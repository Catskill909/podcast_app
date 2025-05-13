// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/podcast.dart';
import '../models/episode.dart';

class PodcastApiService {
  static const String kpfaFeedUrl =
      'https://kpfa.org/program/the-pacifica-evening-news-weekdays/feed/';
      
  // Stream controller to notify listeners when new data is available
  final StreamController<List<Podcast>> _podcastsStreamController = 
      StreamController<List<Podcast>>.broadcast();
      
  // Stream that UI can listen to for updates
  Stream<List<Podcast>> get podcastsStream => _podcastsStreamController.stream;

  String getXmlText(XmlElement? element) {
    if (element == null) return '';
    final buffer = StringBuffer();
    for (final node in element.children) {
      if (node is XmlText) buffer.write(node.value);
      if (node is XmlCDATA) buffer.write(node.value);
    }
    // Fallback: if still empty, try .innerText
    final result = buffer.toString().trim();
    if (result.isNotEmpty) return result;
    
    // More aggressive extraction for elements with CDATA or complex content
    final directText = element.innerText.trim();
    return directText.isNotEmpty ? directText : '';

  }

  // Cache validity duration - consider stale after 30 minutes
  static const cacheFreshnessDuration = Duration(minutes: 30);
  
  Future<List<Podcast>> fetchPodcasts({bool forceRefresh = false}) async {
    final box = Hive.box<Podcast>('podcasts');
    // print('[PodcastApiService] Checking cache...');
    
    // Get the last cache timestamp
    final lastCacheTime = await Hive.box('app_settings').get('last_podcast_fetch_time');
    final DateTime lastFetchTime = lastCacheTime != null 
        ? DateTime.fromMillisecondsSinceEpoch(lastCacheTime) 
        : DateTime.fromMillisecondsSinceEpoch(0);
    
    final bool isCacheFresh = DateTime.now().difference(lastFetchTime) < cacheFreshnessDuration;
    
    // Try cache first if not forcing refresh and cache is fresh
    if (!forceRefresh && box.isNotEmpty && isCacheFresh) {
      // print('[PodcastApiService] Loaded podcasts from cache.');
      final cached = box.values.toList();
      // Start background refresh
      _refreshPodcastsInBackground();
      return cached;
    } else {
      // print('[PodcastApiService] Cache empty or stale, fetching from network...');
      // No cache, stale cache, or forced refresh - fetch from network
      final podcasts = await _fetchAndCacheFromNetwork(box);
      // print('[PodcastApiService] Podcasts from network: count=${podcasts.length}');
      return podcasts;
    }
  }

  void _refreshPodcastsInBackground() async {
    final box = Hive.box<Podcast>('podcasts');
    try {
      // print('[PodcastApiService] Background refresh started.');
      final podcasts = await _fetchAndCacheFromNetwork(box);
      // print('[PodcastApiService] Background refresh complete.');
      
      // Notify listeners that new data is available
      if (podcasts.isNotEmpty) {
        _podcastsStreamController.add(podcasts);
      }
    } catch (e) {
      // print('[PodcastApiService] Background refresh error: $e');
    }
  }

  Future<List<Podcast>> _fetchAndCacheFromNetwork(Box<Podcast> box) async {
    try {
      // print('[PodcastApiService] Fetching from network...');
      final response = await http.get(Uri.parse(kpfaFeedUrl));
      // print('[PodcastApiService] HTTP status: ${response.statusCode}');
      if (response.statusCode != 200) {
        // print('[PodcastApiService] Network error: status ${response.statusCode}');
        throw Exception('Failed to load KPFA feed');
      }
      
      // Update the last fetch timestamp
      await Hive.box('app_settings').put('last_podcast_fetch_time', DateTime.now().millisecondsSinceEpoch);
      final xmlDoc = XmlDocument.parse(response.body);
      final channel = xmlDoc.findAllElements('channel').first;
      final podcast = Podcast(
        id: getXmlText(channel.getElement('link')),
        title: getXmlText(channel.getElement('title')),
        author: getXmlText(channel.getElement('itunes:author')),
        imageUrl:
            channel.getElement('itunes:image')?.getAttribute('href') ?? '',
        description: getXmlText(channel.getElement('description')),
        subtitle: getXmlText(channel.getElement('itunes:subtitle')),
        summary: getXmlText(channel.getElement('itunes:summary')).isNotEmpty
            ? getXmlText(channel.getElement('itunes:summary'))
            : getXmlText(channel.getElement('description')),
        language: getXmlText(channel.getElement('language')),
        copyright: getXmlText(channel.getElement('copyright')),
        category: channel.getElement('itunes:category')?.getAttribute('text'),
        explicitTag: getXmlText(channel.getElement('itunes:explicit')),
        episodes: channel.findElements('item').map((item) {
          final episodeTitle = getXmlText(item.getElement('title'));
          final episodeDescription = getXmlText(item.getElement('description'));
          final episodeSummary = getXmlText(item.getElement('itunes:summary'));
          final episodeContentHtml = getXmlText(item.getElement('content:encoded'));
          final episodeGuid = getXmlText(item.getElement('guid'));
          final episodeExplicitTag = getXmlText(item.getElement('itunes:explicit'));
          final episodePubDate = getXmlText(item.getElement('pubDate'));
          final enclosure = item.getElement('enclosure');
          final imageUrl = item.getElement('itunes:image')?.getAttribute('href') ?? '';
          final durationStr = getXmlText(item.getElement('itunes:duration'));
          final duration = _parseDuration(durationStr);
          return Episode(
            id: episodeGuid.isNotEmpty ? episodeGuid : episodeTitle,
            title: episodeTitle,
            audioUrl: enclosure?.getAttribute('url') ?? '',
            audioLength: int.tryParse(enclosure?.getAttribute('length') ?? ''),
            audioType: enclosure?.getAttribute('type'),
            description: episodeDescription,
            summary: episodeSummary,
            contentHtml: episodeContentHtml,
            imageUrl: (imageUrl.isNotEmpty ? imageUrl : channel.getElement('itunes:image')?.getAttribute('href')) ?? '',
            podcastImageUrl: channel.getElement('itunes:image')?.getAttribute('href') ?? '',
            duration: duration,
            pubDate: _parsePubDate(episodePubDate),
            explicitTag: episodeExplicitTag,
          );
        }).toList(),
      );
      // print('[PodcastApiService] Parsed podcast: title=${podcast.title}, episodes=${podcast.episodes.length}');
      // Clear and update cache
      await box.clear();
      await box.add(podcast);
      // print('[PodcastApiService] Podcast cached.');
      return [podcast];
    } catch (e) {
      // print('[PodcastApiService] ERROR: $e');
      return [];
    }
  }


  Duration _parseDuration(String? input) {
    if (input == null) return Duration.zero;
    final parts = input.split(':').map(int.tryParse).toList();
    if (parts.length == 3) {
      return Duration(
          hours: parts[0] ?? 0, minutes: parts[1] ?? 0, seconds: parts[2] ?? 0);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0] ?? 0, seconds: parts[1] ?? 0);
    } else if (parts.length == 1) {
      return Duration(seconds: parts[0] ?? 0);
    }
    return Duration.zero;
  }

  DateTime? _parsePubDate(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    try {
      // Attempt to parse RFC 822/1123 format (e.g., "Wed, 07 May 2025 18:00:00 +0000")
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", 'en_US').parseUtc(input);
    } catch (e) {
      // Silently return null if parsing fails. Consider logging for production if necessary.
      return null;
    }
  }
}

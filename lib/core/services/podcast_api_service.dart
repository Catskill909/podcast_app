// ignore_for_file: prefer_const_constructors
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/podcast.dart';
import '../models/episode.dart';

class PodcastApiService {
  static const String kpfaFeedUrl =
      'https://kpfa.org/program/the-pacifica-evening-news-weekdays/feed/';

  String getXmlText(XmlElement? element) {
    if (element == null) return '';
    final buffer = StringBuffer();
    for (final node in element.children) {
      if (node is XmlText) buffer.write(node.value);
      if (node is XmlCDATA) buffer.write(node.value);
    }
    // Fallback: if still empty, try .value
    final result = buffer.toString().trim();
    return result.isNotEmpty ? result : (element.value ?? '').trim();
  }

  Future<List<Podcast>> fetchPodcasts() async {
    try {
      final start = DateTime.now();
      // ignore: avoid_print
      print('[fetchPodcasts] Start: ${start.toIso8601String()}');
      final responseStart = DateTime.now();
      // ignore: avoid_print
      print('[fetchPodcasts] Before HTTP request: ${responseStart.difference(start).inMilliseconds} ms');
      final response = await http.get(Uri.parse(kpfaFeedUrl)).timeout(const Duration(seconds: 10));
      final responseEnd = DateTime.now();
      // ignore: avoid_print
      print('[fetchPodcasts] After HTTP response: ${responseEnd.difference(start).inMilliseconds} ms');
      if (response.statusCode != 200) {
        throw Exception('Failed to load KPFA feed');
      }
      final xmlDoc = XmlDocument.parse(response.body);
      final parseEnd = DateTime.now();
      // ignore: avoid_print
      print('[fetchPodcasts] After XML parse: ${parseEnd.difference(start).inMilliseconds} ms');
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
          final episodeContentHtml =
              getXmlText(item.getElement('content:encoded'));
          final episodeGuid = getXmlText(item.getElement('guid'));
          final episodeExplicitTag =
              getXmlText(item.getElement('itunes:explicit'));
          final episodePubDate = getXmlText(item.getElement('pubDate'));
          final enclosure = item.getElement('enclosure');
          final imageUrl =
              item.getElement('itunes:image')?.getAttribute('href') ?? '';
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
            imageUrl: (imageUrl.isNotEmpty
                    ? imageUrl
                    : channel
                        .getElement('itunes:image')
                        ?.getAttribute('href')) ??
                '',
            podcastImageUrl:
                channel.getElement('itunes:image')?.getAttribute('href') ?? '',
            duration: duration,
            pubDate: _parsePubDate(episodePubDate),
            explicitTag: episodeExplicitTag,
          );
        }).toList(),
      );
      final done = DateTime.now();
      // ignore: avoid_print
      print('[fetchPodcasts] After Podcast obj creation: ${done.difference(start).inMilliseconds} ms');
      return [podcast];
    } catch (e) {
      // ignore: avoid_print
      print('[fetchPodcasts] ERROR: $e');
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
    if (input == null) return null;
    try {
      return DateTime.parse(input);
    } catch (_) {
      // Try RFC822 parsing
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/models/podcast.dart';
import '../../core/models/episode.dart';
import '../../core/services/podcast_api_service.dart';

class PodcastDetailScreen extends StatefulWidget {
  final Podcast podcast;
  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  bool _expanded = false;
  late Podcast _currentPodcast;
  final PodcastApiService _apiService = PodcastApiService();

  @override
  void initState() {
    super.initState();
    _currentPodcast = widget.podcast;
  }

  Future<void> _refreshPodcastDetails() async {
    try {
      List<Podcast> refreshedPodcasts = await _apiService.fetchPodcasts(forceRefresh: true);
      Podcast? updatedPodcast = refreshedPodcasts.firstWhere(
        (p) => p.id == _currentPodcast.id,
        orElse: () {
          return _currentPodcast;
        }
      );

      if (mounted && updatedPodcast.id == _currentPodcast.id) {
        setState(() {
          _currentPodcast = updatedPodcast;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh episodes: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Pacifica Evening News')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundImage: _currentPodcast.imageUrl.isNotEmpty
                    ? NetworkImage(_currentPodcast.imageUrl) as ImageProvider
                    : const AssetImage('assets/images/pacifica-news.png'),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final text = _currentPodcast.description;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      secondChild: Text(
                        text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _expanded ? 'Read less' : 'Read more',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Text(
                'Episodes',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPodcastDetails,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey[900],
                child: ListView.builder(
                  itemCount: _currentPodcast.episodes.length,
                  itemBuilder: (context, index) {
                    final episode = _currentPodcast.episodes[index];
                    return Card(
                      color: Colors.grey[900],
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/player',
                            arguments: Episode(
                              id: episode.id,
                              title: episode.title,
                              audioUrl: episode.audioUrl,
                              description: episode.description,
                              duration: episode.duration,
                              podcastImageUrl: episode.imageUrl.isNotEmpty
                                  ? episode.imageUrl
                                  : _currentPodcast.imageUrl,
                              summary: episode.summary,
                              contentHtml: episode.contentHtml,
                              imageUrl: episode.imageUrl,
                              audioLength: episode.audioLength,
                              audioType: episode.audioType,
                              pubDate: episode.pubDate,
                              explicitTag: episode.explicitTag,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                shadowColor:
                                    Colors.black.withAlpha((0.15 * 255).toInt()),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white24, width: 1.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: episode.imageUrl.isNotEmpty
                                        ? Image.network(
                                            episode.imageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/pacifica-news.png',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : (_currentPodcast.imageUrl.isNotEmpty
                                            ? Image.network(
                                                _currentPodcast.imageUrl,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    'assets/images/pacifica-news.png',
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                'assets/images/pacifica-news.png',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              )),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      episode.pubDate != null &&
                                              episode.title.isNotEmpty
                                          ? '${episode.title} – ${_formatPubDate(episode.pubDate)}'
                                          : (episode.title.isNotEmpty
                                              ? episode.title
                                              : _formatPubDate(episode.pubDate)),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white.withAlpha(220),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPubDate(DateTime? date) {
    if (date == null) return '';
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}

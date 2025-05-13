import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore_for_file: prefer_const_constructors
import '../../core/services/podcast_api_service.dart';
import '../../core/models/podcast.dart';
import '../widgets/podcast_drawer.dart';
import 'package:provider/provider.dart';
import '../../core/providers/connectivity_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Podcast>> _podcastFuture;
  final PodcastApiService apiService = PodcastApiService();
  StreamSubscription<List<Podcast>>? _podcastStreamSubscription;

  @override
  void initState() {
    super.initState();
    _fetchWithTimeout();
    
    // Listen to the stream for updates from background refresh
    _podcastStreamSubscription = apiService.podcastsStream.listen((updatedPodcasts) {
      // When new data is available from background refresh, update the UI
      setState(() {
        _podcastFuture = Future.value(updatedPodcasts);
      });
    });
  }
  
  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _podcastStreamSubscription?.cancel();
    super.dispose();
  }

  void _fetchWithTimeout({bool forceRefresh = false}) {
    setState(() {
      _podcastFuture = apiService.fetchPodcasts(forceRefresh: forceRefresh).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Network request timed out'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final networkStatus = Provider.of<ConnectivityProvider>(context).status;
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 56,
              child: Image.asset(
                'assets/images/header.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Logo', style: TextStyle(color: Colors.white)),
              ),
            ),
            Positioned(
              right: 0,
              child: SizedBox(width: 56), // matches default leading icon width
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      drawer: const PodcastDrawer(),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: networkStatus == NetworkStatus.offline
                ? MaterialBanner(
                    key: const ValueKey('offline-banner'),
                    backgroundColor: Colors.grey[900]!.withAlpha(230),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.wifi_off, color: Colors.redAccent.withAlpha(200), size: 32),
                    content: Text(
                      'You are offline. Some features may be unavailable.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Oswald',
                            color: Colors.white,
                          ) ?? const TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                    ),
                    actions: [
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text('Retry', style: GoogleFonts.oswald(color: Colors.white)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent.withAlpha(60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _fetchWithTimeout,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchWithTimeout(forceRefresh: true);
                return;
              },
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[900],
              child: FutureBuilder<List<Podcast>>(
                future: _podcastFuture,
                builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading podcasts...',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            final isTimeout = snapshot.error is TimeoutException;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.redAccent.withAlpha(180)),
                  const SizedBox(height: 8),
                  Text(
                    isTimeout ? 'Request timed out' : 'Couldn\'t load feed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Oswald',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to retry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _fetchWithTimeout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No podcasts available',
                style: TextStyle(fontFamily: 'Oswald', color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final podcasts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Podcasts',
                  style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.15 * 255).toInt()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: podcast,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    shadowColor: Colors.black.withAlpha((0.15 * 255).toInt()),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white24, width: 1.2),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: (podcast.imageUrl.isNotEmpty)
                                            ? Image.network(
                                                podcast.imageUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/pacifica-news.png',
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          podcast.title,
                                          key: ValueKey(podcast.title),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Oswald',
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          podcast.author,
                                          key: ValueKey(podcast.author),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontFamily: 'Oswald',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

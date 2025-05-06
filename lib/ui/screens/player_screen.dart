import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import 'package:provider/provider.dart';
import '../../core/providers/audio_provider.dart';
import 'package:share_plus/share_plus.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode;
  const PlayerScreen({super.key, required this.episode});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioProvider audioProvider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      audioProvider = Provider.of<AudioProvider>(context, listen: false);
      if (audioProvider.currentEpisode?.id != widget.episode.id) {
        audioProvider.setCurrentEpisode(widget.episode);
      }
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Pacifica Evening News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share(
                'Check out this episode of The Pacifica Evening News: ${widget.episode.title}',
                subject: widget.episode.title,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          child: (widget.episode.imageUrl.isNotEmpty)
                              ? Image.network(
                                  widget.episode.imageUrl,
                                  width: MediaQuery.of(context).size.width,
                                  height: 240,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/pacifica-news.png',
                                  width: MediaQuery.of(context).size.width,
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                        ),


                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 91, // covers 38% of the image (240px height)
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(220), // darker
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Text(
                            widget.episode.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'Oswald',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              shadows: const [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black87,
                                  offset: Offset(0, 2),
                                ),
                                Shadow(
                                  blurRadius: 16,
                                  color: Colors.black54,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Consumer<AudioProvider>(
                      builder: (context, audioProvider, child) {
                        final isPlaying = audioProvider.isPlaying;
                        final isCompleted = audioProvider.isCompleted;
                        final position = isCompleted ? Duration.zero : audioProvider.position;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10),
                              iconSize: 36,
                              onPressed: () => audioProvider
                                  .seek(position - const Duration(seconds: 10)),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: Icon(
                                  isCompleted || !isPlaying
                                      ? Icons.play_circle_fill
                                      : Icons.pause_circle_filled,
                                  size: 56),
                              iconSize: 56,
                              onPressed: () => (isCompleted || !isPlaying)
                                  ? audioProvider.play()
                                  : audioProvider.pause(),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.forward_10),
                              iconSize: 36,
                              onPressed: () => audioProvider
                                  .seek(position + const Duration(seconds: 10)),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer<AudioProvider>(
                      builder: (context, audioProvider, child) {
                        final mediaItem =
                            audioProvider.audioHandler.mediaItem.value;
                        final totalDuration =
                            mediaItem?.duration ?? Duration.zero;
                        final sliderMax = totalDuration.inSeconds.toDouble();

                        return StreamBuilder<Duration>(
                          stream: audioProvider.positionStream,
                          initialData: audioProvider.position,
                          builder: (context, snapshot) {
                            final isCompleted = audioProvider.isCompleted;
                            final position = isCompleted ? Duration.zero : (snapshot.data ?? Duration.zero);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Slider(
                                    value: position.inSeconds
                                        .toDouble()
                                        .clamp(0.0, sliderMax),
                                    min: 0,
                                    max: sliderMax > 0 ? sliderMax : 1.0,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                    thumbColor: Colors.white,
                                    onChanged: (value) => audioProvider
                                        .seek(Duration(seconds: value.toInt())),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(position)),
                                      Text(_formatDuration(totalDuration)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        widget.episode.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(220),
                          fontSize: 13,
                          fontFamily: 'Oswald',
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

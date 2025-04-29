import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import 'package:provider/provider.dart';
import '../../core/providers/audio_provider.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode;
  const PlayerScreen({super.key, required this.episode});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioProvider audioProvider;
  late AudioPlayer player;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.setCurrentEpisode(widget.episode);
      player = audioProvider.audioService.audioPlayer;
      await audioProvider.audioService.setUrl(widget.episode.audioUrl);
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.episode.title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.podcasts, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 32),
                  Text(widget.episode.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(widget.episode.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final playing = state?.playing ?? false;
                      final processing = state?.processingState == ProcessingState.loading || state?.processingState == ProcessingState.buffering;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10),
                            iconSize: 36,
                            onPressed: () => player.seek(player.position - const Duration(seconds: 10)),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: Icon(
                              processing
                                  ? Icons.hourglass_empty
                                  : (playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
                              size: 56,
                            ),
                            iconSize: 56,
                            onPressed: processing
                                ? null
                                : () => playing ? player.pause() : player.play(),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.forward_10),
                            iconSize: 36,
                            onPressed: () => player.seek(player.position + const Duration(seconds: 10)),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder<Duration?>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final total = player.duration ?? widget.episode.duration;
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            min: 0,
                            max: total.inSeconds.toDouble(),
                            onChanged: (value) => player.seek(Duration(seconds: value.toInt())),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(total)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
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


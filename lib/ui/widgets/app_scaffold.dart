import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/audio_provider.dart';
import 'mini_player.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final episode = audioProvider.currentEpisode;
    final isPlaying = episode != null ? audioProvider.isPlaying : false;
    return Stack(
      children: [
        child,
        if (episode != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: SizedBox(
                    height: 56,
                    child: MiniPlayer(
                      title: episode.title,
                      isPlaying: isPlaying,
                      onTap: () {
                        Navigator.of(context).pushNamed('/player', arguments: episode);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

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
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      Colors.white.withOpacity(0.07),
                      Theme.of(context).colorScheme.background,
                    ),
                    border: Border.all(
                      color: Colors.white.withAlpha(46),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.32),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    borderRadius: BorderRadius.circular(20),
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
          ),
      ],
    );
  }
}

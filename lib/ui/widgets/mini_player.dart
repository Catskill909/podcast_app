import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/connectivity_provider.dart'; 
// import '../../core/models/episode.dart'; 
import '../../core/providers/audio_provider.dart'; 

SnackBar buildNoConnectionSnackBar(
  BuildContext context,
  String episodeTitle,
  VoidCallback onRetryPlay,
) {
  return SnackBar(
    backgroundColor: Colors.grey[900]!.withAlpha(230),
    content: Row(
      children: [
        Icon(Icons.wifi_off, color: Colors.redAccent.withAlpha(200)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'No connection. Unable to play episode.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Oswald',
                  color: Colors.white,
                ) ??
                const TextStyle(
                  fontFamily: 'Oswald',
                  color: Colors.white,
                  fontSize: 16,
                ),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: Text('Retry',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontFamily: 'Oswald', color: Colors.white)),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.redAccent.withAlpha(60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onRetryPlay();
          },
        ),
      ],
    ),
    duration: const Duration(seconds: 4),
    margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
  );
}

class MiniPlayer extends StatelessWidget {
  final String title;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPauseTap;

  const MiniPlayer({
    super.key,
    required this.title,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPauseTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(150),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 12,
              offset: Offset(0, 2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x1EFFFFFF),
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x1EFFFFFF),
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x3C000000),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0.3,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
                final audioProvider = Provider.of<AudioProvider>(context, listen: false);

                // If trying to play (currently not playing) AND offline
                if (!audioProvider.isPlaying && connectivityProvider.status == NetworkStatus.offline) {
                  final currentEpisode = audioProvider.currentEpisode; 
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildNoConnectionSnackBar(
                      context,
                      currentEpisode?.title ?? 'this episode', 
                      onPlayPauseTap, 
                    ),
                  );
                } else {
                  // If online, or if already playing (then it's a pause request)
                  onPlayPauseTap();
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

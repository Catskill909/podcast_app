import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final bool isPlaying;
  final VoidCallback onTap;
  const MiniPlayer({
    super.key,
    required this.title,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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

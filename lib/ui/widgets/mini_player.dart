import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPauseTap; // Added new callback
  const MiniPlayer({
    super.key,
    required this.title,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPauseTap, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Replaced Icon with IconButton for separate tap handling
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onPlayPauseTap, // Use the new callback
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

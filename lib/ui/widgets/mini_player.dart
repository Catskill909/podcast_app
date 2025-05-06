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
        // ignore: prefer_const_constructors
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(150), // More subtle border
            width: 2.0, // Reduced width
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28000000), // Black with alpha 40
              blurRadius: 12,
              offset: Offset(0, 2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x1EFFFFFF), // White with alpha 30
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x1EFFFFFF), // White with alpha 30
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0.2,
            ),
            BoxShadow(
              color: Color(0x3C000000), // Black with alpha 60
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0.3,
            ),
          ],
        ),
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

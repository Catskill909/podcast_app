import 'package:flutter/material.dart';

class SocialCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color iconColor;
  final Color backgroundColor;

  const SocialCircleButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.size = 44.0,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: size * 0.55, // scale icon nicely within circle
            ),
          ),
        ),
      ),
    );
  }
}

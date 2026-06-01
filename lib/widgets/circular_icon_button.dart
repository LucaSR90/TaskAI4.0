import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 42,
    this.showDot = false,
    this.dotColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool showDot;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: backgroundColor ?? AppColors.accent.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                size: size * 0.48,
                color: iconColor ?? AppColors.accentLight,
              ),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dotColor ?? const Color(0xFFFF6B6B),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

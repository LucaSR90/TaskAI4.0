import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta tipo mockup: `HOY · 3 PENDIENTES`
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.left,
    required this.right,
  });

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
              ),
          children: [
            TextSpan(
              text: left.toUpperCase(),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const TextSpan(
              text: '  ·  ',
              style: TextStyle(color: AppColors.textMuted),
            ),
            TextSpan(
              text: right.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

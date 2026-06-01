import 'package:flutter/material.dart';

class GlassTag extends StatelessWidget {
  const GlassTag({
    super.key,
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: filled
            ? color.withValues(alpha: 0.35)
            : color.withValues(alpha: 0.14),
        border: Border.all(
          color: color.withValues(alpha: filled ? 0.5 : 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

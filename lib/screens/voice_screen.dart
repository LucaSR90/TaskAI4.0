import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                ),
                Text(
                  'Capturar tarea',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(
            height: 100,
            width: 200,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AudioWavePainter(progress: _waveController.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          _MicButton(onTap: () {}),
          const SizedBox(height: 18),
          Text(
            'Escuchando...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Recordar llamar al cliente García el viernes a las 10am sobre la propuesta',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: AppColors.textPrimary.withValues(alpha: 0.92),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Captura de voz no implementada en v1.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accentLight, AppColors.micGlow],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.5),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 44),
      ),
    );
  }
}

class _AudioWavePainter extends CustomPainter {
  _AudioWavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentLight
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const barCount = 12;
    final spacing = size.width / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = spacing * i + spacing / 2;
      final phase = i * 0.55 + progress * math.pi * 2;
      final h = size.height * (0.25 + 0.75 * (math.sin(phase) * 0.5 + 0.5));

      canvas.drawLine(
        Offset(x, centerY - h / 2),
        Offset(x, centerY + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

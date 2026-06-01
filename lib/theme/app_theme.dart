import 'package:flutter/material.dart';

import '../models/task_category.dart';
import '../models/task_priority.dart';

class AppColors {
  static const background = Color(0xFF121214);
  static const surface = Color(0xFF1A1A1F);
  static const surfaceElevated = Color(0xFF242429);
  static const card = Color(0xFF1E1E24);
  static const cardHighlight = Color(0xFF25252D);
  static const border = Color(0xFF32323C);
  static const textPrimary = Color(0xFFF4F4F6);
  static const textSecondary = Color(0xFF8E8E9A);
  static const textMuted = Color(0xFF6B6B78);

  /// Azul eléctrico del mockup
  static const accent = Color(0xFF2F7BFF);
  static const accentLight = Color(0xFF4A9FFF);
  static const accentGlow = Color(0xFF5B9FFF);
  static const micGlow = Color(0xFF1E5FD4);

  static const notificationBell = Color(0xFFFFC107);
  static const checkboxPending = Color(0xFFE85D5D);
  static const priorityAltaBg = Color(0xFF8B3A3A);
  static const priorityMediaBg = Color(0xFF6B5A2E);
  static const priorityBajaBg = Color(0xFF2D4A35);

  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return const Color(0xFFFF6B6B);
      case TaskPriority.media:
        return const Color(0xFFE8C547);
      case TaskPriority.baja:
        return const Color(0xFF5CB87A);
    }
  }

  static Color priorityBackground(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return priorityAltaBg;
      case TaskPriority.media:
        return priorityMediaBg;
      case TaskPriority.baja:
        return priorityBajaBg;
    }
  }

  static Color categoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.trabajo:
        return accentLight;
      case TaskCategory.personal:
        return const Color(0xFF4ADE80);
      case TaskCategory.estudio:
        return const Color(0xFF38BDF8);
      case TaskCategory.urgente:
        return const Color(0xFFFF8C42);
    }
  }
}

class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme.copyWith(
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accentLight,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.accent.withValues(alpha: 0.22),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.accentLight : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.accentLight : AppColors.textSecondary,
            size: 22,
          );
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.border;
        }),
      ),
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.accentLight,
          fontWeight: FontWeight.w800,
          fontSize: 28,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF0F2F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.accent.withValues(alpha: 0.12),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isDarkModeProvider = StateProvider<bool>((ref) => true);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(isDarkModeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

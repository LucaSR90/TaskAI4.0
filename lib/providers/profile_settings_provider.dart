import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoolSettingsNotifier extends StateNotifier<bool> {
  BoolSettingsNotifier(this.storageKey, {bool defaultValue = true}) : super(defaultValue) {
    _load();
  }

  final String storageKey;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(storageKey) ?? state;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKey, state);
  }
  
  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKey, state);
  }
}

final notificationsEnabledProvider = StateNotifierProvider<BoolSettingsNotifier, bool>((ref) {
  return BoolSettingsNotifier('notifications_enabled');
});

final agenticAiEnabledProvider = StateNotifierProvider<BoolSettingsNotifier, bool>((ref) {
  return BoolSettingsNotifier('agentic_ai_enabled');
});

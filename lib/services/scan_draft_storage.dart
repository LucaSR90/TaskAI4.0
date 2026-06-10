import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/scanned_task_draft.dart';

class ScanDraftStorage {
  ScanDraftStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _key = 'taskai_scan_draft';

  final FlutterSecureStorage _storage;

  Future<void> save(ScannedTaskDraft draft) async {
    await _storage.write(
      key: _key,
      value: jsonEncode({
        'title': draft.title,
        'description': draft.description,
        'source': draft.source.name,
      }),
    );
  }

  Future<ScannedTaskDraft?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ScannedTaskDraft(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      source: ScanSource.values.byName(map['source'] as String? ?? 'ocr'),
    );
  }

  Future<void> clear() async => _storage.delete(key: _key);
}

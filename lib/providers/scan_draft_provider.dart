import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scanned_task_draft.dart';
import '../services/scan_draft_storage.dart';

final scanDraftStorageProvider = Provider<ScanDraftStorage>(
  (ref) => ScanDraftStorage(),
);

final pendingScanDraftProvider =
    StateProvider<ScannedTaskDraft?>((ref) => null);

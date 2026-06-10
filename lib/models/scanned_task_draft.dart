enum ScanMode { ocr, qr }

enum ScanSource { ocr, qr }

class ScannedTaskDraft {
  const ScannedTaskDraft({
    required this.title,
    required this.description,
    required this.source,
  });

  final String title;
  final String description;
  final ScanSource source;

  bool get isValid => title.trim().isNotEmpty;

  factory ScannedTaskDraft.fromOcrText(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const ScannedTaskDraft(
        title: '',
        description: '',
        source: ScanSource.ocr,
      );
    }

    return ScannedTaskDraft(
      title: lines.first,
      description: lines.length > 1 ? lines.sublist(1).join('\n') : '',
      source: ScanSource.ocr,
    );
  }

  factory ScannedTaskDraft.fromQrJson(Map<String, dynamic> json) {
    return ScannedTaskDraft(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      source: ScanSource.qr,
    );
  }
}

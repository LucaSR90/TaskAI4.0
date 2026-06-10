import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/scanned_task_draft.dart';

class MlKitScanService {
  CameraController? _controller;
  TextRecognizer? _textRecognizer;
  BarcodeScanner? _barcodeScanner;

  bool _isProcessing = false;
  bool _isDisposed = false;
  Timer? _scanTimer;

  CameraController? get controller => _controller;
  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  Future<void> initializeCamera() async {
    if (_isDisposed) return;

    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  void _ensureRecognizers(ScanMode mode) {
    if (mode == ScanMode.ocr) {
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    } else {
      _barcodeScanner ??= BarcodeScanner(
        formats: [BarcodeFormat.qrCode],
      );
    }
  }

  void startPeriodicScan({
    required ScanMode mode,
    required void Function(ScannedTaskDraft draft) onResult,
    required void Function(Object error) onError,
    Duration interval = const Duration(milliseconds: 1200),
  }) {
    stopPeriodicScan();
    _ensureRecognizers(mode);

    _scanTimer = Timer.periodic(interval, (_) async {
      if (_isProcessing || !isInitialized || _isDisposed) return;
      _isProcessing = true;

      try {
        final file = await _controller!.takePicture();
        final draft = await _processImageFile(file.path, mode);
        try {
          await File(file.path).delete();
        } catch (_) {}

        if (draft.isValid) onResult(draft);
      } catch (e) {
        onError(e);
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<ScannedTaskDraft> _processImageFile(
    String path,
    ScanMode mode,
  ) async {
    final inputImage = InputImage.fromFilePath(path);

    if (mode == ScanMode.ocr) {
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
      final result = await _textRecognizer!.processImage(inputImage);
      return ScannedTaskDraft.fromOcrText(result.text);
    } else {
      _barcodeScanner ??= BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      final barcodes = await _barcodeScanner!.processImage(inputImage);
      for (final barcode in barcodes) {
        final raw = barcode.rawValue;
        if (raw == null || raw.isEmpty) continue;

        try {
          final json = jsonDecode(raw) as Map<String, dynamic>;
          final draft = ScannedTaskDraft.fromQrJson(json);
          if (draft.isValid) return draft;
        } on FormatException {
          continue;
        }
      }
      return const ScannedTaskDraft(
        title: '',
        description: '',
        source: ScanSource.qr,
      );
    }
  }

  void stopPeriodicScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    stopPeriodicScan();
    await _controller?.dispose();
    await _textRecognizer?.close();
    await _barcodeScanner?.close();

    _controller = null;
    _textRecognizer = null;
    _barcodeScanner = null;
  }
}


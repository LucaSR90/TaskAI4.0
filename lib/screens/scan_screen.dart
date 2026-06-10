import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/scanned_task_draft.dart';
import '../providers/scan_draft_provider.dart';
import '../services/camera_permission_service.dart';
import '../services/ml_kit_scan_service.dart';
import '../theme/app_theme.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _scanService = MlKitScanService();
  final _permissionService = CameraPermissionService();

  ScanMode _mode = ScanMode.ocr;
  bool _loading = true;
  bool _hasResult = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final permission = await _permissionService.checkAndRequest();

    if (!mounted) return;

    if (permission != CameraPermissionStatus.granted) {
      setState(() {
        _loading = false;
        _errorMessage = _permissionMessage(permission);
      });
      await _showPermissionDialog(permission);
      return;
    }

    try {
      await _scanService.initializeCamera();
      if (!mounted) return;
      setState(() => _loading = false);
      _startScanning();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo iniciar la cámara: $e';
      });
    }
  }

  void _startScanning() {
    _scanService.startPeriodicScan(
      mode: _mode,
      onResult: _onDraftDetected,
      onError: (e) {
        if (!mounted || _hasResult) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar imagen: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _onDraftDetected(ScannedTaskDraft draft) async {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    _scanService.stopPeriodicScan();

    final storage = ref.read(scanDraftStorageProvider);
    await storage.save(draft);
    ref.read(pendingScanDraftProvider.notifier).state = draft;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _mode == ScanMode.ocr
              ? 'Texto detectado. Campos rellenados.'
              : 'QR importado correctamente.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );

    context.pop(true);
  }

  void _switchMode(ScanMode mode) {
    if (_mode == mode || _hasResult) return;
    setState(() => _mode = mode);
    _scanService.stopPeriodicScan();
    _startScanning();
  }

  String _permissionMessage(CameraPermissionStatus status) {
    switch (status) {
      case CameraPermissionStatus.permanentlyDenied:
        return 'El permiso de cámara fue denegado permanentemente.';
      case CameraPermissionStatus.restricted:
        return 'El acceso a la cámara está restringido en este dispositivo.';
      case CameraPermissionStatus.denied:
        return 'Se necesita permiso de cámara para escanear.';
      case CameraPermissionStatus.granted:
        return '';
    }
  }

  Future<void> _showPermissionDialog(CameraPermissionStatus status) async {
    final openSettings = status == CameraPermissionStatus.permanentlyDenied;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permiso de cámara requerido'),
        content: Text(
          openSettings
              ? 'TaskAI necesita la cámara para OCR y códigos QR. '
                  'Actívala en Ajustes del sistema.'
              : 'Concede acceso a la cámara para capturar texto o importar tareas desde QR.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop(false);
            },
            child: const Text('Cancelar'),
          ),
          if (openSettings)
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _permissionService.openSettings();
              },
              child: const Text('Abrir Ajustes'),
            )
          else
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                setState(() {
                  _loading = true;
                  _errorMessage = null;
                });
                await _bootstrap();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _scanService.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(false),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorState(message: _errorMessage!)
              : Column(
                  children: [
                    Expanded(
                      child: controller == null
                          ? const SizedBox.shrink()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CameraPreview(controller),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _ModeToggle(
                      mode: _mode,
                      onChanged: _switchMode,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Text(
                        _mode == ScanMode.ocr
                            ? 'Apunta a un texto impreso. La primera línea será el título.'
                            : 'Escanea un QR con JSON: {"title":"...","description":"..."}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final ScanMode mode;
  final ValueChanged<ScanMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SegmentedButton<ScanMode>(
        segments: const [
          ButtonSegment(
            value: ScanMode.ocr,
            icon: Icon(Icons.document_scanner_outlined),
            label: Text('OCR'),
          ),
          ButtonSegment(
            value: ScanMode.qr,
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: Text('QR'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

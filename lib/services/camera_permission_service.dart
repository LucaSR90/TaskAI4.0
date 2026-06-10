import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

class CameraPermissionService {
  Future<CameraPermissionStatus> checkAndRequest() async {
    var status = await Permission.camera.status;

    if (status.isGranted) return CameraPermissionStatus.granted;
    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) return CameraPermissionStatus.restricted;

    status = await Permission.camera.request();

    if (status.isGranted) return CameraPermissionStatus.granted;
    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) return CameraPermissionStatus.restricted;

    return CameraPermissionStatus.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}

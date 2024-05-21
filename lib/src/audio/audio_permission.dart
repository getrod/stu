import 'package:permission_handler/permission_handler.dart';

/// Will keep requesting mic permission until accepted.
/// 
/// This is because the [AudioEngine] can't function until
/// the microphone is accepted.
Future<bool> requestMicPermission() async {
  return Permission.microphone.request().isGranted;
}
import 'package:flutter/foundation.dart';

import '../../standalone/platform_detect.dart' as platform;

/// Platforms where [mobile_scanner] exposes a live camera.
bool get percQrScannerSupported {
  if (kIsWeb) return true;
  return platform.platformIsMobile || platform.platformIsMacOS;
}
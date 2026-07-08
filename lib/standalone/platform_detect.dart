export '../wallet_core/services/platform_detect_stub.dart'
    if (dart.library.io) '../wallet_core/services/platform_detect_io.dart'
    if (dart.library.html) '../wallet_core/services/platform_detect_web.dart';
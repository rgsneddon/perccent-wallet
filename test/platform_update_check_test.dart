import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/wallet_core/services/app_update_check.dart';

void main() {
  tearDown(() {
    AppUpdateChecker.fetchBodyOverride = null;
    debugDefaultTargetPlatformOverride = null;
  });

  test('Windows on latest platform build ignores newer global-only version', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    AppUpdateChecker.fetchBodyOverride = (uri) async => '''
{
  "version": "1.1.7",
  "build_number": 12,
  "package_name": "perccent_wallet",
  "platforms": {
    "windows": { "version": "1.1.6", "build_number": 11 },
    "ios": { "version": "1.1.6", "build_number": 11 }
  }
}
''';

    final info = await const AppUpdateChecker().check(current: '1.1.6+11');

    expect(info.checkSucceeded, isTrue);
    expect(info.updateAvailable, isFalse);
    expect(info.latestFull, '1.1.6+11');
  });

  test('Windows advertises update when platform feed is newer', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    AppUpdateChecker.fetchBodyOverride = (uri) async => '''
{
  "version": "1.1.6",
  "build_number": 11,
  "package_name": "perccent_wallet",
  "platforms": {
    "windows": { "version": "1.1.6", "build_number": 11 },
    "ios": { "version": "1.1.6", "build_number": 11 }
  }
}
''';

    final info = await const AppUpdateChecker().check(current: '1.1.5+10');

    expect(info.checkSucceeded, isTrue);
    expect(info.updateAvailable, isTrue);
    expect(info.latestFull, '1.1.6+11');
    expect(
      AppUpdateChecker.updateUrlsForRelease(info.latestRelease).first,
      contains('perccent-wallet-v1.1.6-windows-x64-setup.exe'),
    );
  });

  test('Android ignores newer iOS-only platform entry', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AppUpdateChecker.fetchBodyOverride = (uri) async => '''
{
  "version": "1.1.6",
  "build_number": 11,
  "package_name": "perccent_wallet",
  "platforms": {
    "android": { "version": "1.1.6", "build_number": 11 },
    "ios": { "version": "1.1.7", "build_number": 12 }
  }
}
''';

    final info = await const AppUpdateChecker().check(current: '1.1.6+11');

    expect(info.checkSucceeded, isTrue);
    expect(info.updateAvailable, isFalse);
    expect(info.latestFull, '1.1.6+11');
  });

  test('iOS uses ios platform entry for comparison', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    AppUpdateChecker.fetchBodyOverride = (uri) async => '''
{
  "version": "1.1.6",
  "build_number": 11,
  "package_name": "perccent_wallet",
  "platforms": {
    "windows": { "version": "1.1.6", "build_number": 11 },
    "ios": { "version": "1.1.7", "build_number": 12 }
  }
}
''';

    final info = await const AppUpdateChecker().check(current: '1.1.6+11');

    expect(info.checkSucceeded, isTrue);
    expect(info.updateAvailable, isTrue);
    expect(info.latestFull, '1.1.7+12');
    expect(
      AppUpdateChecker.updateUrlsForRelease(info.latestRelease).first,
      contains('perccent-wallet-v1.1.7-ios-setup.ipa'),
    );
  });
}
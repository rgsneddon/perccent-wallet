import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/perc/perc_app_version.dart';
import 'package:perccent_wallet/wallet_core/services/app_update_check.dart';

String _pubspecVersion() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(r'^version:\s*([0-9.]+\+\d+)', multiLine: true)
      .firstMatch(pubspec);
  if (match == null) {
    fail('pubspec.yaml missing version: line');
  }
  return match.group(1)!;
}

void main() {
  test('PercAppVersion.current matches pubspec.yaml version', () {
    expect(PercAppVersion.current, _pubspecVersion());
  });

  test('version.json matches PercAppVersion.current', () {
    final jsonFile = File('version.json');
    expect(jsonFile.existsSync(), isTrue);
    final json = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
    final release = (json['version'] as String).trim();
    final build = int.tryParse('${json['build_number']}') ?? 0;
    expect('$release+$build', PercAppVersion.current);
    expect(release, '1.1.7');
  });

  test('AppUpdateChecker reports no update when remote matches current', () async {
    AppUpdateChecker.fetchBodyOverride = (uri) async {
      final release = PercAppVersion.releaseOf(PercAppVersion.current);
      final build = PercAppVersion.buildOf(PercAppVersion.current);
      return '''
{
  "version":"$release",
  "build_number":$build,
  "package_name":"perccent_wallet",
  "platforms":{
    "windows":{"version":"$release","build_number":$build},
    "android":{"version":"$release","build_number":$build},
    "ios":{"version":"$release","build_number":$build}
  }
}
''';
    };
    addTearDown(() => AppUpdateChecker.fetchBodyOverride = null);

    final info = await const AppUpdateChecker().check(
      current: PercAppVersion.current,
    );

    expect(info.checkSucceeded, isTrue);
    expect(info.updateAvailable, isFalse);
    expect(info.currentFull, PercAppVersion.current);
    expect(info.latestFull, PercAppVersion.current);
  });

  test('pre-fix constant would have falsely advertised 1.0.5 update', () {
    // Documents regression: stale 1.0.2+3 vs remote 1.0.5+3 triggered update nag.
    expect(PercAppVersion.isNewerThan('1.0.5+3', '1.0.2+3'), isTrue);
    expect(PercAppVersion.isNewerThan('1.0.5+3', PercAppVersion.current), isFalse);
  });
}
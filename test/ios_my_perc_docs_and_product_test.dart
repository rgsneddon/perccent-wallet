import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Portable scratch for evidence (goal harness + local runs).
String _scratchDir() {
  final env = Platform.environment['GROK_GOAL_SCRATCH'] ??
      Platform.environment['TMPDIR'] ??
      Directory.systemTemp.path;
  final dir = Directory(
    '$env${Platform.pathSeparator}perccent_ios_my_perc_test',
  );
  dir.createSync(recursive: true);
  return dir.path;
}

String _repoRoot() {
  var dir = File(Platform.script.toFilePath()).parent;
  while (!File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not locate perccent_wallet root');
    }
    dir = parent;
  }
  return dir.path;
}

File _repoFile(String relativePath) {
  final normalized = relativePath.replaceAll('/', Platform.pathSeparator);
  return File('${_repoRoot()}${Platform.pathSeparator}$normalized');
}

Directory _repoDir(String relativePath) {
  final normalized = relativePath.replaceAll('/', Platform.pathSeparator);
  return Directory('${_repoRoot()}${Platform.pathSeparator}$normalized');
}

void main() {
  test('README documents MY PERC iOS build and downloads', () {
    final readme = _repoFile('README.md').readAsStringSync();
    expect(readme, contains('MY PERC'));
    expect(readme, contains('iOS'));
    expect(readme, contains('flutter build ios'));
    expect(readme, contains('perccent-wallet'));
    expect(readme, contains('ios-setup.ipa'));
    expect(readme, contains('RELEASE_NOTES.md'));

    final out = File(
      '${_scratchDir()}${Platform.pathSeparator}readme_ios_excerpt.txt',
    );
    final lines = readme
        .split('\n')
        .where(
          (l) =>
              l.contains('iOS') ||
              l.contains('MY PERC') ||
              l.contains('flutter build ios') ||
              l.contains('Simulator'),
        )
        .take(40)
        .join('\n');
    out.writeAsStringSync(lines);
  });

  test('privacy policy and LICENSE cover MY PERC iOS accurately', () {
    final privacy = _repoFile('PRIVACY_POLICY.md').readAsStringSync();
    final license = _repoFile('LICENSE').readAsStringSync();

    expect(privacy, contains('MY PERC'));
    expect(privacy, contains('iOS'));
    expect(privacy, contains('Android and iOS'));
    expect(privacy, contains('Face ID'));
    expect(privacy, contains('Keychain'));
    expect(
      privacy.toLowerCase(),
      isNot(contains('biometric vault enrollment is not enabled on ios')),
    );

    expect(license, contains('MY PERC'));
    expect(license, contains('iOS'));
    expect(license, contains('personal'));
    expect(license, contains('Commercial License'));

    File('${_scratchDir()}${Platform.pathSeparator}legal_check.txt')
        .writeAsStringSync(
      'privacy_has_ios=${privacy.contains('iOS')}\n'
      'privacy_mobile_biometrics=${privacy.contains('Android and iOS')}\n'
      'license_has_ios=${license.contains('iOS')}\n'
      'license_my_perc=${license.contains('MY PERC')}\n',
    );
  });

  test('release notes describe iOS MY PERC build and doc updates', () {
    final notes = _repoFile('RELEASE_NOTES.md').readAsStringSync();
    expect(notes, contains('MY PERC'));
    expect(notes, contains('iOS'));
    expect(notes, contains('PRIVACY_POLICY'));
    expect(notes, contains('LICENSE'));
    expect(notes, contains('README'));
    expect(notes, contains('Runner.app'));

    File('${_scratchDir()}${Platform.pathSeparator}release_notes.md')
        .writeAsStringSync(notes);
  });

  test('iOS Podfile and project support CocoaPods build', () {
    expect(_repoFile('ios/Podfile').existsSync(), isTrue);
    expect(_repoFile('ios/Podfile.lock').existsSync(), isTrue);
    final pbx =
        _repoFile('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(pbx, contains('PRODUCT_BUNDLE_IDENTIFIER = perccent-wallet;'));
  });

  test('simulator Runner.app product is non-trivial when present', () {
    final app = _repoDir('build/ios/iphonesimulator/Runner.app');
    // Build is gitignored; when present after flutter build ios --simulator, size ≫ 4KB.
    if (!app.existsSync()) {
      // Still assert wiring that produces the product exists (CI without prior build).
      expect(_repoFile('ios/Podfile').existsSync(), isTrue);
      return;
    }

    var totalBytes = 0;
    for (final entity in app.listSync(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalBytes += entity.lengthSync();
      }
    }
    expect(totalBytes, greaterThan(4096 * 100),
        reason: 'Runner.app must be a real app, not a 4KB placeholder');

    final flutterFw = Directory(
      '${app.path}${Platform.pathSeparator}Frameworks${Platform.pathSeparator}Flutter.framework',
    );
    final appFw = Directory(
      '${app.path}${Platform.pathSeparator}Frameworks${Platform.pathSeparator}App.framework',
    );
    expect(flutterFw.existsSync(), isTrue);
    expect(appFw.existsSync(), isTrue);

    File('${_scratchDir()}${Platform.pathSeparator}runner_app_size.txt')
        .writeAsStringSync('totalBytes=$totalBytes\npath=${app.path}\n');
  });
}

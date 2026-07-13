import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/wallet_core/services/app_update_check.dart';

const _scratchDir =
    r'C:\Users\rgsne\AppData\Local\Temp\grok-goal-e6a4a8fb17ae\implementer';

Future<void> _ensureScratchDir() async {
  await Directory(_scratchDir).create(recursive: true);
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

void main() {
  test('iOS build scripts and signing docs exist', () {
    for (final path in [
      'scripts/build_ios_installer.ps1',
      'scripts/verify_ios_packaging.ps1',
      'scripts/ios_project_audit.ps1',
      'scripts/lib/ios_build.ps1',
      'scripts/deploy_downloads.ps1',
      'downloads/index.html',
      'ios/ExportOptions.plist',
      'ios/SIGNING.md',
    ]) {
      expect(_repoFile(path).existsSync(), isTrue, reason: path);
    }
  });

  test('iOS project audit: bundle ID, permissions, signing placeholders', () async {
    const expectedBundleId = 'com.perccent.perccentWallet';
    final pbxproj =
        _repoFile('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(pbxproj, contains('PRODUCT_BUNDLE_IDENTIFIER = $expectedBundleId;'));

    final infoPlist = _repoFile('ios/Runner/Info.plist').readAsStringSync();
    expect(infoPlist, contains('NSCameraUsageDescription'));
    expect(infoPlist, contains('NSFaceIDUsageDescription'));

    final signing = _repoFile('ios/SIGNING.md').readAsStringSync();
    expect(signing, contains(expectedBundleId));
    expect(signing, contains('DEVELOPMENT_TEAM'));

    final exportPlist = _repoFile('ios/ExportOptions.plist').readAsStringSync();
    expect(exportPlist, contains('<string>development</string>'));
    expect(exportPlist, contains('<string>automatic</string>'));

    await _ensureScratchDir();
    File('$_scratchDir${Platform.pathSeparator}ios_project_audit_perccent.log')
        .writeAsStringSync(
      'bundleId=$expectedBundleId\n'
      'permissions=NSCameraUsageDescription,NSFaceIDUsageDescription\n'
      'exportMethod=development\n'
      'signingStyle=automatic\n'
      'teamPlaceholder=DEVELOPMENT_TEAM in SIGNING.md\n',
    );
  });

  test('iOS update URLs point at perccent-wallet release IPA', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final urls = AppUpdateChecker.updateUrlsForRelease('1.1.4');
    expect(urls.first, contains('perccent-wallet-v1.1.4-ios-setup.ipa'));
    expect(
      urls.first,
      contains('github.com/rgsneddon/perccent-wallet/releases/download/v1.1.4'),
    );
    expect(urls.any((u) => u.contains('.ipa')), isTrue);
  });

  test('downloads index advertises iOS installer card', () {
    final pubspec = _repoFile('pubspec.yaml').readAsStringSync();
    final versionMatch =
        RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)').firstMatch(pubspec);
    expect(versionMatch, isNotNull);
    final release = versionMatch!.group(1)!;

    final html = _repoFile('downloads/index.html').readAsStringSync();
    expect(html, contains('<article class="card ios">'));
    expect(html, contains('perccent-wallet-v$release-ios-setup.ipa'));
    expect(
      html,
      contains(
        'github.com/rgsneddon/perccent-wallet/releases/download/v$release/perccent-wallet-v$release-ios-setup.ipa',
      ),
    );
  });

  test('deploy_downloads.ps1 includes ios-setup.ipa cleanup pattern', () {
    final script =
        _repoFile('scripts/deploy_downloads.ps1').readAsStringSync();
    expect(script, contains('*-ios-setup.ipa'));
  });

  test('packages staged IPA with checksum sidecars via -SkipIosBuild', () async {
    final pubspec = _repoFile('pubspec.yaml').readAsStringSync();
    final versionMatch =
        RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)').firstMatch(pubspec);
    expect(versionMatch, isNotNull);
    final release = versionMatch!.group(1)!;
    final publishedName = 'perccent-wallet-v$release-ios-setup.ipa';

    final installerIosDir = Directory(
      '${_repoRoot()}${Platform.pathSeparator}installer${Platform.pathSeparator}ios',
    );
    if (installerIosDir.existsSync()) {
      installerIosDir.deleteSync(recursive: true);
    }

    final ipaDir = Directory(
      '${_repoRoot()}${Platform.pathSeparator}build${Platform.pathSeparator}ios${Platform.pathSeparator}ipa',
    );
    ipaDir.createSync(recursive: true);
    final stagedIpa = File('${ipaDir.path}${Platform.pathSeparator}staged-flutter-output.ipa');
    stagedIpa.writeAsBytesSync(List<int>.filled(4096, 0x50));

    final versionDir = Directory(
      '${_repoRoot()}${Platform.pathSeparator}build${Platform.pathSeparator}downloads${Platform.pathSeparator}v$release',
    );
    final publishedPath = File('${versionDir.path}${Platform.pathSeparator}$publishedName');
    final checksumsPath = File('${versionDir.path}${Platform.pathSeparator}checksums.json');
    final metaJson = _repoFile('installer/ios/perccent-wallet-v$release-ios.json');

    final checksumsBackup =
        checksumsPath.existsSync() ? checksumsPath.readAsStringSync() : null;
    final pathsToClean = <String>[
      stagedIpa.path,
      publishedPath.path,
      '${publishedPath.path}.sha256',
      '${publishedPath.path}.sha512',
      metaJson.path,
    ];
    addTearDown(() {
      for (final path in pathsToClean) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
      if (checksumsBackup != null) {
        checksumsPath.writeAsStringSync(checksumsBackup);
      }
    });

    final script = _repoFile('scripts/build_ios_installer.ps1');
    final result = await Process.run(
      'powershell',
      ['-ExecutionPolicy', 'Bypass', '-File', script.path, '-SkipIosBuild'],
      runInShell: true,
      workingDirectory: _repoRoot(),
    );

    await _ensureScratchDir();
    final scratch = _scratchDir;
    final evidence = StringBuffer()
      ..writeln('deleted_installer_ios_before_run=true')
      ..writeln('exit=${result.exitCode}')
      ..writeln('stdout:')
      ..writeln(result.stdout)
      ..writeln('stderr:')
      ..writeln(result.stderr);
    File('$scratch${Platform.pathSeparator}perccent_ios_packaging_test.log')
        .writeAsStringSync(evidence.toString());

    expect(result.exitCode, 0, reason: '${result.stderr}\n${result.stdout}');
    expect(installerIosDir.existsSync(), isTrue, reason: 'installer/ios must be created');
    expect(publishedPath.existsSync(), isTrue, reason: publishedName);
    expect(File('${publishedPath.path}.sha256').existsSync(), isTrue);
    expect(File('${publishedPath.path}.sha512').existsSync(), isTrue);
    expect(metaJson.existsSync(), isTrue);

    expect(checksumsPath.existsSync(), isTrue);
    final manifest =
        jsonDecode(checksumsPath.readAsStringSync()) as Map<String, dynamic>;
    final packages = manifest['packages'] as List<dynamic>;
    final iosPkg = packages.cast<Map<String, dynamic>>().firstWhere(
      (p) => (p['file'] as String) == publishedName,
      orElse: () => throw StateError('checksums.json missing $publishedName'),
    );
    expect(iosPkg['sha256'], matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(iosPkg['sha512'], matches(RegExp(r'^[a-f0-9]{128}$')));

    final scratchArtifacts = Directory('$scratch${Platform.pathSeparator}perccent_ios_packaging_artifacts');
    if (scratchArtifacts.existsSync()) scratchArtifacts.deleteSync(recursive: true);
    scratchArtifacts.createSync(recursive: true);
    for (final path in [
      publishedPath.path,
      '${publishedPath.path}.sha256',
      '${publishedPath.path}.sha512',
      metaJson.path,
      checksumsPath.path,
    ]) {
      final src = File(path);
      if (src.existsSync()) {
        src.copySync('${scratchArtifacts.path}${Platform.pathSeparator}${src.uri.pathSegments.last}');
      }
    }
  });
}
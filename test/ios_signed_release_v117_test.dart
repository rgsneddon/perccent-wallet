import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
  test('pubspec and version.json are 1.1.8+13 with Apple platform fields', () {
    final pubspec = _repoFile('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: 1.1.8+13'));
    final vj = jsonDecode(_repoFile('version.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(vj['version'], '1.1.8');
    expect(vj['build_number'].toString(), '13');
    final platforms = vj['platforms'] as Map<String, dynamic>;
    final ios = platforms['ios'] as Map<String, dynamic>;
    final macos = platforms['macos'] as Map<String, dynamic>;
    expect(ios['version'], '1.1.7');
    expect(ios['build_number'].toString(), '12');
    expect(macos['version'], '1.1.8');
    expect(macos['build_number'].toString(), '13');
  });

  test('downloads page advertises real v1.1.7 iOS IPA with matching sha256', () {
    final html = _repoFile('downloads/index.html').readAsStringSync();
    expect(html, contains('v1.1.7'));
    expect(html, contains('perccent-wallet-v1.1.7-ios-setup.ipa'));
    expect(html, contains('<article class="card ios">'));

    final metaPath = _repoFile('installer/ios/perccent-wallet-v1.1.7-ios.json');
    expect(metaPath.existsSync(), isTrue);
    final meta = jsonDecode(metaPath.readAsStringSync()) as Map<String, dynamic>;
    final sha = meta['sha256'] as String;
    expect(sha, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(html, contains(sha));
    expect(meta['sizeBytes'] as int, greaterThan(4096 * 100));
    expect(meta['status'], 'signed_published');
    expect(meta['teamId'], 'SFCBP95595');
    expect(meta['bundleId'], 'perccent-wallet');
  });

  test('DEVELOPMENT_TEAM is set in iOS project', () {
    final pbx =
        _repoFile('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(pbx, contains('DEVELOPMENT_TEAM = SFCBP95595;'));
    final export = _repoFile('ios/ExportOptions.plist').readAsStringSync();
    expect(export, contains('SFCBP95595'));
  });

  test('RELEASE_NOTES cover signed iOS v1.1.7', () {
    final notes = _repoFile('RELEASE_NOTES.md').readAsStringSync();
    expect(notes, contains('v1.1.7'));
    expect(notes, contains('ios-setup.ipa'));
    final meta = jsonDecode(
      _repoFile('installer/ios/perccent-wallet-v1.1.7-ios.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(notes, contains(meta['sha256'] as String));
  });
}

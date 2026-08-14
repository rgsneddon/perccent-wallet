import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('version is 1.1.7 and macos installer metadata is real', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('version: 1.1.8+13'));
    final metaFile = File('installer/macos/perccent-wallet-v1.1.8-macos.json');
    expect(metaFile.existsSync(), isTrue);
    final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
    final sha = meta['sha256'] as String;
    expect(sha, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(meta['sizeBytes'] as int, greaterThan(4096 * 100));
    expect(meta['name'], 'perccent-wallet-v1.1.8-macos-setup.zip');
    expect(meta['platform'], 'macos');
    expect(meta['bundleId'], 'perccent-wallet');
  });

  test('downloads page lists macOS v1.1.7 card with matching sha256', () {
    final html = File('downloads/index.html').readAsStringSync();
    expect(html, contains('class="card macos"'));
    expect(html, contains('perccent-wallet-v1.1.8-macos-setup.zip'));
    final meta = jsonDecode(
      File('installer/macos/perccent-wallet-v1.1.8-macos.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(html, contains(meta['sha256'] as String));
    expect(html.toLowerCase(), contains('macos'));
  });

  test('README and RELEASE_NOTES document macOS v1.1.7', () {
    final readme = File('README.md').readAsStringSync();
    final notes = File('RELEASE_NOTES.md').readAsStringSync();
    expect(readme, contains('macos-setup.zip'));
    expect(readme, contains('macOS'));
    expect(readme, contains('v1.1.8'));
    expect(notes, contains('perccent-wallet-v1.1.8-macos-setup.zip'));
    final meta = jsonDecode(
      File('installer/macos/perccent-wallet-v1.1.8-macos.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(notes, contains(meta['sha256'] as String));
  });

  test('PRIVACY and LICENSE mention macOS as supported platform', () {
    final privacy = File('PRIVACY_POLICY.md').readAsStringSync();
    final license = File('LICENSE').readAsStringSync();
    expect(privacy, contains('macOS'));
    expect(privacy, contains('1.1.8'));
    expect(license, contains('macOS'));
    expect(File('assets/LICENSE').readAsStringSync(), license);
  });
}

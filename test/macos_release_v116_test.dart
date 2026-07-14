import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('version remains 1.1.6 and macos installer metadata is real', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('version: 1.1.6+11'));
    final metaFile = File('installer/macos/perccent-wallet-v1.1.6-macos.json');
    expect(metaFile.existsSync(), isTrue);
    final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
    final sha = meta['sha256'] as String;
    expect(sha, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(meta['sizeBytes'] as int, greaterThan(4096 * 100));
    expect(meta['name'], 'perccent-wallet-v1.1.6-macos-setup.zip');
    expect(meta['platform'], 'macos');
  });

  test('downloads page lists macOS v1.1.6 card with matching sha256', () {
    final html = File('downloads/index.html').readAsStringSync();
    expect(html, contains('class="card macos"'));
    expect(html, contains('perccent-wallet-v1.1.6-macos-setup.zip'));
    final meta = jsonDecode(
      File('installer/macos/perccent-wallet-v1.1.6-macos.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(html, contains(meta['sha256'] as String));
    expect(html.toLowerCase(), contains('macos'));
  });

  test('README and RELEASE_NOTES document macOS v1.1.6', () {
    final readme = File('README.md').readAsStringSync();
    final notes = File('RELEASE_NOTES.md').readAsStringSync();
    expect(readme, contains('macos-setup.zip'));
    expect(readme, contains('macOS'));
    expect(notes, contains('macos-setup.zip'));
    expect(notes, contains('5742d898a27a4a79b7346215c4cc22f63d00d3417a14c6b4e7dbff094fb99597'));
  });

  test('PRIVACY and LICENSE mention macOS as supported platform', () {
    final privacy = File('PRIVACY_POLICY.md').readAsStringSync();
    final license = File('LICENSE').readAsStringSync();
    expect(privacy, contains('macOS'));
    expect(privacy, contains('1.1.6'));
    expect(license, contains('macOS'));
    expect(File('assets/LICENSE').readAsStringSync(), license);
  });
}

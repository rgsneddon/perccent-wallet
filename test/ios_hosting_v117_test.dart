import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('version is 1.1.7 and downloads host real iOS IPA metadata', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: 1.1.8+13'));
    final html = File('downloads/index.html').readAsStringSync();
    expect(html, contains('v1.1.7'));
    expect(html, contains('perccent-wallet-v1.1.7-ios-setup.ipa'));
    final metaFile = File('installer/ios/perccent-wallet-v1.1.7-ios.json');
    expect(metaFile.existsSync(), isTrue);
    final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
    final sha = meta['sha256'] as String;
    expect(sha, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(html, contains(sha));
    expect(meta['sizeBytes'] as int, greaterThan(4096 * 100));
    expect(meta['bundleId'], 'perccent-wallet');
    expect(meta['teamId'], 'SFCBP95595');
  });

  test('README hosts MY PERC iOS on perccent-wallet not Evolve installer', () {
    final readme = File('README.md').readAsStringSync();
    expect(readme, contains('v1.1.7'));
    expect(readme, contains('perccent-wallet-v1.1.7-ios-setup.ipa'));
    expect(readme.toLowerCase(), contains('hosting'));
    expect(readme, contains('no separate Evolve Chronoflux iOS installer'));
  });

  test('LICENSE and assets/LICENSE match and mention iOS', () {
    final root = File('LICENSE').readAsStringSync();
    expect(File('assets/LICENSE').readAsStringSync(), root);
    expect(root, contains('MY PERC'));
    expect(root, contains('iOS'));
  });

  test('PRIVACY covers iOS biometrics and v1.1.7', () {
    final policy = File('PRIVACY_POLICY.md').readAsStringSync();
    expect(policy, contains('1.1.7'));
    expect(policy, contains('Android and iOS'));
    expect(policy, contains('Face ID'));
  });
}

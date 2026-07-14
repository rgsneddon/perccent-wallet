import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('version is 1.1.6 and downloads host real iOS IPA metadata', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: 1.1.6+11'));
    final html = File('downloads/index.html').readAsStringSync();
    expect(html, contains('v1.1.6'));
    expect(html, contains('perccent-wallet-v1.1.6-ios-setup.ipa'));
    expect(
      html,
      contains('1844aa2923a71ae51b7564ca978820c31537834b3789c144c0fa93b23dc241f5'),
    );
    final meta =
        File('installer/ios/perccent-wallet-v1.1.6-ios.json').readAsStringSync();
    expect(meta, contains('1844aa2923a71ae51b7564ca978820c31537834b3789c144c0fa93b23dc241f5'));
    expect(meta, contains('"sizeBytes": 8653370'));
  });

  test('README hosts MY PERC iOS on perccent-wallet not Evolve installer', () {
    final readme = File('README.md').readAsStringSync();
    expect(readme, contains('v1.1.6'));
    expect(readme, contains('perccent-wallet-v1.1.6-ios-setup.ipa'));
    expect(readme.toLowerCase(), contains('hosting'));
    expect(readme, contains('no separate Evolve Chronoflux iOS installer'));
  });

  test('LICENSE and assets/LICENSE match and mention iOS', () {
    final root = File('LICENSE').readAsStringSync();
    expect(File('assets/LICENSE').readAsStringSync(), root);
    expect(root, contains('MY PERC'));
    expect(root, contains('iOS'));
  });

  test('PRIVACY covers iOS biometrics and v1.1.6', () {
    final policy = File('PRIVACY_POLICY.md').readAsStringSync();
    expect(policy, contains('1.1.6'));
    expect(policy, contains('Android and iOS'));
    expect(policy, contains('Face ID'));
  });
}

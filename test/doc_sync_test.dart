import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _semverFromPubspec() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
      .firstMatch(pubspec);
  if (match == null) fail('pubspec.yaml missing version line');
  return match.group(1)!;
}

void main() {
  test('README version and wallet features match pubspec', () {
    final semver = _semverFromPubspec();
    final readme = File('README.md').readAsStringSync();
    expect(readme, contains('v$semver'));
    expect(readme, isNot(contains('v1.0.8')));
    expect(readme.toLowerCase(), contains('biometric'));
    expect(readme.toLowerCase(), contains('pull'));
    expect(readme.toLowerCase(), contains('hold-to-reveal'));
    expect(readme.toLowerCase(), contains('one main-chain confirmation'));
  });

  test('PRIVACY_POLICY discloses optional Android biometric vault', () {
    final policy = File('PRIVACY_POLICY.md').readAsStringSync().toLowerCase();
    expect(policy, contains('biometric'));
    expect(policy, anyOf(contains('secure storage'), contains('os-backed')));
    expect(policy, anyOf(contains('opt-in'), contains('opt in')));
    expect(policy, contains('v1.1.0'));
  });

  test('LICENSE copies match canonical repo root', () {
    final root = File('LICENSE').readAsStringSync();
    expect(File('assets/LICENSE').readAsStringSync(), root);
  });
}
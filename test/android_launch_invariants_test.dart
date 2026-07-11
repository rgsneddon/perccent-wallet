import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android launch_background drawables do not reference missing launch_image', () {
    for (final path in [
      'android/app/src/main/res/drawable/launch_background.xml',
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path must exist');
      final xml = file.readAsStringSync();
      expect(xml, isNot(contains('@mipmap/launch_image')),
          reason: '$path must not reference @mipmap/launch_image');
      expect(xml, isNot(contains('<bitmap')),
          reason: '$path must not inflate a bitmap splash (no launch_image asset)');
    }
  });

  test('AndroidManifest declares wallet network and scanner permissions', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    expect(manifest.existsSync(), isTrue);
    final xml = manifest.readAsStringSync();
    expect(xml, contains('android.permission.INTERNET'));
    expect(xml, contains('android.permission.CAMERA'));
    expect(xml, contains('android:label="MY PERC"'));
    expect(xml, contains('CallbackActivity'));
  });

  test('GeneratedPluginRegistrant includes native path_provider on Android', () {
    final registrant = File(
      'android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java',
    );
    expect(registrant.existsSync(), isTrue,
        reason: 'run flutter pub get / build apk to generate registrant');
    final java = registrant.readAsStringSync();
    expect(java, contains('PathProviderPlugin'),
        reason: 'wallet persistence requires path_provider_android native plugin');
    expect(java, isNot(contains('JniPlugin')),
        reason: 'pin path_provider_android 2.2.19 to avoid JNI cold-start path');
  });

  test('pubspec pins path_provider_android to 2.2.19', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('path_provider_android: 2.2.19'));
  });
}
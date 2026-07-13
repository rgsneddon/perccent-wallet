import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perccent_wallet/perc/providers/perc_wallet_provider.dart';
import 'package:perccent_wallet/perc/services/perc_wallet_store_memory.dart';
import 'package:perccent_wallet/screens/wallet_loading_screen.dart';
import 'package:perccent_wallet/standalone/my_perc_branding.dart';
import 'package:perccent_wallet/widgets/my_perc_logo.dart';

import 'test_locale_provider.dart';

/// Reads embedded frame widths from a Windows ICO directory table.
List<int> icoEmbeddedWidths(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(6), reason: '$path is not a valid ICO');
  final count = bytes[4] | (bytes[5] << 8);
  final widths = <int>[];
  for (var i = 0; i < count; i++) {
    final offset = 6 + i * 16;
    expect(
      offset + 1,
      lessThan(bytes.length),
      reason: '$path ICO directory entry $i is truncated',
    );
    final widthByte = bytes[offset];
    widths.add(widthByte == 0 ? 256 : widthByte);
  }
  return widths;
}

void main() {
  const iconPaths = <String>[
    'assets/branding/my_perc_logo.png',
    'web/favicon.png',
    'web/icons/Icon-192.png',
    'web/icons/Icon-512.png',
    'web/icons/Icon-maskable-192.png',
    'web/icons/Icon-maskable-512.png',
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    'windows/runner/resources/app_icon.ico',
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png',
  ];

  test('MY PERC % icon assets exist and are non-empty', () {
    for (final path in iconPaths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path must exist');
      expect(file.lengthSync(), greaterThan(0), reason: '$path must not be empty');
    }
    expect(MyPercLogo.assetPath, 'assets/branding/my_perc_logo.png');
  });

  test('Windows app_icon.ico embeds multiple launcher sizes', () {
    const icoPath = 'windows/runner/resources/app_icon.ico';
    final file = File(icoPath);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(1000), reason: 'ICO should bundle multiple frames');

    final widths = icoEmbeddedWidths(icoPath);
    expect(widths.length, greaterThan(1), reason: 'ICO must contain multiple embedded sizes');
    expect(widths.toSet(), containsAll([32, 256]));
    expect(widths, contains(16));
  });

  test('web metadata wires MY PERC favicon and manifest icons', () {
    final index = File('web/index.html').readAsStringSync();
    expect(index, contains('href="favicon.png"'));
    expect(index, contains('<title>MY PERC</title>'));
    expect(index, contains('apple-mobile-web-app-title" content="MY PERC"'));
    expect(index, contains('theme-color" content="#0F1A24"'));

    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync()) as Map<String, dynamic>;
    expect(manifest['name'], 'MY PERC');
    expect(manifest['short_name'], 'MY PERC');
    expect(manifest['background_color'], '#0F1A24');
    expect(manifest['theme_color'], '#0F1A24');

    final icons = manifest['icons'] as List<dynamic>;
    final srcs = icons.map((e) => (e as Map)['src'] as String).toSet();
    expect(srcs, containsAll([
      'icons/Icon-192.png',
      'icons/Icon-512.png',
      'icons/Icon-maskable-192.png',
      'icons/Icon-maskable-512.png',
    ]));
  });

  test('pubspec registers bundled MY PERC logo asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/branding/my_perc_logo.png'));
  });

  testWidgets('splash screen shows % logo above MY PERC product name', (tester) async {
    WalletLoadingScreen.introDurationOverride = Duration.zero;
    addTearDown(() => WalletLoadingScreen.introDurationOverride = null);

    final wallet = PercWalletProvider(store: PercWalletStoreMemory());
    await wallet.initialize();
    final locale = await createTestLocaleProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: wallet),
          ChangeNotifierProvider.value(value: locale),
        ],
        child: const MaterialApp(
          home: WalletLoadingScreen(walletReady: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('my_perc_splash_logo')), findsOneWidget);
    expect(find.byType(MyPercLogo), findsOneWidget);
    expect(find.text(MyPercBranding.productName), findsOneWidget);

    final logoFinder = find.byType(MyPercLogo);
    final productFinder = find.text(MyPercBranding.productName);
    final logoY = tester.getTopLeft(logoFinder).dy;
    final productY = tester.getTopLeft(productFinder).dy;
    expect(logoY, lessThan(productY));
  });
}
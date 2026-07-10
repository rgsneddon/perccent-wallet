import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/l10n/app_localizations.dart';
import 'package:perccent_wallet/l10n/wallet_only_localizations.dart';
import 'package:perccent_wallet/standalone/my_perc_branding.dart';
import 'package:perccent_wallet/wallet_core/models/locale_config.dart';
import 'package:perccent_wallet/wallet_core/services/app_update_check.dart';
import 'package:perccent_wallet/widgets/wallet_splash_poster.dart';

void main() {
  final strings = walletLocalizationsOf(LocaleConfig.defaults);

  test('MY PERC branding strings exclude Evolve Wallet sign-in copy', () {
    expect(strings.t('wallet_app_title'), 'MY PERC');
    expect(strings.t('wallet_title'), 'MY PERC');
    expect(strings.t('wallet_login_title'), 'MY PERC sign-in');
    expect(strings.t('splash_enter_app'), 'Enter MY PERC');
    expect(strings.t('splash_tagline'), isNot(contains('Full Community Governance Suite')));

    final loginTitle = strings.t('wallet_login_title').toLowerCase();
    expect(loginTitle, isNot(contains('evolve wallet')));
    expect(strings.t('splash_enter_app').toLowerCase(), isNot(contains('enter evolve')));
  });

  test('AppUpdateChecker resolves perccent-wallet installers not evolve-v', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(AppUpdateChecker.pagesVersionUrl, contains('perccent-wallet'));
    expect(AppUpdateChecker.sourceVersionUrl, contains('perccent-wallet'));
    expect(AppUpdateChecker.downloadsBaseUrl, contains('perccent-wallet'));

    final urls = AppUpdateChecker.updateUrlsForRelease('1.0.6');
    expect(urls, isNotEmpty);
    expect(urls.first, contains('perccent-wallet-v1.0.6-windows-x64-setup.exe'));
    expect(urls.join('|'), isNot(contains('evolve-v')));
    expect(urls.join('|'), isNot(contains('rgsneddon.github.io/evolve/downloads')));
  });

  test('AppUpdateChecker android URLs use perccent-wallet apk naming', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final urls = AppUpdateChecker.updateUrlsForRelease('2.1.0');
    expect(urls.first, contains('perccent-wallet-v2.1.0-android-setup.apk'));
    expect(urls.join('|'), isNot(contains('evolve-v')));
  });

  test('wallet screen build path does not include Analysis faucet card', () {
    final src = File('lib/perc/screens/wallet_screen.dart').readAsStringSync();
    expect(src.contains('_faucetCard(wallet'), isFalse);
    expect(src.contains("strings.t('wallet_faucet_title')"), isFalse);
  });

  test('Credit & Governance copy recommends Evolve Full Community Governance Suite', () {
    expect(
      strings.t('credit_governance_intro'),
      contains('MY PERC'),
    );
    expect(
      strings.t('credit_governance_link_label'),
      'Evolve Full Community Governance Suite',
    );
    expect(
      strings.t('credit_governance_link_suffix'),
      contains('percent-chance'),
    );
    expect(
      strings.t('credit_parish_note'),
      contains('encrypted backups'),
    );
    expect(strings.t('credit_attribution_title'), 'Attribution');
    expect(
      strings.t('credit_attribution_body'),
      contains('RUSSELL G SNEDDON'),
    );
  });

  test('WalletSplashPoster uses solid MY PERC background without banner asset', () {
    final src = File('lib/widgets/wallet_splash_poster.dart').readAsStringSync();
    expect(src.contains('evolve.jpg'), isFalse);
    expect(src.contains('Image.asset'), isFalse);
    expect(src.contains('MyPercBranding.splashBackground'), isTrue);
    expect(MyPercBranding.splashBackground, const Color(0xFF0F1A24));
    expect(const WalletSplashPoster(), isA<WalletSplashPoster>());
  });

  test('upgrade advisory strings wire Evolve Suite and MY PERC installer links', () {
    expect(strings.t('my_perc_upgrade_evolve_link'), 'Full Evolve Suite');
    expect(strings.t('my_perc_upgrade_wallet_link'), 'MY PERC installer');
    expect(MyPercBranding.fullEvolveSuiteUrl, contains('evolve'));
    expect(MyPercBranding.installerPrefix, 'perccent-wallet');
  });
}
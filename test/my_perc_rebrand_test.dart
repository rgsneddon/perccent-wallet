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
    expect(src.contains("strings.t('wallet_scenario_block_height')"), isFalse);
    expect(src.contains("strings.t('wallet_scenario_block_capped')"), isFalse);
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
    final splashSrc =
        File('lib/screens/wallet_loading_screen.dart').readAsStringSync();
    expect(src.contains('evolve.jpg'), isFalse);
    expect(src.contains('Image.asset'), isFalse);
    expect(src.contains('MyPercBranding.splashBackground'), isTrue);
    expect(splashSrc, contains('MyPercLogo'));
    expect(MyPercBranding.splashBackground, const Color(0xFF0F1A24));
    expect(const WalletSplashPoster(), isA<WalletSplashPoster>());
  });

  test('wallet empty and treasury notices exclude analysis scenario prompts', () {
    const blocked = [
      'Analysis',
      'analysis',
      'run a scenario',
      'run analysis',
      'run another scenario',
      'percent-chance',
      'social-cohesion',
      'social cohesion',
      'Análisis',
      'escenario',
      'scenario',
      'faucet',
      'grifo',
      'scénario',
      'Szenario',
    ];

    void expectNeutral(String key) {
      final value = strings.t(key);
      for (final phrase in blocked) {
        expect(
          value.toLowerCase(),
          isNot(contains(phrase.toLowerCase())),
          reason: '$key must not mention "$phrase" — got: $value',
        );
      }
      expect(value.trim(), isNotEmpty, reason: '$key must not be empty');
    }

    final walletScreenSrc =
        File('lib/perc/screens/wallet_screen.dart').readAsStringSync();
    final walletScreenKeys = RegExp(r"strings\.t\('(wallet_[^']+)'\)")
        .allMatches(walletScreenSrc)
        .map((m) => m.group(1)!)
        .toSet()
        .toList()
      ..sort();

    expect(walletScreenKeys, isNotEmpty);

    const extraStatusKeys = [
      'wallet_status_treasury_empty',
      'wallet_status_treasury_cap',
      'wallet_status_faucet_credited',
    ];

    for (final key in {...walletScreenKeys, ...extraStatusKeys}) {
      expectNeutral(key);
    }

    expect(
      strings.t('wallet_transactions_empty'),
      contains('Send or receive PERC'),
    );
    expect(
      strings.t('wallet_blockchain_awaiting_launch'),
      contains('sync completes'),
    );
    expect(
      strings.t('wallet_session_expired'),
      contains('sign in again'),
    );
    expect(
      strings.t('wallet_treasury_note'),
      contains('network block pace'),
    );
    expect(
      strings.t('wallet_status_treasury_empty'),
      contains('sync your wallet'),
    );
    expect(
      strings.t('wallet_treasury_inflation_critical'),
      contains('network activity'),
    );
  });

  test('upgrade advisory strings wire Evolve Suite and MY PERC installer links', () {
    expect(strings.t('my_perc_upgrade_evolve_link'), 'Full Evolve Suite');
    expect(strings.t('my_perc_upgrade_wallet_link'), 'MY PERC installer');
    expect(MyPercBranding.fullEvolveSuiteUrl, contains('evolve'));
    expect(MyPercBranding.installerPrefix, 'perccent-wallet');
  });
}
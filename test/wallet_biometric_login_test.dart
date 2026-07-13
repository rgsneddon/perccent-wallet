import 'dart:io';

import 'package:perccent_wallet/perc/providers/perc_wallet_provider.dart';
import 'package:perccent_wallet/perc/services/perc_ledger_hub.dart';
import 'package:perccent_wallet/perc/services/wallet_biometric_credential_store.dart';
import 'package:perccent_wallet/perc/services/perc_wallet_store_memory.dart';
import 'package:perccent_wallet/perc/widgets/registration_seed_setup_dialog.dart';
import 'package:perccent_wallet/perc/widgets/wallet_auth_panel.dart';
import 'package:perccent_wallet/perc/widgets/wallet_biometric_auth_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'test_locale_provider.dart';

void main() {
  setUp(() {
    PercLedgerHub.resetForTest();
    PercWalletProvider.sessionTimeoutEnabled = false;
  });

  tearDown(() {
    PercWalletProvider.sessionTimeoutEnabled = true;
    WalletBiometricAuthUi.storeOverride = null;
    WalletBiometricAuthUi.biometricPlatformOverrideForTest = null;
    PercLedgerHub.resetForTest();
  });

  WalletBiometricCredentialStore testStore({
    Map<String, String>? memory,
    Future<bool> Function(String reason)? authenticate,
    bool platform = true,
  }) {
    return WalletBiometricCredentialStore(
      biometricPlatformOverride: platform,
      memoryStorage: memory ?? <String, String>{},
      authenticateOverride: authenticate ?? (_) async => true,
      availabilityOverride: () async => true,
    );
  }

  test('MainActivity extends FlutterFragmentActivity for local_auth', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/perccent/perccent_wallet/MainActivity.kt',
    ).readAsStringSync();
    expect(mainActivity, contains('FlutterFragmentActivity'));
    expect(mainActivity, isNot(contains('FlutterActivity()')));
  });

  test('iOS Info.plist declares Face ID usage for biometric vault', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('NSFaceIDUsageDescription'));
    expect(plist.toLowerCase(), contains('face id'));
  });

  test('biometric vault is gated to Android and iOS (not web)', () {
    final authUi =
        File('lib/perc/widgets/wallet_biometric_auth_ui.dart').readAsStringSync();
    final store = File(
      'lib/perc/services/wallet_biometric_credential_store.dart',
    ).readAsStringSync();
    final panel =
        File('lib/perc/widgets/wallet_auth_panel.dart').readAsStringSync();
    final seedDialog = File(
      'lib/perc/widgets/registration_seed_setup_dialog.dart',
    ).readAsStringSync();

    expect(authUi, contains('TargetPlatform.android'));
    expect(authUi, contains('TargetPlatform.iOS'));
    expect(store, contains('TargetPlatform.iOS'));
    expect(store, contains('IOSOptions'));
    expect(store, contains('KeychainAccessibility.first_unlock_this_device'));
    expect(authUi, contains('offerEnrollmentIfNeeded'));
    expect(panel, contains('WalletBiometricAuthUi.showBiometricSignIn'));
    expect(panel, contains('offerEnrollmentIfNeeded'));
    expect(seedDialog, contains('offerEnrollmentIfNeeded'));
  });

  test('credential store rejects non-mobile platforms', () async {
    final store = testStore(platform: false);
    expect(store.isBiometricPlatform, isFalse);
    expect(await store.isBiometricAvailableOnDevice(), isFalse);
    expect(
      await store.saveCredentials(username: 'a', password: 'b'),
      isFalse,
    );
    expect(await store.hasStoredCredentials(), isFalse);
  });

  test('iOS platform override enrolls, unlocks, and fails closed', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final store = WalletBiometricCredentialStore(
      biometricPlatformOverride: true,
      memoryStorage: <String, String>{},
      authenticateOverride: (_) async => true,
      availabilityOverride: () async => true,
    );
    expect(store.isBiometricPlatform, isTrue);
    expect(await store.saveCredentials(username: 'alice', password: 'secret'),
        isTrue);
    expect(await store.hasStoredCredentials(), isTrue);
    final ok = await store.unlockWithBiometric(localizedReason: 'Face ID');
    expect(ok?.username, 'alice');
    expect(ok?.password, 'secret');

    final failStore = WalletBiometricCredentialStore(
      biometricPlatformOverride: true,
      memoryStorage: <String, String>{
        'wallet_biometric_enabled': 'true',
        'wallet_biometric_credentials':
            '{"username":"alice","password":"secret"}',
      },
      authenticateOverride: (_) async => false,
      availabilityOverride: () async => true,
    );
    expect(
      await failStore.unlockWithBiometric(localizedReason: 'Face ID'),
      isNull,
    );
  });

  testWidgets(
    'registration seed enrollment refreshes auth panel biometric button',
    (tester) async {
      WalletBiometricAuthUi.biometricPlatformOverrideForTest = true;

      final store = testStore();
      WalletBiometricAuthUi.storeOverride = store;
      PercWalletProvider.sessionTimeoutEnabled = true;

      final wallet = PercWalletProvider(store: PercWalletStoreMemory());
      await wallet.initialize();
      await wallet.setupTreasuryPassword('password12345');
      await wallet.register('alice', 'password12345');
      expect(wallet.pendingSeedSetup, isTrue);

      final locale = await createTestLocaleProvider();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: wallet),
            ChangeNotifierProvider.value(value: locale),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RegistrationSeedSetupDialogHost(
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('registration_seed_skip_button')),
      );
      await tester.tap(find.byKey(const Key('registration_seed_skip_button')));
      await tester.pumpAndSettle();

      expect(find.text('Enable biometric sign-in?'), findsOneWidget);
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      expect(wallet.isLoggedIn, isTrue);
      expect(await store.hasStoredCredentials(), isTrue);

      await wallet.logout();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: wallet),
            ChangeNotifierProvider.value(value: locale),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WalletAuthPanel(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in with biometrics'), findsOneWidget);
    },
  );

  test('registration session can enroll biometric via real credential store',
      () async {
    WalletBiometricAuthUi.biometricPlatformOverrideForTest = true;
    final store = testStore();

    final wallet = PercWalletProvider(store: PercWalletStoreMemory());
    await wallet.initialize();
    await wallet.setupTreasuryPassword('password12345');
    await wallet.register('alice', 'password12345');
    await wallet.completeRegistrationSeedSetup(enableSeed: false);

    expect(wallet.isLoggedIn, isTrue);
    await store.saveCredentials(username: 'alice', password: 'password12345');
    expect(await store.hasStoredCredentials(), isTrue);
    expect(
      WalletBiometricAuthUi.showBiometricSignIn(
        loginMode: true,
        hasStoredCredentials: await store.hasStoredCredentials(),
      ),
      isTrue,
    );
  });

  test('showBiometricSignIn true on iOS override with stored creds', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    WalletBiometricAuthUi.biometricPlatformOverrideForTest = true;
    expect(
      WalletBiometricAuthUi.showBiometricSignIn(
        loginMode: true,
        hasStoredCredentials: true,
      ),
      isTrue,
    );
    expect(
      WalletBiometricAuthUi.showBiometricSignIn(
        loginMode: false,
        hasStoredCredentials: true,
      ),
      isFalse,
    );
  });

  test('unlockWithBiometric reads stored credentials after auth', () async {
    final store = testStore();
    await store.saveCredentials(username: 'alice', password: 'password12345');
    final creds = await store.unlockWithBiometric(
      localizedReason: 'Authenticate to sign in',
    );
    expect(creds?.username, 'alice');
    expect(creds?.password, 'password12345');
  });

  test('stored credentials plus biometric auth complete login', () async {
    final store = testStore();
    await store.saveCredentials(username: 'alice', password: 'password12345');

    final wallet = PercWalletProvider(store: PercWalletStoreMemory());
    await wallet.initialize();
    await wallet.setupTreasuryPassword('password12345');
    await wallet.register('alice', 'password12345');
    await wallet.logout();

    final creds = await store.unlockWithBiometric(
      localizedReason: 'Authenticate to sign in',
    );
    expect(creds, isNotNull);

    await wallet.login(creds!.username, creds.password);
    expect(wallet.isLoggedIn, isTrue);
    expect(wallet.errorMessage, isNull);
  });

  test('biometric auth failure leaves manual login path intact', () async {
    final store = testStore(authenticate: (_) async => false);
    await store.saveCredentials(username: 'alice', password: 'password12345');

    final creds = await store.unlockWithBiometric(
      localizedReason: 'Authenticate to sign in',
    );
    expect(creds, isNull);
  });
}

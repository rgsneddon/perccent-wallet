import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/perc/providers/perc_wallet_provider.dart';
import 'package:perccent_wallet/perc/services/perc_ledger_hub.dart';
import 'package:perccent_wallet/perc/services/wallet_biometric_credential_store.dart';
import 'package:perccent_wallet/perc/services/perc_wallet_store_memory.dart';

void main() {
  setUp(() {
    PercLedgerHub.resetForTest();
    PercWalletProvider.sessionTimeoutEnabled = false;
  });

  tearDown(() {
    PercWalletProvider.sessionTimeoutEnabled = true;
    PercLedgerHub.resetForTest();
  });

  test('credential store saves and unlocks on Android with biometric gate',
      () async {
    final memory = <String, String>{};
    final store = WalletBiometricCredentialStore(
      androidPlatformOverride: true,
      availabilityOverride: () async => true,
      authenticateOverride: (_) async => true,
      memoryStorage: memory,
    );

    expect(await store.saveCredentials(
      username: 'alice',
      password: 'password12345',
    ), isTrue);
    expect(await store.hasStoredCredentials(), isTrue);
    expect(await store.storedUsername(), 'alice');

    final creds = await store.unlockWithBiometric(
      localizedReason: 'test',
    );
    expect(creds?.username, 'alice');
    expect(creds?.password, 'password12345');
  });

  test('mocked biometric unlock completes wallet login without error', () async {
    final memory = <String, String>{};
    final store = WalletBiometricCredentialStore(
      androidPlatformOverride: true,
      availabilityOverride: () async => true,
      authenticateOverride: (_) async => true,
      memoryStorage: memory,
    );
    await store.saveCredentials(username: 'alice', password: 'password12345');

    final wallet = PercWalletProvider(store: PercWalletStoreMemory());
    await wallet.initialize();
    await wallet.setupTreasuryPassword('password12345');
    await wallet.register('alice', 'password12345');
    await wallet.logout();

    final creds = await store.unlockWithBiometric(localizedReason: 'test');
    expect(creds, isNotNull);
    await wallet.login(creds!.username, creds.password);

    expect(wallet.isLoggedIn, isTrue);
    expect(wallet.errorMessage, isNull);
  });

  test('biometric sign-in affordance gated to Android login with stored creds',
      () {
    final authUi =
        File('lib/perc/widgets/wallet_biometric_auth_ui.dart').readAsStringSync();
    final panel =
        File('lib/perc/widgets/wallet_auth_panel.dart').readAsStringSync();
    expect(authUi, contains('TargetPlatform.android'));
    expect(authUi, contains('Icons.fingerprint'));
    expect(panel, contains('WalletBiometricAuthUi.showBiometricSignIn'));
    expect(panel, contains('offerEnrollmentAfterLogin'));
  });
}
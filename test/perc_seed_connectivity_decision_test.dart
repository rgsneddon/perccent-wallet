import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:perccent_wallet/perc/perc_chain_constants.dart';
import 'package:perccent_wallet/perc/providers/perc_wallet_provider.dart';
import 'package:perccent_wallet/perc/services/perc_ledger_hub.dart';
import 'package:perccent_wallet/perc/services/perc_network_client.dart';
import 'package:perccent_wallet/perc/services/perc_network_config.dart';
import 'package:perccent_wallet/perc/services/perc_network_coordinator.dart';
import 'package:perccent_wallet/perc/services/perc_network_protocol.dart';
import 'package:perccent_wallet/perc/services/perc_network_rendezvous.dart';
import 'package:perccent_wallet/perc/services/perc_wallet_store_memory.dart';

const _seedBase = 'https://test-seed.example';

Map<String, dynamic> _statusJson({int height = 12}) => {
      'evolutionaryChainId': PercChainConstants.evolutionaryChainId,
      'blockHeight': height,
      'tipHash': 'tip-$height',
      'revision': 3,
      'networkGenesisRevision': 2,
      'endpoint': _seedBase,
      'sessionUsername': PercChainConstants.seedUsername,
    };

MockClient _statusClient({
  required int Function() statusHandler,
  int statusCode = 200,
  Map<String, dynamic>? body,
}) {
  return MockClient((request) async {
    if (request.method == 'GET' && request.url.path.endsWith('/perc/status')) {
      final code = statusHandler();
      if (code != 200) {
        return http.Response('offline', code);
      }
      return http.Response(
        jsonEncode(body ?? _statusJson()),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.method == 'GET' && request.url.path.endsWith('/perc/ledger')) {
      return http.Response('not found', 404);
    }
    // Rendezvous side effects during force sync — ignore quietly.
    return http.Response('{}', 200);
  });
}

void _installLiveSeedMocks(http.Client httpClient) {
  PercNetworkConfig.setCachedForTest(
    const PercNetworkConfig(
      rendezvousUrl: _seedBase,
      seedUsername: PercChainConstants.seedUsername,
      networkGenesisRevision: 2,
    ),
  );
  PercNetworkCoordinator.disableLiveNodesForTests = false;
  PercNetworkCoordinator.instance.installNetworkClientForTest(
    PercNetworkClient(client: httpClient),
  );
  PercNetworkCoordinator.instance.installRendezvousForTest(
    PercNetworkRendezvous(client: httpClient),
  );
}

Future<PercWalletProvider> _bootWalletWithSeedHttp({
  required http.Client httpClient,
}) async {
  _installLiveSeedMocks(httpClient);

  final store = PercWalletStoreMemory();
  final wallet = PercWalletProvider(store: store);
  await wallet.initialize();
  await wallet.setupTreasuryPassword('password12345');
  await wallet.register('seeduser', 'password12345');
  await wallet.login('seeduser', 'password12345');
  return wallet;
}

void main() {
  setUp(() {
    PercLedgerHub.resetForTest();
    PercNetworkConfig.resetForTest();
    PercWalletProvider.sessionTimeoutEnabled = false;
    PercNetworkCoordinator.disableLiveNodesForTests = true;
  });

  tearDown(() {
    PercNetworkCoordinator.disableLiveNodesForTests = true;
    PercWalletProvider.sessionTimeoutEnabled = true;
    PercNetworkConfig.resetForTest();
    PercLedgerHub.resetForTest();
  });

  test('PercNetworkClient.fetchStatus returns status on HTTP 200', () async {
    final client = PercNetworkClient(
      client: _statusClient(statusHandler: () => 200),
    );
    final status = await client.fetchStatus(_seedBase);
    expect(status, isNotNull);
    expect(status!.blockHeight, 12);
    expect(status.evolutionaryChainId, PercChainConstants.evolutionaryChainId);
  });

  test('PercNetworkClient.fetchStatus returns null when host never answers 200',
      () async {
    final client = PercNetworkClient(
      client: _statusClient(statusHandler: () => 503),
    );
    final status = await client.fetchStatus(_seedBase);
    expect(status, isNull);
  });

  test(
    'syncWalletToSeed does not report offline when status probe succeeds',
    () async {
      var probes = 0;
      final wallet = await _bootWalletWithSeedHttp(
        httpClient: _statusClient(
          statusHandler: () {
            probes++;
            return 200;
          },
        ),
      );

      await wallet.syncWalletToSeed();

      expect(probes, greaterThan(0));
      expect(wallet.errorMessage, isNot('wallet_sync_seed_offline'));
      expect(PercLedgerHub.instance.network.isConnectedToSeed, isTrue);
      expect(
        wallet.statusMessage == 'wallet_sync_success' ||
            wallet.statusMessage == 'wallet_sync_partial',
        isTrue,
        reason:
            'status=${wallet.statusMessage} error=${wallet.errorMessage}',
      );
    },
  );

  test(
    'syncWalletToSeed reports offline when every status probe fails',
    () async {
      final wallet = await _bootWalletWithSeedHttp(
        httpClient: _statusClient(statusHandler: () => 503),
      );

      // Ensure we start from disconnected for an honest offline outcome.
      PercNetworkCoordinator.instance.setSeedConnectedForTest(false);
      await wallet.syncWalletToSeed();

      expect(wallet.errorMessage, 'wallet_sync_seed_offline');
      expect(PercLedgerHub.instance.network.isConnectedToSeed, isFalse);
    },
  );

  test(
    'forceSync keeps seed connected when a later status probe fails after success',
    () async {
      var probes = 0;
      final httpClient = _statusClient(
        statusHandler: () {
          probes++;
          // First probe OK (forceSync connect); later probes fail (deepSync re-probe).
          return probes == 1 ? 200 : 503;
        },
      );
      _installLiveSeedMocks(httpClient);

      final store = PercWalletStoreMemory();
      final wallet = PercWalletProvider(store: store);
      await wallet.initialize();
      await wallet.setupTreasuryPassword('password12345');
      // Register/login with live nodes disabled so only forceSync exercises probes.
      PercNetworkCoordinator.disableLiveNodesForTests = true;
      await wallet.register('stickyuser', 'password12345');
      await wallet.login('stickyuser', 'password12345');
      PercNetworkCoordinator.disableLiveNodesForTests = false;
      _installLiveSeedMocks(httpClient);
      probes = 0;

      await PercLedgerHub.instance.network.forceSyncWalletToSeed();

      expect(probes, greaterThan(1));
      expect(PercLedgerHub.instance.network.isConnectedToSeed, isTrue);
      expect(wallet.errorMessage, isNot('wallet_sync_seed_offline'));
    },
  );

  test('PercNetworkStatus.fromJson accepts numeric fields as num', () {
    final status = PercNetworkStatus.fromJson({
      'evolutionaryChainId': PercChainConstants.evolutionaryChainId,
      'blockHeight': 96.0,
      'tipHash': 'abc',
      'revision': 111.0,
      'networkGenesisRevision': 2.0,
    });
    expect(status.blockHeight, 96);
    expect(status.revision, 111);
    expect(status.networkGenesisRevision, 2);
  });
}

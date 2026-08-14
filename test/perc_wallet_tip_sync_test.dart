import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/perc/models/perc_amount.dart';
import 'package:perccent_wallet/perc/models/perc_block.dart';
import 'package:perccent_wallet/perc/perc_chain_constants.dart';
import 'package:perccent_wallet/perc/services/perc_chain_tip.dart';
import 'package:perccent_wallet/perc/services/perc_ledger.dart';
import 'package:perccent_wallet/perc/services/perc_ledger_hub.dart';
import 'package:perccent_wallet/perc/services/perc_network_config.dart';
import 'package:perccent_wallet/perc/services/perc_network_coordinator.dart';
import 'package:perccent_wallet/perc/services/perc_network_protocol.dart';
import 'package:perccent_wallet/perc/services/perc_wallet_store_memory.dart';

PercLedger _ledgerWithBlocks(int count, {String label = 'tip'}) {
  final ledger = PercLedger.empty();
  ledger.ensureTreasuryAccount();
  ledger.setupTreasuryPassword('password12345');
  ledger.launchBlockchain();
  ledger.consumeBlockchainLaunchEvent();
  while (ledger.blocks.length < count) {
    ledger.blocks.add(
      PercBlock(
        index: ledger.blocks.length,
        timestamp: DateTime.utc(2026, 1, 1, 0, ledger.blocks.length),
        transactions: const [],
        treasuryEmitted: PercAmount.zero,
        scenarioLabel: '$label ${ledger.blocks.length}',
      ),
    );
  }
  return ledger;
}

void main() {
  setUp(() {
    PercNetworkConfig.resetForTest();
    PercLedgerHub.resetForTest();
  });

  test('PercChainTip.tallest matches explorer/pool tip unit (blocks.length)', () {
    final seed = _ledgerWithBlocks(7);
    final local = _ledgerWithBlocks(3);
    expect(PercChainTip.height(seed), seed.blocks.length);
    expect(
      PercChainTip.tallest(
        localHeight: PercChainTip.height(local),
        seedHeight: PercChainTip.height(seed),
      ),
      PercChainTip.height(seed),
    );
  });

  test('adoptTallerTip lifts a shorter local ledger to the reachable seed tip',
      () {
    final local = _ledgerWithBlocks(4, label: 'local');
    final seed = _ledgerWithBlocks(9, label: 'seed');
    final after = PercChainTip.adoptTallerTip(
      local,
      seed,
      expectedTipHash: PercChainTip.hash(seed),
    );
    expect(after, PercChainTip.height(seed));
    expect(PercChainTip.height(local), PercChainTip.height(seed));
  });

  test('macOS Release entitlements allow outbound seed/explorer HTTP', () {
    final ents = File('macos/Runner/Release.entitlements').readAsStringSync();
    expect(ents, contains('com.apple.security.app-sandbox'));
    expect(ents, contains('com.apple.security.network.client'));
  });

  test('adoptTallerTip lifts a real shorter local ledger to a live seed export',
      () async {
    final localPath = Platform.environment['PERC_LOCAL_LEDGER'] ??
        '${Platform.environment['HOME']}/Library/Containers/perccent-wallet/'
            'Data/Library/Application Support/perccent-wallet/'
            'perc_evolve-chronoflux-principia-chain-1_ledger.json';
    final localFile = File(localPath);
    PercLedger local;
    if (localFile.existsSync()) {
      local = PercLedger.fromJson(
        jsonDecode(localFile.readAsStringSync()) as Map<String, dynamic>,
      );
    } else {
      local = _ledgerWithBlocks(4, label: 'fixture-short');
    }
    final client = HttpClient();
    late PercLedger seed;
    const urls = [
      'https://evolve.restoreprivacy.online/perc/ledger',
      'https://135.181.152.10.sslip.io/perc/ledger',
    ];
    try {
      Object? lastErr;
      HttpClientResponse? res;
      String? body;
      for (final url in urls) {
        try {
          final req = await client.getUrl(Uri.parse(url));
          final attempt =
              await req.close().timeout(const Duration(seconds: 30));
          if (attempt.statusCode == 200) {
            res = attempt;
            body = await attempt.transform(utf8.decoder).join();
            break;
          }
          lastErr = 'GET $url -> ${attempt.statusCode}';
        } catch (e) {
          lastErr = e;
        }
      }
      expect(res?.statusCode, 200, reason: '$lastErr');
      seed = PercLedger.fromJson(jsonDecode(body!) as Map<String, dynamic>);
    } finally {
      client.close(force: true);
    }
    final seedH = PercChainTip.height(seed);
    expect(seedH, seed.blocks.length);
    expect(seedH, greaterThan(0));
    if (PercChainTip.height(local) >= seedH) {
      return;
    }
    final after = PercChainTip.adoptTallerTip(
      local,
      seed,
      expectedTipHash: PercChainTip.hash(seed),
    );
    expect(after, seedH);
    expect(PercChainTip.height(local), seedH);
    final out = Platform.environment['PERC_ADOPT_OUT'];
    if (out != null && out.isNotEmpty) {
      File(out).writeAsStringSync(jsonEncode(local.toJson()));
    }
  });

  test('forceSync + syncToNetworkHeight adopt test seed when local is behind',
      () async {
    final store = PercWalletStoreMemory();
    await PercLedgerHub.instance.initialize(store);
    final hub = PercLedgerHub.instance;
    final network = hub.network;

    final short = _ledgerWithBlocks(5, label: 'wallet');
    hub.importPeerLedger(short, force: true);
    final localBefore = PercChainTip.height(hub.ledger);

    final seed = _ledgerWithBlocks(localBefore + 5, label: 'network');
    final tip = PercChainTip.height(seed);
    expect(localBefore, lessThan(tip));

    network.registerTestSeedLedger(seed);
    await network.forceSyncWalletToSeed();

    expect(PercChainTip.height(hub.ledger), tip);
    expect(network.networkBlockHeight, tip);
    expect(network.syncState, PercNetworkSyncState.synced);
  });
}

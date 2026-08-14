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

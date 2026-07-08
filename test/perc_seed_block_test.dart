import 'package:flutter_test/flutter_test.dart';
import 'package:perccent_wallet/perc/models/perc_amount.dart';
import 'package:perccent_wallet/perc/perc_chain_constants.dart';
import 'package:perccent_wallet/perc/services/perc_seed_block.dart';

void main() {
  test('seed anchor stays at block 1 below 100M PERC emission', () {
    expect(
      PercSeedBlock.fromTreasuryMinted(PercAmount.zero),
      1,
    );
    expect(
      PercSeedBlock.fromTreasuryMinted(
        PercAmount.fromPerc(
          (PercChainConstants.percPerSeedBlock - 1).toDouble(),
        ),
      ),
      1,
    );
  });

  test('seed anchor advances at each 100M PERC emission threshold', () {
    final perBlock = PercChainConstants.percPerSeedBlock.toDouble();
    expect(
      PercSeedBlock.fromTreasuryMinted(PercAmount.fromPerc(perBlock)),
      2,
    );
    expect(
      PercSeedBlock.fromTreasuryMinted(PercAmount.fromPerc(perBlock * 2)),
      3,
    );
    expect(
      PercSeedBlock.fromTreasuryMinted(PercAmount.fromPerc(perBlock * 2 + 1)),
      3,
    );
  });
}
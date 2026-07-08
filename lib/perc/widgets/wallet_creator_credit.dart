import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../wallet_core/widgets/wallet_attribution.dart';

/// Creator credit shown on all wallet surfaces.
class WalletCreatorCredit extends StatelessWidget {
  const WalletCreatorCredit({super.key, required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: WalletAttribution(strings: strings),
      ),
    );
  }
}
import '../standalone/wallet_ports.dart';
import 'app_localizations.dart';

/// Wallet-only l10n entry — no FCG voting strings on the standalone path.
typedef WalletLocalizations = AppLocalizations;

WalletLocalizations walletLocalizationsOf(LocaleConfig config) =>
    AppLocalizations.of(config);
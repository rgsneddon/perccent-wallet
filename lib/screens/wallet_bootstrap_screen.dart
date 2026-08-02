import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../perc/providers/perc_wallet_provider.dart';
import '../perc/widgets/registration_seed_setup_dialog.dart';
import '../providers/locale_provider.dart';
import 'wallet_loading_screen.dart';
import 'wallet_shell_screen.dart';

/// Splash, wallet boot, then sign-in before the standalone shell.
class WalletBootstrapScreen extends StatefulWidget {
  const WalletBootstrapScreen({
    super.key,
    required this.walletProvider,
    this.showShellBottomBar = true,
    this.shellTabIndex,
  });

  final PercWalletProvider walletProvider;

  /// When false, [WalletShellScreen] hides its nested bottom bar (Suite embed).
  final bool showShellBottomBar;

  /// Optional forced shell tab when embedded in Suite.
  final int? shellTabIndex;

  @override
  State<WalletBootstrapScreen> createState() => _WalletBootstrapScreenState();
}

class _WalletBootstrapScreenState extends State<WalletBootstrapScreen> {
  bool _walletReady = false;
  bool _enteredApp = false;
  Object? _bootError;

  @override
  void initState() {
    super.initState();
    if (widget.walletProvider.isReady) {
      _walletReady = true;
    } else {
      unawaited(_bootWallet(widget.walletProvider));
    }
  }

  Future<void> _bootWallet(PercWalletProvider wallet) async {
    try {
      await wallet.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException(
          'Wallet boot timed out after 20s',
        ),
      );
      if (!mounted) return;
      setState(() => _walletReady = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _bootError = e);
    }
  }

  void _enterApp() {
    setState(() => _enteredApp = true);
  }

  bool get _ready => _walletReady && _enteredApp && _bootError == null;

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return RegistrationSeedSetupDialogHost(
        child: WalletShellScreen(
          openRegistrationOnLaunch: false,
          showBottomBar: widget.showShellBottomBar,
          tabIndex: widget.shellTabIndex,
        ),
      );
    }

    if (_bootError != null) {
      final strings =
          AppLocalizations.of(context.watch<LocaleProvider>().config);
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.t('wallet_opening_error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _bootError = null;
                      _walletReady = widget.walletProvider.isReady;
                    });
                    if (!_walletReady) {
                      unawaited(_bootWallet(widget.walletProvider));
                    }
                  },
                  child: Text(strings.t('wallet_opening_retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RegistrationSeedSetupDialogHost(
      child: WalletLoadingScreen(
        walletReady: _walletReady,
        onAuthenticated: _enterApp,
        onEnterApp: _enterApp,
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../perc/models/perc_faucet_credit_result.dart';
import '../perc/providers/perc_wallet_provider.dart';
import '../perc/services/perc_faucet_cooldown.dart';
import '../perc/services/perc_network_coordinator.dart';
import '../perc/screens/credit_screen.dart';
import '../perc/screens/security_screen.dart';
import '../perc/screens/wallet_screen.dart';
import '../providers/locale_provider.dart';

/// Wallet-only shell — Wallet, Security, and Credit tabs (no Evolve analysis).
///
/// When [showBottomBar] is false (Suite embed), only the body for [tabIndex]
/// is shown — the Suite main bar owns navigation.
class WalletShellScreen extends StatefulWidget {
  const WalletShellScreen({
    super.key,
    this.openRegistrationOnLaunch = false,
    this.showBottomBar = true,
    this.tabIndex,
  });

  final bool openRegistrationOnLaunch;

  /// When false, hide nested bottom [NavigationBar] (Suite hosts destinations).
  final bool showBottomBar;

  /// When non-null, force this tab body (0=Wallet, 1=Security, 2=Credit).
  final int? tabIndex;

  @override
  State<WalletShellScreen> createState() => _WalletShellScreenState();
}

class _WalletShellScreenState extends State<WalletShellScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  late bool _walletTabVisited = widget.openRegistrationOnLaunch;
  PercWalletProvider? _wallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final inBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive;
    PercNetworkCoordinator.instance.setAppInBackground(inBackground);
    if (state == AppLifecycleState.resumed) {
      _wallet?.checkSessionTimeout();
      final wallet = _wallet;
      if (wallet != null) unawaited(wallet.refreshInboundNow());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.read<PercWalletProvider>();
    if (_wallet != wallet) {
      _wallet?.removeListener(_onWalletUpdate);
      _wallet = wallet;
      _wallet!.addListener(_onWalletUpdate);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wallet?.removeListener(_onWalletUpdate);
    super.dispose();
  }

  void _onWalletUpdate() {
    final popup = _wallet?.takeCooldownPopup();
    if (popup != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCooldownDialog(popup);
      });
    }
  }

  Future<void> _showCooldownDialog(PercFaucetCreditResult result) async {
    final strings = AppLocalizations.of(context.read<LocaleProvider>().config);
    final wait = result.cooldownRemaining ?? Duration.zero;
    final blockWait = result.nextBlockEstimate ?? wait;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.t('wallet_cooldown_popup_title')),
        content: Text(
          strings
              .t('wallet_cooldown_popup_body')
              .replaceAll('{wait}', PercFaucetCooldown.formatWait(wait))
              .replaceAll(
                  '{blockWait}', PercFaucetCooldown.formatWait(blockWait)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.t('wallet_cooldown_popup_ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context.watch<LocaleProvider>().config);

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Wallet',
      ),
      NavigationDestination(
        icon: Icon(Icons.security_outlined),
        selectedIcon: Icon(Icons.security),
        label: 'Security',
      ),
      NavigationDestination(
        icon: Icon(Icons.info_outline),
        selectedIcon: Icon(Icons.info),
        label: 'Credit',
      ),
    ];

    final navIndex =
        (widget.tabIndex ?? _index).clamp(0, destinations.length - 1);
    final showWallet = _walletTabVisited || navIndex == 0;
    if (navIndex == 0 && !_walletTabVisited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _walletTabVisited = true);
      });
    }

    final body = IndexedStack(
      index: navIndex,
      children: [
        showWallet ? const WalletScreen() : const SizedBox.shrink(),
        const SecurityScreen(),
        const CreditScreen(),
      ],
    );

    if (!widget.showBottomBar) {
      // Suite main bar owns destinations — no nested child bar.
      return Scaffold(
        key: const Key('wallet_shell_embed_no_bottom_bar'),
        body: body,
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: destinations[0].icon,
            selectedIcon: destinations[0].selectedIcon,
            label: strings.t('nav_wallet'),
          ),
          NavigationDestination(
            icon: destinations[1].icon,
            selectedIcon: destinations[1].selectedIcon,
            label: strings.t('nav_security'),
          ),
          NavigationDestination(
            icon: destinations[2].icon,
            selectedIcon: destinations[2].selectedIcon,
            label: strings.t('nav_credit'),
          ),
        ],
      ),
    );
  }
}
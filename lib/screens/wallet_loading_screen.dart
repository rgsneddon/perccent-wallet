import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../perc/perc_app_version.dart';
import '../perc/providers/perc_wallet_provider.dart';
import '../l10n/wallet_message_localization.dart';
import '../perc/widgets/wallet_auth_panel.dart';
import '../perc/widgets/wallet_credential_error_banner.dart';
import '../providers/locale_provider.dart';
import '../wallet_core/services/app_update_check.dart';
import '../perc/widgets/wallet_language_selector.dart';
import '../standalone/my_perc_branding.dart';
import '../widgets/my_perc_upgrade_advisory.dart';
import '../widgets/wallet_splash_poster.dart';
import '../widgets/splash_version_status.dart';

/// MY PERC launch screen — solid background until the user signs in.
class WalletLoadingScreen extends StatefulWidget {
  const WalletLoadingScreen({
    super.key,
    required this.walletReady,
    this.onAuthenticated,
    this.onEnterApp,
  });

  final bool walletReady;
  final VoidCallback? onAuthenticated;
  final VoidCallback? onEnterApp;

  @visibleForTesting
  static Duration? introDurationOverride;

  static Duration get introDuration =>
      introDurationOverride ?? const Duration(seconds: 3);

  static String get versionLabel =>
      'v${PercAppVersion.releaseOf(PercAppVersion.current)}';

  @override
  State<WalletLoadingScreen> createState() => _WalletLoadingScreenState();
}

class _WalletLoadingScreenState extends State<WalletLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  bool _showAuth = false;
  bool _hadAccessAtBoot = false;
  bool _capturedBootAccess = false;
  PercWalletProvider? _wallet;
  bool _checkingUpdate = true;
  AppUpdateInfo? _updateInfo;
  final _authPanelKey = GlobalKey<WalletAuthPanelState>();
  bool _autoEnterTriggered = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkForUpdates());
    _intro = AnimationController(
      vsync: this,
      duration: WalletLoadingScreen.introDuration,
    );
    if (WalletLoadingScreen.introDuration == Duration.zero) {
      _showAuth = true;
    } else {
      _intro.forward().whenComplete(() {
        if (mounted) setState(() => _showAuth = true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.read<PercWalletProvider>();
    if (!_capturedBootAccess) {
      _hadAccessAtBoot = wallet.hasAppAccess;
      _capturedBootAccess = true;
    }
    if (!identical(_wallet, wallet)) {
      _wallet?.removeListener(_onWalletChanged);
      _wallet = wallet;
      _wallet!.addListener(_onWalletChanged);
    }
    _maybeAutoEnterApp();
  }

  @override
  void didUpdateWidget(WalletLoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.walletReady &&
        (_intro.status == AnimationStatus.completed ||
            WalletLoadingScreen.introDuration == Duration.zero)) {
      _showAuth = true;
    }
  }

  Future<void> _checkForUpdates() async {
    final info = await const AppUpdateChecker().check();
    if (!mounted) return;
    setState(() {
      _updateInfo = info;
      _checkingUpdate = false;
    });
  }

  void _onWalletChanged() {
    _maybeAutoEnterApp();
  }

  void _maybeAutoEnterApp() {
    if (!mounted || !_showAuth || !widget.walletReady || _autoEnterTriggered) {
      return;
    }
    final wallet = _wallet;
    if (wallet == null || !wallet.isWalletConnectComplete) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _autoEnterTriggered) return;
      final current = _wallet;
      if (current == null || !current.isWalletConnectComplete) return;
      _autoEnterTriggered = true;
      widget.onAuthenticated?.call();
    });
  }

  @override
  void dispose() {
    _wallet?.removeListener(_onWalletChanged);
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        AppLocalizations.of(context.watch<LocaleProvider>().config);
    final wallet = context.watch<PercWalletProvider>();
    final authVisible = _showAuth && widget.walletReady;
    final authSlide = authVisible ? 0.0 : 28.0;
    final authOpacity = authVisible ? 1.0 : 0.0;

    final credentialErrorActive = !wallet.hasAppAccess &&
        WalletMessageLocalization.isCredentialError(wallet.errorMessage);

    return WalletCredentialErrorScope(
      active: credentialErrorActive,
      onDismiss: () => _authPanelKey.currentState?.dismissCredentialError(),
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WalletSplashPoster(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Text(
                                MyPercBranding.productName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                  color: MyPercBranding.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                strings.t('splash_tagline'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                  color: MyPercBranding.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const WalletLanguageSelector(),
                              const SizedBox(height: 4),
                              Text(
                                WalletLoadingScreen.versionLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  color: MyPercBranding.textMuted,
                                ),
                              ),
                              SplashVersionStatus(
                                info: _updateInfo,
                                checking: _checkingUpdate,
                                strings: strings,
                              ),
                              MyPercUpgradeAdvisory(
                                strings: strings,
                                latestRelease: _updateInfo?.latestRelease,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          opacity: authOpacity,
                          duration: const Duration(milliseconds: 450),
                          child: AnimatedSlide(
                            offset: Offset(0, authSlide / 120),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: _authSection(wallet, strings),
                            ),
                          ),
                        ),
                        if (!widget.walletReady)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  strings.t('splash_preparing_wallet'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9BA3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _authSection(PercWalletProvider wallet, AppLocalizations strings) {
    if (wallet.hasAppAccess) {
      return _walletLoadingSection(strings);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MyPercBranding.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyPercBranding.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WalletAuthPanel(
          key: _authPanelKey,
          compact: true,
          showCreatorCredit: false,
        ),
      ),
    );
  }

  Widget _walletLoadingSection(AppLocalizations strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            strings.t('splash_wallet_loading'),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9BA3B8),
            ),
          ),
        ],
      ),
    );
  }
}

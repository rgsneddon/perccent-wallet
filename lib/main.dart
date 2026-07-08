import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/locale_config.dart';
import 'models/locale_config_ui.dart';
import 'perc/providers/perc_wallet_provider.dart';
import 'perc/services/perc_network_coordinator.dart';
import 'platform/desktop_window_init.dart';
import 'providers/evolve_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/wallet_bootstrap_screen.dart';
import 'theme/app_theme.dart';
import 'platform/desktop_platform.dart';
import 'widgets/app_version_badge.dart';
import 'widgets/desktop_window_shell.dart';
import 'widgets/locale_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDesktopWindow();
  PercNetworkCoordinator.disableLiveNodesForTests = false;

  final walletProvider = PercWalletProvider();
  final evolveProvider = EvolveProvider();
  final localeProvider = LocaleProvider();

  await localeProvider.initialize();

  runApp(PerccentWalletApp(
    walletProvider: walletProvider,
    evolveProvider: evolveProvider,
    localeProvider: localeProvider,
  ));
}

class PerccentWalletApp extends StatelessWidget {
  const PerccentWalletApp({
    super.key,
    required this.walletProvider,
    required this.evolveProvider,
    required this.localeProvider,
  });

  final PercWalletProvider walletProvider;
  final EvolveProvider evolveProvider;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: evolveProvider),
        ChangeNotifierProvider.value(value: walletProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProv, _) {
          final strings = AppLocalizations.of(localeProv.config);

          return MaterialApp(
            title: strings.t('wallet_app_title'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            locale: localeProv.config.materialLocale,
            supportedLocales: LocaleConfig.languages
                .map((l) => Locale(l.code))
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final content = child ?? const SizedBox.shrink();
              return Directionality(
                textDirection: localeProv.config.textDirection,
                child: DesktopWindowShell(
                  title: strings.t('wallet_app_title'),
                  child: isDesktopWindows
                      ? content
                      : Stack(
                          clipBehavior: Clip.none,
                          children: [
                            content,
                            Positioned(
                              top: MediaQuery.paddingOf(context).top + 6,
                              right: 10,
                              child: const IgnorePointer(
                                child: AppVersionBadge(),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
            home: LocaleSync(
              child: WalletBootstrapScreen(walletProvider: walletProvider),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// Standalone MY PERC product identity, palette, and canonical upgrade links.
class MyPercBranding {
  const MyPercBranding._();

  static const String productName = 'MY PERC';

  /// Deep slate — solid splash/login background.
  static const Color splashBackground = Color(0xFF0F1A24);

  static const Color scaffoldBackground = Color(0xFF0F1A24);
  static const Color surface = Color(0xFF1A2836);
  static const Color surfaceElevated = Color(0xFF243447);
  static const Color primaryAccent = Color(0xFFE8A838);
  static const Color secondaryAccent = Color(0xFF4ECDC4);
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFFA8B8C8);
  static const Color textMuted = Color(0xFF7A8FA3);
  static const Color borderSubtle = Color(0xFF2E4054);

  /// perccent-wallet release feeds (not Evolve v4.*).
  static const String pagesVersionUrl =
      'https://rgsneddon.github.io/perccent-wallet/version.json';
  static const String sourceVersionUrl =
      'https://raw.githubusercontent.com/rgsneddon/perccent-wallet/main/version.json';
  static const String downloadsBaseUrl =
      'https://github.com/rgsneddon/perccent-wallet/releases/latest';
  static const String releasesBaseUrl =
      'https://github.com/rgsneddon/perccent-wallet/releases/download';
  static const String releasesTagBaseUrl =
      'https://github.com/rgsneddon/perccent-wallet/releases/tag';

  /// Optional upgrade to the full Evolve Suite (analysis + governance).
  static const String fullEvolveSuiteUrl = 'https://rgsneddon.github.io/evolve/';

  static const String installerPrefix = 'perccent-wallet';

  /// Analysis faucet is Evolve-only — hidden on MY PERC wallet home.
  static const bool showAnalysisFaucet = false;
}
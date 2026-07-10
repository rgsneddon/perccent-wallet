import 'package:flutter/material.dart';

import '../standalone/my_perc_branding.dart';

/// Solid-color splash background for MY PERC (no banner image).
class WalletSplashPoster extends StatelessWidget {
  const WalletSplashPoster({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: MyPercBranding.splashBackground);
  }
}
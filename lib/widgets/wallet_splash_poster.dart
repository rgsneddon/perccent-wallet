import 'package:flutter/material.dart';

/// Static splash background — no video decode or animation.
class WalletSplashPoster extends StatelessWidget {
  const WalletSplashPoster({
    super.key,
    this.assetPath = 'assets/banner/evolve.jpg',
  });

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.low,
        semanticLabel: 'Perccent wallet splash',
        errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0A0E18)),
      ),
    );
  }
}
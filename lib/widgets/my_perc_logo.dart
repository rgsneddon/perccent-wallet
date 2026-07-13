import 'package:flutter/material.dart';

/// MY PERC % mark shown on splash and login.
class MyPercLogo extends StatelessWidget {
  const MyPercLogo({
    super.key,
    this.size = 88,
  });

  static const String assetPath = 'assets/branding/my_perc_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'MY PERC logo',
    );
  }
}
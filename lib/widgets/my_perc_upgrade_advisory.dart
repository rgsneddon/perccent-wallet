import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../standalone/my_perc_branding.dart';
import '../wallet_core/services/app_update_check.dart';

/// Discrete optional upgrade links on the MY PERC login screen.
class MyPercUpgradeAdvisory extends StatelessWidget {
  const MyPercUpgradeAdvisory({
    super.key,
    required this.strings,
    this.latestRelease,
  });

  final AppLocalizations strings;
  final String? latestRelease;

  @override
  Widget build(BuildContext context) {
    final myPercUrl = latestRelease != null && latestRelease!.isNotEmpty
        ? AppUpdateChecker.updateUrlForRelease(latestRelease!)
        : MyPercBranding.downloadsBaseUrl;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 11,
            height: 1.45,
            color: MyPercBranding.textMuted,
          ),
          children: [
            TextSpan(text: strings.t('my_perc_upgrade_advisory_prefix')),
            TextSpan(
              text: strings.t('my_perc_upgrade_evolve_link'),
              style: const TextStyle(
                color: MyPercBranding.secondaryAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _open(MyPercBranding.fullEvolveSuiteUrl),
            ),
            TextSpan(text: strings.t('my_perc_upgrade_advisory_mid')),
            TextSpan(
              text: strings.t('my_perc_upgrade_wallet_link'),
              style: const TextStyle(
                color: MyPercBranding.primaryAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _open(myPercUrl),
            ),
            TextSpan(text: strings.t('my_perc_upgrade_advisory_suffix')),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../wallet_core/models/chronoflux_continuum_snapshot.dart';
import '../../wallet_core/models/locale_config.dart';
import '../../wallet_core/models/scenario_input.dart';
import '../../wallet_core/services/chronoflux_micro_engine.dart';

/// Verifies each microblock against the Chronoflux continuum equation.
class PercChronofluxMicroVerifier {
  const PercChronofluxMicroVerifier({ChronofluxMicroEngine? engine})
      : _engine = engine ?? const ChronofluxMicroEngine();

  final ChronofluxMicroEngine _engine;

  ChronofluxMicroVerifyResult verify(
    ScenarioInput input, {
    LocaleConfig locale = LocaleConfig.defaults,
  }) {
    final snapshot = _engine.continuumSnapshot(input, locale: locale);
    final recheck = ChronofluxMicroEngine.heuristicPercentChance(
      regressivePct: snapshot.regressivePct,
      refinedScs: snapshot.refinedScs,
      shearScs: snapshot.shearScs,
    );
    final selfConsistent =
        (recheck - snapshot.continuumPercent).abs() < 1e-9;
    final payload = _payloadFor(snapshot);
    final fingerprint = _fingerprint(payload);
    final fingerprintRecheck = _fingerprint(payload);
    return ChronofluxMicroVerifyResult(
      fingerprint: fingerprint,
      selfConsistent: selfConsistent && fingerprint == fingerprintRecheck,
      continuumPercent: snapshot.continuumPercent,
      regressivePct: snapshot.regressivePct,
      refinedScs: snapshot.refinedScs,
      shearScs: snapshot.shearScs,
    );
  }

  static String _payloadFor(ChronofluxContinuumSnapshot snapshot) =>
      '${snapshot.regressivePct.toStringAsFixed(6)}|'
      '${snapshot.refinedScs.toStringAsFixed(6)}|'
      '${snapshot.shearScs.toStringAsFixed(6)}|'
      '${snapshot.continuumPercent.toStringAsFixed(6)}';

  static String _fingerprint(String payload) =>
      sha256.convert(utf8.encode(payload)).toString();
}

class ChronofluxMicroVerifyResult {
  const ChronofluxMicroVerifyResult({
    required this.fingerprint,
    required this.selfConsistent,
    required this.continuumPercent,
    required this.regressivePct,
    required this.refinedScs,
    required this.shearScs,
  });

  final String fingerprint;
  final bool selfConsistent;
  final double continuumPercent;
  final double regressivePct;
  final double refinedScs;
  final double shearScs;
}
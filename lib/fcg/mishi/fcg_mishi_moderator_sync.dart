import '../../perc/services/perc_ledger.dart';
import 'fcg_mishi_bridge_store.dart';

/// Standalone wallet: Mishi bridge sync is disabled (Evolve-only integration).
Future<void> syncModeratorVerifierToMishiBridge({
  required PercLedger ledger,
  required String username,
  FcgMishiBridgeStore? bridge,
}) async {}
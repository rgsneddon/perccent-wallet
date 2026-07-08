/// Standalone wallet boundary — perc/ imports this facade, not wallet_core/ or fcg/.
library;

export 'wallet_error_keys.dart';
export 'mishi_sync.dart' show syncModeratorVerifierToMishiBridge;
export '../wallet_core/widgets/wallet_attribution.dart';
export '../wallet_core/governance/governance_paper.dart';
export '../wallet_core/data/ward_moderator_registry.dart';
export '../wallet_core/models/analysis_mode.dart';
export '../wallet_core/models/chronoflux_continuum_snapshot.dart';
export '../wallet_core/models/construct_meta.dart';
export '../wallet_core/models/locale_config.dart';
export '../wallet_core/models/locale_config_ui.dart';
export '../wallet_core/models/scenario_input.dart';
export '../wallet_core/services/app_performance.dart';
export '../wallet_core/services/chronoflux_micro_engine.dart';
export 'platform_detect.dart';
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$replacements = @(
    @("import '../../models/locale_config.dart';", "import '../../wallet_core/models/locale_config.dart';"),
    @("import '../../models/analysis_mode.dart';", "import '../../wallet_core/models/analysis_mode.dart';"),
    @("import '../../models/scenario_input.dart';", "import '../../wallet_core/models/scenario_input.dart';"),
    @("import '../../models/construct_meta.dart';", "import '../../wallet_core/models/construct_meta.dart';"),
    @("import '../../models/chronoflux_continuum_snapshot.dart';", "import '../../wallet_core/models/chronoflux_continuum_snapshot.dart';"),
    @("import '../../services/app_performance.dart';", "import '../../wallet_core/services/app_performance.dart';"),
    @("import '../../services/evolve_engine.dart';", "import '../../wallet_core/services/chronoflux_micro_engine.dart';"),
    @("import '../../fcg/data/fcg_uk_ward_moderator_registry.dart';", "import '../../wallet_core/data/ward_moderator_registry.dart';"),
    @("import '../../fcg/services/fcg_governance_paper.dart';", "import '../../wallet_core/governance/governance_paper.dart';"),
    @("import '../../fcg/mishi/fcg_mishi_moderator_sync.dart';", "import '../services/perc_mishi_sync.dart';"),
    @("import '../../widgets/evolve_creator_attribution.dart';", "import '../../wallet_core/widgets/wallet_attribution.dart';"),
    @("import 'models/locale_config.dart';", "import 'wallet_core/models/locale_config.dart';"),
    @("import 'models/locale_config_ui.dart';", "import 'wallet_core/models/locale_config_ui.dart';"),
    @("import '../models/locale_config.dart';", "import '../wallet_core/models/locale_config.dart';"),
    @("import '../services/device_locale_resolver.dart';", "import '../wallet_core/services/device_locale_resolver.dart';"),
    @("import '../services/locale_store.dart';", "import '../wallet_core/services/locale_store.dart';"),
    @("import '../services/locale_store_factory.dart';", "import '../wallet_core/services/locale_store_factory.dart';"),
    @("import '../services/app_update_check.dart';", "import '../wallet_core/services/app_update_check.dart';"),
    @("EvolveCreatorAttribution", "WalletAttribution"),
    @("FcgGovernancePaper", "GovernancePaper"),
    @("FcgUkWardModeratorRegistry", "WardModeratorRegistry"),
    @("EvolveEngine", "ChronofluxMicroEngine")
)

Get-ChildItem -Recurse lib -Filter *.dart | ForEach-Object {
    if ($_.FullName -match 'wallet_core') { return }
    $c = Get-Content $_.FullName -Raw
    $changed = $false
    foreach ($pair in $replacements) {
        if ($c -contains $pair[0] -or $c.Contains($pair[0])) {
            $c = $c.Replace($pair[0], $pair[1])
            $changed = $true
        }
    }
    if ($changed) { Set-Content $_.FullName $c -NoNewline }
}

# platform_detect conditional imports in perc_qr_scanner_support
$qr = Get-Content lib/perc/services/perc_qr_scanner_support.dart -Raw
$qr = $qr -replace "../../services/platform_detect_stub.dart", "../../wallet_core/services/platform_detect_stub.dart"
$qr = $qr -replace "../../services/platform_detect_io.dart", "../../wallet_core/services/platform_detect_io.dart"
Set-Content lib/perc/services/perc_qr_scanner_support.dart $qr -NoNewline

Write-Host "imports updated"
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

# Files needed by evolve_engine chain + wallet shell (from find_wallet_deps.py)
$serviceFiles = @(
    "app_performance.dart","app_update_check.dart","base_rate_service.dart",
    "chronoflux_weight_construal.dart","cohesion_narrative_formatter.dart",
    "cohesion_report_formatter.dart","conclusion_explainer_data_builder.dart",
    "construal_realtime.dart","continuum_conclusion_builder.dart",
    "device_locale_resolver.dart","event_classifier.dart","evolve_engine.dart",
    "evolve_engine_runner.dart","field_calculation_context.dart",
    "forecast_calibrator.dart","grok_style_formatter.dart","input_parser.dart",
    "locale_store.dart","locale_store_factory.dart","locale_store_io.dart",
    "locale_store_memory.dart","locale_store_stub.dart","locale_store_web.dart",
    "multi_part_question_parser.dart","observational_analyzer.dart",
    "outcome_feasibility.dart","part_pathway_weight_construal.dart",
    "part_percent_composer.dart","part_three_action_builder.dart",
    "part_three_conclusion_formatter.dart","part_two_narrative_builder.dart",
    "party_response_analyzer.dart","party_response_extractor.dart",
    "pathway_construal_service.dart","platform_detect_io.dart",
    "platform_detect_stub.dart","platform_detect_web.dart",
    "question_parameter_scraper.dart","question_relevance_filter.dart",
    "question_semantics.dart","region_context.dart","scenario_agent_detector.dart",
    "scenario_calculation_context.dart","scenario_input_profile.dart",
    "scenario_lean_context.dart","social_discourse_construal.dart"
)
$modelFiles = @(
    "analysis_mode.dart","chronoflux_continuum_snapshot.dart",
    "conclusion_explainer_data.dart","construct_input.dart","evolve_result.dart",
    "forecast_result.dart","grok_session.dart","locale_config.dart",
    "locale_config_ui.dart","outcome_record.dart","part_percent_breakdown.dart",
    "part_three_conclusion.dart","party_response_scs.dart",
    "pathway_construct_texts.dart","scenario_input.dart"
)

New-Item -ItemType Directory -Force -Path lib/wallet_core/services,lib/wallet_core/models,lib/wallet_core/data,lib/wallet_core/governance,lib/wallet_core/widgets | Out-Null

foreach ($f in $serviceFiles) {
    Copy-Item "lib/services/$f" "lib/wallet_core/services/$f" -Force
}
foreach ($f in $modelFiles) {
    Copy-Item "lib/models/$f" "lib/wallet_core/models/$f" -Force
}
Copy-Item lib/data/outcome_registry.dart lib/wallet_core/data/outcome_registry.dart -Force
Copy-Item lib/fcg/data/fcg_uk_ward_moderator_list.dart lib/wallet_core/data/ward_moderator_list.dart -Force
Copy-Item lib/fcg/data/fcg_uk_ward_moderator_list_stub.dart lib/wallet_core/data/ward_moderator_list_stub.dart -Force
Copy-Item lib/fcg/data/fcg_uk_ward_moderator_registry.dart lib/wallet_core/data/ward_moderator_registry.dart -Force
Copy-Item lib/fcg/services/fcg_governance_paper.dart lib/wallet_core/governance/governance_paper.dart -Force
Copy-Item lib/widgets/evolve_creator_attribution.dart lib/wallet_core/widgets/wallet_attribution.dart -Force

# Rename evolve_engine -> chronoflux_micro_engine
Rename-Item lib/wallet_core/services/evolve_engine.dart chronoflux_micro_engine.dart
Remove-Item lib/wallet_core/services/evolve_engine_runner.dart -Force

# Fix imports inside wallet_core
Get-ChildItem -Recurse lib/wallet_core -Filter *.dart | ForEach-Object {
    $c = Get-Content $_.FullName -Raw
    $c = $c -replace "import '\.\./models/", "import '../models/"
    $c = $c -replace "import '\.\./\.\./models/", "import '../../wallet_core/models/"
    $c = $c -replace "import '\.\./services/", "import '../services/"
    $c = $c -replace "import '\.\./\.\./services/", "import '../../wallet_core/services/"
    $c = $c -replace "import '\.\./data/", "import '../data/"
    $c = $c -replace "import '\.\./\.\./data/", "import '../../wallet_core/data/"
    $c = $c -replace "import '\.\./l10n/", "import '../../l10n/"
    $c = $c -replace "import '\.\./\.\./l10n/", "import '../../l10n/"
    $c = $c -replace "import '\.\./perc/", "import '../../perc/"
    $c = $c -replace "import 'fcg_uk_ward_moderator_list.dart'", "import 'ward_moderator_list.dart'"
    $c = $c -replace "FcgUkWardModeratorRegistry", "WardModeratorRegistry"
    $c = $c -replace "fcgUkWardModeratorUsernames", "wardModeratorUsernames"
    $c = $c -replace "fcgUkWardModeratorWardNames", "wardModeratorWardNames"
    $c = $c -replace "class FcgGovernancePaper", "class GovernancePaper"
    $c = $c -replace "FcgGovernancePaper", "GovernancePaper"
    $c = $c -replace "class EvolveCreatorAttribution", "class WalletAttribution"
    $c = $c -replace "EvolveCreatorAttribution", "WalletAttribution"
    $c = $c -replace "_EvolveCreatorAttributionState", "_WalletAttributionState"
    $c = $c -replace "class EvolveEngine", "class ChronofluxMicroEngine"
    $c = $c -replace "EvolveEngine", "ChronofluxMicroEngine"
    $c = $c -replace "import 'evolve_engine.dart'", "import 'chronoflux_micro_engine.dart'"
    $c = $c -replace "import 'evolve_engine_runner.dart'", ""
    Set-Content $_.FullName $c -NoNewline
}

# Slim pathway_construct_texts — drop Grok factory
$pt = Get-Content lib/wallet_core/models/pathway_construct_texts.dart -Raw
$pt = $pt -replace "import '\.\./models/grok_session\.dart';\r?\n\r?\n", ""
$pt = $pt -replace "(?s)  factory PathwayConstructTexts\.fromGrok\(GrokConstrualResult result\) =>.*?;\r?\n\r?\n", ""
Set-Content lib/wallet_core/models/pathway_construct_texts.dart $pt -NoNewline

# Ward registry class rename in registry file
$wr = Get-Content lib/wallet_core/data/ward_moderator_registry.dart -Raw
$wr = $wr -replace "abstract final class FcgUkWardModeratorRegistry", "abstract final class WardModeratorRegistry"
Set-Content lib/wallet_core/data/ward_moderator_registry.dart $wr -NoNewline

Write-Host "wallet_core scaffold created"
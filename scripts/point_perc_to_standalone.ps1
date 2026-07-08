$replacements = @(
    @("import '../../wallet_core/models/analysis_mode.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/models/locale_config.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/models/scenario_input.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/models/construct_meta.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/models/chronoflux_continuum_snapshot.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/services/app_performance.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/services/chronoflux_micro_engine.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/governance/governance_paper.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/widgets/wallet_attribution.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/data/ward_moderator_registry.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../services/perc_mishi_sync.dart';", "import '../../standalone/wallet_ports.dart';"),
    @("import '../../wallet_core/services/platform_detect_stub.dart'", "import '../../standalone/wallet_ports.dart'"),
    @("import '../../wallet_core/services/platform_detect_io.dart'", "import '../../standalone/wallet_ports.dart'")
)

Get-ChildItem -Recurse lib/perc -Filter *.dart | ForEach-Object {
    $c = Get-Content $_.FullName -Raw
    $orig = $c
    foreach ($pair in $replacements) {
        $c = $c.Replace($pair[0], $pair[1])
    }
    # Deduplicate repeated wallet_ports imports
    $lines = $c -split "`n"
    $seenPorts = $false
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($line in $lines) {
        if ($line -match "import '../../standalone/wallet_ports.dart';") {
            if ($seenPorts) { continue }
            $seenPorts = $true
        }
        $out.Add($line)
    }
    $c = ($out -join "`n")
    if ($c -ne $orig) { Set-Content $_.FullName $c -NoNewline }
}
Write-Host "perc -> standalone"
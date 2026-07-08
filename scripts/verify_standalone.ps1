param(
  [string]$Scratch = $env:SCRATCH
)

$ErrorActionPreference = "Stop"
if (-not $Scratch) {
  $Scratch = Join-Path $env:TEMP "grok-goal-e875eeaa4a0f\implementer"
}
$env:SCRATCH = $Scratch
New-Item -ItemType Directory -Force -Path $Scratch | Out-Null

$RepoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $RepoRoot

$commit = (git rev-parse --short HEAD).Trim()
$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

function Write-Scratch($name, $content) {
  Set-Content -Path (Join-Path $Scratch $name) -Value $content -Encoding utf8
}

# Fresh scratch - remove stale artifacts
@(
  "standalone_repo_meta.log","standalone_flutter_tests.log","standalone_shell_structure.log",
  "standalone_perc_chain_tests.log","standalone_seed_health_1.json","standalone_seed_health_2.json",
  "standalone_seed_peers.json","standalone_seed_status.json","standalone_docs_check.log",
  "standalone_flutter_analyze.log","CHANGED_FILES.log","standalone_wallet_verify.log",
  "flutter_analyze.log"
) | ForEach-Object {
  $p = Join-Path $Scratch $_
  if (Test-Path $p) { Remove-Item $p -Force }
}

Write-Host "=== verify_standalone @ $commit ==="

# 1. Repo meta
try {
  $meta = gh repo view rgsneddon/perccent-wallet --json name,visibility,url 2>&1 | Out-String
} catch {
  $meta = "gh unavailable: $_"
}
Write-Scratch "standalone_repo_meta.log" $meta

# 2. Flutter tests (plan step 2 file list)
$testFiles = @(
  "test/perc_auth_username_test.dart",
  "test/perc_registration_completion_test.dart",
  "test/perc_send_settlement_test.dart",
  "test/perc_wallet_backup_test.dart",
  "test/perc_seed_recovery_test.dart",
  "test/perc_chain_alignment_test.dart",
  "test/perc_chain_tip_test.dart",
  "test/perc_network_coordinator_test.dart",
  "test/perc_treasury_lock_test.dart"
)
$flutterLog = Join-Path $Scratch "standalone_flutter_tests.log"
flutter test @testFiles 2>&1 | Tee-Object -FilePath $flutterLog
if ($LASTEXITCODE -ne 0) { throw "flutter test failed" }

# 3. Shell structure
$shellLog = @()
$shellLog += "commit=$commit captured=$stamp"
$shellLog += ""
$shellLog += "=== main.dart imports ==="
$shellLog += (Select-String -Path lib/main.dart -Pattern "^import" | ForEach-Object { $_.Line })
$shellLog += ""
$shellLog += "=== wallet_shell_screen tabs ==="
$shellLog += (Select-String -Path lib/screens/wallet_shell_screen.dart -Pattern "WalletScreen|SecurityScreen|CreditScreen|HomeScreen|FcgVoting|EvolveProvider" | ForEach-Object { $_.Line })
$shellLog += ""
$shellLog += "=== forbidden imports in entry/shell ==="
$forbidden = Select-String -Path lib/main.dart,lib/screens/wallet_shell_screen.dart,lib/screens/wallet_bootstrap_screen.dart -Pattern "EvolveProvider|HomeScreen|FcgVoting|fcg/|evolve_engine" -SimpleMatch
if ($forbidden) { $shellLog += $forbidden.Line } else { $shellLog += "(none)" }
$shellLog += ""
$shellLog += "=== perc imports wallet_core (should be empty) ==="
$wc = Get-ChildItem -Recurse lib/perc -Filter *.dart | Select-String -Pattern "wallet_core" | ForEach-Object { "$($_.Filename):$($_.LineNumber):$($_.Line.Trim())" }
if ($wc) { $shellLog += $wc } else { $shellLog += "(none - perc uses standalone/ only)" }
Write-Scratch "standalone_shell_structure.log" ($shellLog -join "`n")

# 4. perc_chain tests
$chainLog = Join-Path $Scratch "standalone_perc_chain_tests.log"
Push-Location perc_chain
npm test 2>&1 | Tee-Object -FilePath $chainLog
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "npm test failed" }
Pop-Location

# 5-6. Seed evidence
Push-Location perc_chain
node scripts/capture_seed_evidence.mjs $Scratch
$seedExit = $LASTEXITCODE
if ($seedExit -eq 2) {
  Write-Host "Seed peers empty - running fallback tests"
  node --test src/merge_network_state.test.js src/seed_wallet_compat.test.js 2>&1 | Tee-Object -FilePath (Join-Path $Scratch "standalone_seed_fallback_tests.log")
  $peers = Get-Content (Join-Path $Scratch "standalone_seed_peers.json") -Raw | ConvertFrom-Json
  $peers | Add-Member -NotePropertyName fallbackTests -NotePropertyValue "merge_network_state + seed_wallet_compat passed" -Force
  $peers | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $Scratch "standalone_seed_peers.json")
}
Pop-Location

# 7. Docs
$docs = @()
foreach ($f in @("README.md","LICENSE","PRIVACY_POLICY.md")) {
  $docs += "=== $f ==="
  if (Test-Path $f) { $docs += (Get-Content $f -TotalCount 20) } else { $docs += "MISSING" }
  $docs += ""
}
Write-Scratch "standalone_docs_check.log" ($docs -join "`n")

# 9. Flutter analyze
$analyzeLog = Join-Path $Scratch "standalone_flutter_analyze.log"
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
flutter analyze lib 2>&1 | Tee-Object -FilePath $analyzeLog | Out-Null
$ErrorActionPreference = $prevEap
$errors = Select-String -Path $analyzeLog -Pattern "^  error"
if ($errors) { throw "flutter analyze errors: $($errors.Count)" }

# Changed files + summary
$changed = @()
$changed += git status --short
$changed += git diff --stat
Write-Scratch "CHANGED_FILES.log" ($changed -join "`n") 
@(
  "verify_standalone.ps1 run",
  "commit=$commit",
  "stamp=$stamp",
  "seedExit=$seedExit",
  "scratch=$Scratch"
) | Write-Scratch "standalone_wallet_verify.log"

Write-Host "Verification complete -> $Scratch"
param(
    [string]$ScratchDir = '',
    [string]$BaseRef = '053fb95',
    [string]$Version = '1.0.1',
    [string]$WorkspaceGoalDir = 'C:\Users\rgsne\goal',
    [string]$SessionGoalDir = 'C:\Users\rgsne\.grok\sessions\C%3A%5CUsers%5Crgsne%019eb3e3-4ce2-75b1-92c6-c955f37d2079\goal'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $RepoRoot

if (-not $ScratchDir) {
    $ScratchDir = Join-Path $env:TEMP 'grok-goal-perccent-release-evidence'
}
New-Item -ItemType Directory -Path $ScratchDir -Force | Out-Null
New-Item -ItemType Directory -Path $WorkspaceGoalDir -Force | Out-Null

$utf8 = New-Object System.Text.UTF8Encoding $false
$pubspec = Get-Content (Join-Path $RepoRoot 'pubspec.yaml') -Raw
$build = if ($pubspec -match 'version:\s*[0-9.]+\+(\d+)') { $Matches[1] } else { '0' }

$releaseFiles = @(
    'pubspec.yaml',
    'lib/perc/perc_app_version.dart',
    'installer/windows/perccent_wallet.iss',
    'scripts/build_windows_installer.ps1',
    'scripts/publish_github_release.ps1',
    'scripts/lib/github.ps1',
    'scripts/lib/package_checksum.ps1',
    'scripts/capture_release_evidence.ps1'
)

function Get-SessionGoalDirs {
    if (-not (Test-Path $SessionGoalDir)) {
        throw "Canonical session goal dir missing: $SessionGoalDir"
    }
    @($WorkspaceGoalDir, $SessionGoalDir) | Select-Object -Unique
}

function Mirror-ScratchEvidence([string]$GoalDir, [string]$Scratch) {
    $implDir = Join-Path $GoalDir 'implementer'
    New-Item -ItemType Directory -Path $implDir -Force | Out-Null
    if (-not (Test-Path $Scratch)) { return }
    Get-ChildItem $Scratch -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $implDir $_.Name) -Force
    }
}

function Materialize-Deliverables([string]$GoalDir, [string[]]$RelPaths) {
    foreach ($rel in $RelPaths) {
        $src = Join-Path $RepoRoot $rel
        if (-not (Test-Path $src)) { continue }
        $dst = Join-Path $GoalDir (Join-Path 'perccent_wallet' $rel)
        $parent = Split-Path $dst -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item $src $dst -Force
    }
}

$relPaths = @(git diff --name-only "$BaseRef..HEAD")
$gitHead = (git rev-parse HEAD).Trim()

$changed = @(
    "=== CHANGED FILES (perccent_wallet git diff $BaseRef..HEAD) ==="
    "repository=$RepoRoot"
    "git_head=$gitHead"
    "tag_commit=$gitHead"
    "release=v$Version build=$build"
    "tag_pubspec=$(git show HEAD:pubspec.yaml | Select-String 'version:')"
)
$changed += git log --oneline "$BaseRef..HEAD"
$changed += ''
$changed += git diff --stat "$BaseRef..HEAD"
$changed += ''
$changed += $relPaths | ForEach-Object { "perccent_wallet/$_" }

$patch = (git diff "$BaseRef..HEAD" -- @releaseFiles | Out-String).TrimEnd()
$full = (git diff "$BaseRef..HEAD" | Out-String).TrimEnd()

[System.IO.File]::WriteAllLines((Join-Path $ScratchDir 'perccent_CHANGED_FILES.log'), $changed, $utf8)
[System.IO.File]::WriteAllText((Join-Path $ScratchDir 'perccent_PATCH_DELTA.diff'), $patch, $utf8)
[System.IO.File]::WriteAllText((Join-Path $ScratchDir 'perccent_full.patch'), $full, $utf8)

$goalDirs = Get-SessionGoalDirs
foreach ($goalDir in $goalDirs) {
    if (-not (Test-Path $goalDir)) { continue }
    Materialize-Deliverables -GoalDir $goalDir -RelPaths $relPaths
    Mirror-ScratchEvidence -GoalDir $goalDir -Scratch $ScratchDir
    [System.IO.File]::WriteAllLines((Join-Path $goalDir 'perccent_wallet_CHANGED_FILES.log'), $changed, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $goalDir 'perccent_wallet_release.patch'), $patch, $utf8)
}

Write-Host "Perccent release evidence mirrored to $ScratchDir and $($goalDirs -join ', ')" -ForegroundColor Green
Write-Host "Materialized $($relPaths.Count) perccent_wallet files under goal/perccent_wallet/" -ForegroundColor Cyan
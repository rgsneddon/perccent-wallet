# Build Windows installer and publish a GitHub Release with platform binaries.
param(
    [string]$Version = '',
    [string]$RepoName = 'perccent-wallet',
    [string]$ReleaseNotes = '',
    [switch]$SkipBuild,
    [switch]$SkipTests,
    [switch]$RecreateRelease
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot\lib\github.ps1"
. "$PSScriptRoot\lib\package_checksum.ps1"

Set-Location $Root
Ensure-GitIdentity -Root $Root

if (-not $Version) {
    $pubspec = Get-Content (Join-Path $Root 'pubspec.yaml') -Raw
    if ($pubspec -match 'version:\s*([0-9.]+)\+(\d+)') {
        $Version = $Matches[1]
    } else {
        throw 'Could not read version from pubspec.yaml'
    }
}

$tag = if ($Version -match '^v') { $Version } else { "v$Version" }
$versionNoV = $tag -replace '^v', ''
$owner = Get-GitHubOwner -Root $Root

if (-not $SkipTests) {
    flutter test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not $SkipBuild) {
    & "$PSScriptRoot\build_installers.ps1"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$releaseDir = Join-Path $Root "build\release\$tag"
if (Test-Path $releaseDir) { Remove-Item $releaseDir -Recurse -Force }
New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null

$installerDir = Join-Path $Root "build\downloads\v$versionNoV"
if (-not (Test-Path $installerDir)) {
    throw "Missing installer packages: $installerDir"
}

& "$PSScriptRoot\audit_dependencies.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$PSScriptRoot\scan_release_artifacts.ps1" -Version $versionNoV
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Get-ChildItem $installerDir -File | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $releaseDir $_.Name) -Force
}

$defaultNotes = @"
Perccent Wallet $tag

Standalone PERC wallet — send, receive, stake, and sync on the Chronoflux Principia chain.

Windows: ``perccent-wallet-v$versionNoV-windows-x64-setup.exe``
Android: ``perccent-wallet-v$versionNoV-android-setup.apk``
iOS: ``perccent-wallet-v$versionNoV-ios-setup.ipa`` (when built on macOS with Xcode signing)
Verify downloads with attached ``.sha256`` / ``.sha512`` checksum files (minimum SHA-256)
"@
$notes = if ($ReleaseNotes.Trim()) { $ReleaseNotes.Trim() } else { $defaultNotes }

$env:GH_TOKEN = Get-GitHubToken

$assets = Get-ChildItem $releaseDir -File | ForEach-Object { $_.FullName }

Write-Host ''
Write-Host "Publishing GitHub Release $tag on $owner/$RepoName" -ForegroundColor Cyan

$releaseExists = $false
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
gh release view $tag --repo "$owner/$RepoName" 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { $releaseExists = $true }
$ErrorActionPreference = $prevEap

if ($releaseExists -and $RecreateRelease) {
    Write-Host "Deleting release $tag for clean recreate." -ForegroundColor Yellow
    gh release delete $tag --repo "$owner/$RepoName" --yes --cleanup-tag=false
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $releaseExists = $false
}

$notesFile = Join-Path $env:TEMP "perccent-release-notes-$tag.md"
[System.IO.File]::WriteAllText($notesFile, $notes, (New-Object System.Text.UTF8Encoding $false))

if ($releaseExists) {
    gh release edit $tag --repo "$owner/$RepoName" --notes-file $notesFile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    gh release upload $tag --repo "$owner/$RepoName" --clobber @assets
} else {
    gh release create $tag `
        --repo "$owner/$RepoName" `
        --title "Perccent Wallet $tag" `
        --notes-file $notesFile `
        @assets
}

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host "Release published: https://github.com/$owner/$RepoName/releases/tag/$tag" -ForegroundColor Green
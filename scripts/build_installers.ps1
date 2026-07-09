# Build versioned Windows setup.exe and Android APK packages for Perccent Wallet.
param(
    [switch]$SkipWindowsBuild,
    [switch]$SkipApkBuild
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

& "$PSScriptRoot\build_windows_installer.ps1" -SkipWindowsBuild:$SkipWindowsBuild
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$PSScriptRoot\build_android_installer.ps1" -SkipApkBuild:$SkipApkBuild
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$PSScriptRoot\audit_dependencies.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$PSScriptRoot\scan_release_artifacts.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host 'All Perccent Wallet installers built.' -ForegroundColor Green
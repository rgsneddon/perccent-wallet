# Verify SHA-256/SHA-512 sidecars for staged Perccent Wallet download packages.
param(
    [string]$Version = '',
    [string]$SourceDir = ''
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot\lib\package_checksum.ps1"
Set-Location $Root

if (-not $Version) {
    $pubspec = Get-Content (Join-Path $Root 'pubspec.yaml') -Raw
    if ($pubspec -match 'version:\s*([0-9.]+)\+(\d+)') {
        $Version = $Matches[1]
    } else {
        throw 'Could not read version from pubspec.yaml'
    }
}

if (-not $SourceDir) {
    $SourceDir = Join-Path $Root "build\downloads\v$Version"
}

if (-not (Test-Path $SourceDir)) {
    throw "Missing download packages: $SourceDir"
}

Test-VersionPackageChecksums -VersionDir $SourceDir -RequireSidecars
Write-Host "Checksum verification passed for v$Version" -ForegroundColor Green
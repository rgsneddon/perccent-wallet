# Build a versioned Android APK package with SHA-256 checksum (mirrors Windows installer flow).
param(
    [string]$Version = '',
    [string]$Build = '',
    [switch]$SkipApkBuild
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot\lib\package_checksum.ps1"

Set-Location $Root

if (-not $Version -or -not $Build) {
    $pubspec = Get-Content (Join-Path $Root 'pubspec.yaml') -Raw
    if ($pubspec -match 'version:\s*([0-9.]+)\+(\d+)') {
        if (-not $Version) { $Version = $Matches[1] }
        if (-not $Build) { $Build = $Matches[2] }
    } else {
        throw 'Could not read version from pubspec.yaml'
    }
}

$apkSrc = Join-Path $Root 'build\app\outputs\flutter-apk\app-release.apk'

if (-not $SkipApkBuild) {
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    flutter build apk --release 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            $msg = $_.ToString()
            if ($msg -match 'Warning:|Kotlin Gradle Plugin|Built-in Kotlin|plugin author|RemoteException|Future versions|KGP|incompatible-kotlin|changelogs of these plugins') {
                Write-Host $msg -ForegroundColor Yellow
            } else {
                Write-Error $_
            }
        } else { $_ }
    }
    $ErrorActionPreference = $prevEap
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not (Test-Path $apkSrc)) {
    throw "Missing Android release APK: $apkSrc"
}

function Get-ApkAbis([string]$ApkPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ApkPath)
    try {
        $abis = $zip.Entries |
            Where-Object { $_.FullName -match '^lib/([^/]+)/libapp\.so$' } |
            ForEach-Object { $Matches[1] } |
            Sort-Object -Unique
        return ($abis -join ', ')
    } finally {
        $zip.Dispose()
    }
}

$owner = 'rgsneddon'
$publishedName = "perccent-wallet-v$Version-android-setup.apk"
$stagingDir = Join-Path $Root "build\installer\android"
$versionedDir = Join-Path $Root "build\downloads\v$Version"
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
New-Item -ItemType Directory -Path $versionedDir -Force | Out-Null

$stagingPath = Join-Path $stagingDir $publishedName
$publishedPath = Join-Path $versionedDir $publishedName
Copy-Item $apkSrc $stagingPath -Force
Copy-Item $stagingPath $publishedPath -Force

$abis = Get-ApkAbis $publishedPath
$releaseUrl = "https://github.com/$owner/perccent-wallet/releases/download/v$Version/$publishedName"

$signed = Write-PackageChecksumSidecar `
    -PackagePath $publishedPath `
    -Version $Version `
    -Build $Build `
    -Platform 'android' `
    -Url $releaseUrl `
    -ExtraMetadata @("abis=$abis", 'minSdk=23')

Write-VersionChecksumManifest -VersionDir $versionedDir -BaseUrl $releaseUrl.Replace("/$publishedName", '') | Out-Null

Write-Host ''
Write-Host "Android installer v$Version (build $Build) ready:" -ForegroundColor Green
Write-Host "  $publishedPath"
Write-Host "  $($signed.Sha256Path)"
Write-Host "  $($signed.Sha512Path)"
Write-Host "  ABIs: $abis"
Write-Host "SHA-256: $($signed.Sha256)" -ForegroundColor Cyan
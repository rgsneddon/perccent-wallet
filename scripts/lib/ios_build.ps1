# Shared helpers for Flutter iOS IPA packaging.

function Test-IosBuildHost {
    if ($IsMacOS) { return $true }
    if ($env:GITHUB_ACTIONS -eq 'true' -and $env:RUNNER_OS -eq 'macOS') { return $true }
    return $false
}

function Get-FlutterIpaSource {
    param(
        [Parameter(Mandatory = $true)][string]$Root
    )

    $ipaDir = Join-Path $Root 'build\ios\ipa'
    if (Test-Path $ipaDir) {
        $ipa = Get-ChildItem $ipaDir -Filter '*.ipa' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($ipa) { return $ipa.FullName }
    }
    return $null
}

function Invoke-FlutterIpaBuild {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [string]$ExportOptionsPlist = ''
    )

    if (-not $ExportOptionsPlist) {
        $ExportOptionsPlist = Join-Path $Root 'ios\ExportOptions.plist'
    }
    if (-not (Test-Path $ExportOptionsPlist)) {
        throw "Missing ExportOptions.plist: $ExportOptionsPlist"
    }

    flutter build ipa --release "--export-options-plist=$ExportOptionsPlist"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
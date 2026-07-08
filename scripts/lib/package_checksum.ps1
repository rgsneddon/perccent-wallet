# Shared SHA-256 / SHA-512 checksum helpers for downloadable packages.

function Get-PackageFileHash {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [ValidateSet('SHA256', 'SHA512')][string]$Algorithm = 'SHA256'
    )
    if (-not (Test-Path $Path)) {
        throw "Missing package file: $Path"
    }
    return (Get-FileHash -Path $Path -Algorithm $Algorithm).Hash.ToLowerInvariant()
}

function Write-PackageChecksumSidecar {
    param(
        [Parameter(Mandatory = $true)][string]$PackagePath,
        [string]$Version = '',
        [string]$Build = '',
        [string]$Platform = '',
        [string]$Url = '',
        [string[]]$ExtraMetadata = @()
    )

    if (-not (Test-Path $PackagePath)) {
        throw "Missing package file: $PackagePath"
    }

    $fileName = [IO.Path]::GetFileName($PackagePath)
    $sha256 = Get-PackageFileHash -Path $PackagePath -Algorithm SHA256
    $sha512 = Get-PackageFileHash -Path $PackagePath -Algorithm SHA512

    $sha256Path = "$PackagePath.sha256"
    $sha512Path = "$PackagePath.sha512"

    $meta = [System.Collections.Generic.List[string]]::new()
    $meta.Add("$sha256  $fileName")
    $meta.Add("algorithm=SHA256")
    $meta.Add("algorithm_secondary=SHA512")
    $meta.Add("sha512=$sha512")
    if ($Version) { $meta.Add("version=$Version") }
    if ($Build) { $meta.Add("build=$Build") }
    if ($Platform) { $meta.Add("platform=$Platform") }
    if ($Url) { $meta.Add("url=$Url") }
    foreach ($line in $ExtraMetadata) {
        if ($line) { $meta.Add($line) }
    }
    $meta | Set-Content -Path $sha256Path -Encoding utf8

    @(
        "$sha512  $fileName",
        'algorithm=SHA512',
        "sha256=$sha256"
    ) | Set-Content -Path $sha512Path -Encoding utf8

    return [PSCustomObject]@{
        FileName = $fileName
        Path = $PackagePath
        Sha256 = $sha256
        Sha512 = $sha512
        Sha256Path = $sha256Path
        Sha512Path = $sha512Path
    }
}

function Write-VersionChecksumManifest {
    param(
        [Parameter(Mandatory = $true)][string]$VersionDir,
        [string]$BaseUrl = ''
    )

    if (-not (Test-Path $VersionDir)) {
        throw "Missing version directory: $VersionDir"
    }

    $packages = Get-ChildItem $VersionDir -File | Where-Object {
        $_.Extension -notin '.sha256', '.sha512', '.json' -and
        $_.Name -notlike 'CHECKSUMS*'
    }

    $sha256Lines = [System.Collections.Generic.List[string]]::new()
    $sha512Lines = [System.Collections.Generic.List[string]]::new()
    $entries = @()

    foreach ($pkg in $packages) {
        $sha256 = Get-PackageFileHash -Path $pkg.FullName -Algorithm SHA256
        $sha512 = Get-PackageFileHash -Path $pkg.FullName -Algorithm SHA512
        $sha256Lines.Add("$sha256  $($pkg.Name)")
        $sha512Lines.Add("$sha512  $($pkg.Name)")
        $entries += [PSCustomObject]@{
            file = $pkg.Name
            bytes = $pkg.Length
            sha256 = $sha256
            sha512 = $sha512
            url = if ($BaseUrl) { "$BaseUrl/$($pkg.Name)" } else { '' }
        }
    }

    $sha256Manifest = Join-Path $VersionDir 'CHECKSUMS.sha256'
    $sha512Manifest = Join-Path $VersionDir 'CHECKSUMS.sha512'
    $sha256Lines | Set-Content -Path $sha256Manifest -Encoding utf8
    $sha512Lines | Set-Content -Path $sha512Manifest -Encoding utf8

    $jsonManifest = Join-Path $VersionDir 'checksums.json'
    @{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        algorithms = @('SHA256', 'SHA512')
        minimumAlgorithm = 'SHA256'
        packages = $entries
    } | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonManifest -Encoding utf8

    return $entries
}
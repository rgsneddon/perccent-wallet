# Keep perccent-wallet gh-pages download landing pages in sync.
# gh-pages carries checksum manifests only; full installers live on GitHub Releases.

function Invoke-GitCommand {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Command,
        [Parameter(Mandatory = $true)][string]$FailureMessage
    )

    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $Command 2>&1 | Out-Null
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $prevEap
    if ($exitCode -ne 0) {
        throw "$FailureMessage (exit $exitCode)"
    }
}

function Sync-GhPagesBranch {
    param(
        [string]$Branch = 'gh-pages',
        [string]$Remote = 'origin'
    )

    Invoke-GitCommand { git fetch $Remote $Branch } "git fetch $Remote $Branch failed"

    $tracking = "$Remote/$Branch"
    $current = git branch --show-current 2>$null
    if ($current -eq $Branch) {
        Invoke-GitCommand { git reset --hard $tracking } "git reset --hard $tracking failed"
    } elseif (git show-ref --verify --quiet "refs/heads/$Branch") {
        Invoke-GitCommand { git checkout -f $Branch } "git checkout -f $Branch failed"
        Invoke-GitCommand { git reset --hard $tracking } "git reset --hard $tracking failed"
    } elseif (git show-ref --verify --quiet "refs/remotes/$tracking") {
        Invoke-GitCommand { git checkout -B $Branch $tracking } "git checkout -B $Branch failed"
    } else {
        Invoke-GitCommand { git checkout --orphan $Branch } "git checkout --orphan $Branch failed"
        git rm -rf . 2>$null | Out-Null
    }
}

function Get-GhPagesChecksumArtifacts {
    param(
        [Parameter(Mandatory = $true)][string]$StagedDir
    )

    Get-ChildItem $StagedDir -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Extension -in '.sha256', '.sha512', '.json' -or $_.Name -like 'CHECKSUMS*'
    }
}
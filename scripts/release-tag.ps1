# ============================================================================
# release-tag.ps1 — Academix v13.2 Automated Release Tagging
# Creates versioned git tags with changelog entries
# Usage: .\scripts\release-tag.ps1 -Version "v13.3" -Message "Release notes"
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"
$ROOT = Split-Path $PSScriptRoot -Parent

# Validate version format
if ($Version -notmatch '^v\d+\.\d+(\.\d+)?$') {
    Write-Host "ERROR: Version must match format v1.0 or v1.0.0" -ForegroundColor Red
    exit 1
}

# Check if tag already exists
$existingTag = git tag -l $Version 2>$null
if ($existingTag) {
    Write-Host "ERROR: Tag $Version already exists" -ForegroundColor Red
    exit 1
}

# Ensure clean working tree
$dirty = git status --porcelain 2>$null
if ($dirty) {
    Write-Host "ERROR: Working tree is not clean. Commit or stash changes first." -ForegroundColor Red
    exit 1
}

# Create annotated tag
Write-Host "Creating release tag: $Version" -ForegroundColor Cyan
git tag -a $Version -m "$Message"

# Update CHANGELOG.md
$changelogPath = Join-Path $ROOT "CHANGELOG.md"
if (Test-Path $changelogPath) {
    $changelog = Get-Content $changelogPath -Raw
    $today = Get-Date -Format "yyyy-MM-dd"
    $newEntry = "`n## [$Version] — $today`n`n### Added`n- $Message`n"
    
    # Insert after [Unreleased] section
    if ($changelog -match '\[Unreleased\]') {
        $changelog = $changelog -replace '(\[Unreleased\].*?)(---)', "`$1$newEntry`n---"
    } else {
        $changelog = $newEntry + "`n" + $changelog
    }
    
    $changelog | Out-File -FilePath $changelogPath -Encoding utf8
    Write-Host "CHANGELOG.md updated" -ForegroundColor Green
}

# Push tag
Write-Host "`nPushing tag to remote..." -ForegroundColor Cyan
git push origin $Version

# Summary
Write-Host "`n══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  RELEASE $Version CREATED" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  Tag: $Version" -ForegroundColor Green
Write-Host "  Message: $Message" -ForegroundColor Green
Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor Green
Write-Host "  Commit: $(git rev-parse --short HEAD)" -ForegroundColor Green

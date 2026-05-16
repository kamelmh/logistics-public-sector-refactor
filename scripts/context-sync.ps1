param (
    [Parameter()] [switch]$UpdateOnly
)

$StateFile = ".opencode\context-state.json"
$CriticalPaths = @(
    ".opencode\bootstrap\MASTER_BOOTSTRAP.xml",
    ".opencode\erp-context-compact.md",
    ".crossflow\HANDOFF.md",
    "CLAUDE.md",
    "Software_Surgical_Edit\*.xml"
)

# Initialize State as a Hashtable
if (Test-Path $StateFile) {
    $RawJson = Get-Content $StateFile -Raw
    $StateObj = $RawJson | ConvertFrom-Json
    $StateFiles = @{}
    if ($StateObj.files) {
        foreach ($Prop in $StateObj.files.PSObject.Properties) {
            $StateFiles[$Prop.Name] = $Prop.Value
        }
    }
} else {
    $StateFiles = @{}
}

$DirtyFiles = @()

foreach ($PathPattern in $CriticalPaths) {
    $Files = Get-ChildItem -Path $PathPattern -ErrorAction SilentlyContinue
    foreach ($File in $Files) {
        $FullPath = $File.FullName
        $RelativePath = Resolve-Path -Path $FullPath -Relative
        
        # Calculate SHA256 hash
        $Hash = (Get-FileHash -Path $FullPath -Algorithm SHA256).Hash
        
        if (-not $StateFiles.ContainsKey($RelativePath) -or $StateFiles[$RelativePath] -ne $Hash) {
            $DirtyFiles += $RelativePath
            $StateFiles[$RelativePath] = $Hash
        }
    }
}

if ($DirtyFiles.Count -gt 0) {
    # Convert Hashtable back to PSObject for JSON export
    $ExportObj = [PSCustomObject]@{
        files = $StateFiles
    }
    $ExportObj | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    Write-Host "Found $($DirtyFiles.Count) changed files:" -ForegroundColor Yellow
    $DirtyFiles | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "Context is up-to-date. No changes detected." -ForegroundColor Green
}

if (-not $UpdateOnly) {
    return $DirtyFiles
}

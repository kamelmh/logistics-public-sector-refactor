param(
    [Parameter(Mandatory=$true)]
    [string]$TargetFile
)

$backupDir = Join-Path $PSScriptRoot "..\backups"
Write-Host "DEBUG: backupDir is $backupDir" -ForegroundColor Cyan

if (-not (Test-Path $backupDir)) {
    Write-Error "Backup directory does not exist: $backupDir"
    exit 1
}

# Search recursively for the latest .docx
$latestBackup = Get-ChildItem -Path $backupDir -Filter "*.docx" -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestBackup) {
    Write-Error "No backups found in $backupDir"
    exit 1
}

Write-Host "Found latest backup: $($latestBackup.FullName) ($($latestBackup.Length) bytes)" -ForegroundColor Cyan
$confirm = Read-Host "Do you want to restore $TargetFile from this backup? (y/n)"

if ($confirm -eq 'y') {
    Copy-Item $latestBackup.FullName $TargetFile -Force
    Write-Host "Restored $TargetFile from $($latestBackup.Name)" -ForegroundColor Green
} else {
    Write-Host "Restore cancelled." -ForegroundColor Yellow
}

# Academix v13.2 — Lock API Keys (DPAPI encryption)
# Encrypts plaintext API keys from scripts-tools/_api-keys/
# Output: %USERPROFILE%\.academix-<name>.xml (per-user DPAPI)
# Run once. Plaintext files are deleted after successful encryption.
# Compatible with Get-Secret() in profile-common.ps1

$keyDir = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts-tools\_api-keys"
if (-not (Test-Path $keyDir)) { Write-Host "No _api-keys directory found." -ForegroundColor Yellow; exit 0 }

$files = Get-ChildItem "$keyDir\*.txt" -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { Write-Host "No .txt files to encrypt." -ForegroundColor Green; exit 0 }

$ok = 0; $fail = 0
foreach ($f in $files) {
    $name = $f.BaseName -replace ' ', '-'
    $plain = (Get-Content $f.FullName -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace($plain)) { Write-Host "  [SKIP] $($f.Name) — empty"; continue }
    try {
        $secure = $plain | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential("key", $secure)
        $cred | Export-Clixml "$env:USERPROFILE\.academix-$name.xml" -Force
        Write-Host "  [OK]  Encrypted: $($f.Name)" -ForegroundColor Green
        $ok++
    } catch { Write-Host "  [FAIL] $($f.Name): $_" -ForegroundColor Red; $fail++ }
}

Write-Host "`nEncrypted: $ok | Failed: $fail" -ForegroundColor Cyan
if ($ok -gt 0 -and $fail -eq 0) {
    Write-Host "Delete plaintext files? [y/N] " -NoNewline -ForegroundColor Yellow
    $confirm = Read-Host
    if ($confirm -eq 'y') {
        Remove-Item "$keyDir\*.txt" -Force
        Write-Host "Plaintext files deleted." -ForegroundColor Green
    }
}

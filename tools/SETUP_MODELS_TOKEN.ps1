<#
.SYNOPSIS
    One-time setup for GitHub Models token.
    Saves the token to your PowerShell profile so gh-models works everywhere.

.DESCRIPTION
    Prompts you to paste your GitHub PAT (with models permission),
    saves it to your PowerShell profile ($PROFILE), and tests it.

    If you don't have a token yet:
    1. Go to https://github.com/settings/tokens?type=beta
    2. Click 'Generate new token' → 'Fine-grained token'
    3. Name: gh-models-mobile
    4. Repository access: Public repositories only
    5. Account permissions → Models → Read
    6. Generate and paste the token below
#>

Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   GitHub Models — One-Time Token Setup       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check existing
$existing = $env:GH_MODELS_TOKEN
if ($existing) {
    Write-Host "✅ GH_MODELS_TOKEN already set in this session ($($existing.Length) chars)" -ForegroundColor Green
    $overwrite = Read-Host "Overwrite? (y/N)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "Keeping existing token. Test with: .\gh-models.ps1 env" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Paste your GitHub PAT with 'models:read' permission:" -ForegroundColor Yellow
Write-Host "(Right-click to paste, then press Enter twice)" -ForegroundColor DarkGray
$token = Read-Host ""

if (-not $token) {
    Write-Host "❌ No token entered." -ForegroundColor Red
    exit 1
}

# Test the token
Write-Host "`nTesting token..." -NoNewline -ForegroundColor DarkGray
try {
    $headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
    $models = Invoke-RestMethod -Uri "https://models.inference.ai.azure.com/models" -Headers $headers -ErrorAction Stop
    Write-Host " ✅ OK! $($models.data.Count) models available" -ForegroundColor Green
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    Write-Host " ❌ Failed (HTTP $code)" -ForegroundColor Red
    if ($code -eq 401 -or $code -eq 403) {
        Write-Host "The token needs the 'models' permission." -ForegroundColor Red
        Write-Host "Create a new one at: https://github.com/settings/tokens?type=beta" -ForegroundColor Yellow
    }
    exit 1
}

# Save to PowerShell profile
$profileLine = "`$env:GH_MODELS_TOKEN = '$token'"

# Check if already in profile
$profileContent = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { '' }
if ($profileContent -match 'GH_MODELS_TOKEN') {
    Write-Host "Found existing GH_MODELS_TOKEN in profile. Updating..." -ForegroundColor Yellow
    $profileContent = $profileContent -replace '\$env:GH_MODELS_TOKEN = ''.*''', $profileLine
} else {
    $profileContent += "`r`n`r`n# GitHub Models token (added by SETUP_MODELS_TOKEN.ps1)`r`n$profileLine`r`n"
}

$profileContent | Out-File $PROFILE -Encoding utf8
Write-Host "✅ Saved to PowerShell profile: $PROFILE" -ForegroundColor Green

# Set for current session
$env:GH_MODELS_TOKEN = $token
Write-Host "✅ Set for current session" -ForegroundColor Green

Write-Host "`n── Quick test ──" -ForegroundColor Cyan
try {
    $body = @{ model = "gpt-4o-mini"; messages = @(@{ role = "user"; content = "Say hello in 5 words" }) } | ConvertTo-Json -Compress
    $r = Invoke-RestMethod -Uri "https://models.inference.ai.azure.com/chat/completions" -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Method Post -Body $body -ErrorAction Stop
    Write-Host "✅ Chat works! Response: $($r.choices[0].message.content)" -ForegroundColor Green
    Write-Host "   Tokens: in=$($r.usage.prompt_tokens) out=$($r.usage.completion_tokens)" -ForegroundColor DarkGray
} catch {
    Write-Host "❌ Chat test failed: $_" -ForegroundColor Red
}

Write-Host "`n── Done! You can now use: ──" -ForegroundColor Green
Write-Host "  .\gh-models.ps1 chat -Prompt 'your question'" -ForegroundColor White
Write-Host "  .\gh-models.ps1 chat                    # Interactive" -ForegroundColor White
Write-Host "  .\gh-models.ps1 models                  # List models" -ForegroundColor White
Write-Host "  .\gh-models.ps1 env                     # Check status" -ForegroundColor White
Write-Host ""
Write-Host "For mobile (lite version):" -ForegroundColor Green
Write-Host "  pwsh -c `"& '.\gh-models-lite.ps1' -p 'your question'`"" -ForegroundColor White

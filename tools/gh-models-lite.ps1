<#
.SYNOPSIS
    GitHub Models Lite — ultra-portable, single-prompt version for mobile/SSH.
    Minimal typing, maximum results. Best used from phone terminal apps.

.EXAMPLE
    # From phone SSH client:
    pwsh -c "& '.\gh-models-lite.ps1' -p 'Hello world'"

    # Or with token inline:
    pwsh -c "`$env:GH_MODELS_TOKEN='ghp_xxx'; & '.\gh-models-lite.ps1' -p 'Hello'"

    # List models:
    pwsh -c "& '.\gh-models-lite.ps1' -m"

.PARAMETER p
    Prompt/question (one-shot).

.PARAMETER m
    List available models (mutually exclusive with -p).

.PARAMETER model
    Model name. Default: gpt-4o-mini
.PARAMETER t
    GitHub PAT token. Falls back to $env:GH_MODELS_TOKEN
#>

param(
    [string]$p = '',
    [switch]$m,
    [string]$model = 'gpt-4o-mini',
    [string]$t = ''
)

# Resolve token
$token = if ($t) { $t } elseif ($env:GH_MODELS_TOKEN) { $env:GH_MODELS_TOKEN } else { try { gh auth token 2>$null } catch { '' } }
if (-not $token) { Write-Host "❌ Need token. Set `$env:GH_MODELS_TOKEN or pass -t" -ForegroundColor Red; exit 1 }

$headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$base = 'https://models.inference.ai.azure.com'

# -m flag: list models
if ($m) {
    $r = Invoke-RestMethod -Uri "$base/models" -Headers $headers -ErrorAction Stop
    Write-Host "── GitHub Models Free ──" -ForegroundColor Cyan
    $r.data | ForEach-Object { Write-Host "  $($_.name)" -ForegroundColor White }
    exit 0
}

# One-shot prompt
if (-not $p) { Write-Host "Usage: -p 'question' or -m to list models"; exit 1 }

$body = @{
    model = $model
    messages = @(@{ role = 'user'; content = $p })
    temperature = 0.7
    max_tokens = 2000
} | ConvertTo-Json -Compress

try {
    $r = Invoke-RestMethod -Uri "$base/chat/completions" -Headers $headers -Method Post -Body $body -ErrorAction Stop
    Write-Host $r.choices[0].message.content -ForegroundColor White
    if ($r.usage) { Write-Host "`n── in:$($r.usage.prompt_tokens) out:$($r.usage.completion_tokens)" -ForegroundColor DarkGray }
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 401 -or $code -eq 403) { Write-Host "❌ Token needs 'models' permission. Create one at: https://github.com/settings/tokens?type=beta" -ForegroundColor Red }
    elseif ($code -eq 429) { Write-Host "⏳ Rate limited. Wait a minute." -ForegroundColor Yellow }
    else { Write-Host "❌ Error: $_" -ForegroundColor Red }
}

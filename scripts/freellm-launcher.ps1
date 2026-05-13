param(
    [ValidateSet("start","stop","restart","status","add-key")]
    [string]$Action = "status"
)

$FREELM_DIR = "$env:USERPROFILE\.opencode\plugins\freellm"
$API_DIR = "$FREELM_DIR\packages\api-server"
$PORT = 3000
$LOG = "$FREELM_DIR\freellm.log"
$ERR_LOG = "$FREELM_DIR\freellm-error.log"
$ENV_FILE = "$FREELM_DIR\.env"

function Get-Status {
    try {
        $r = Invoke-RestMethod "http://localhost:$PORT/v1/models" -TimeoutSec 3
        $status = @{ running = $true; models = $r.data.Count }
        $providers = $r.data | Group-Object owned_by
        $status.providers = $providers | ForEach-Object { "$($_.Name):$($_.Count)" }
        return $status
    } catch {
        return @{ running = $false }
    }
}

switch ($Action) {
    "start" {
        $s = Get-Status
        if ($s.running) { Write-Output "FreeLLM already running on port $PORT"; return }

        if (-not (Test-Path "$API_DIR\dist\index.mjs")) {
            Write-Output "Building FreeLLM..."
            Push-Location $FREELM_DIR
            pnpm install --filter @workspace/api-server --no-frozen-lockfile 2>$null
            Pop-Location
            Push-Location $API_DIR
            pnpm run build
            Pop-Location
        }

        $proc = Start-Process -NoNewWindow -FilePath "node" -ArgumentList "--env-file=../../.env --enable-source-maps ./dist/index.mjs" -WorkingDirectory $API_DIR -RedirectStandardOutput $LOG -RedirectStandardError $ERR_LOG -PassThru
        Start-Sleep -Seconds 4
        $s = Get-Status
        if ($s.running) {
            Write-Output "FreeLLM started on port $PORT — $($s.models) models"
        } else {
            Write-Output "Failed to start. Check: $ERR_LOG"
        }
    }

    "stop" {
        $procs = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "freellm" -or $_.CommandLine -match "index.mjs" }
        if (-not $procs) { Write-Output "FreeLLM not running"; return }
        $procs | Stop-Process -Force
        Write-Output "FreeLLM stopped"
    }

    "restart" {
        & $PSCommandPath stop
        Start-Sleep -Seconds 1
        & $PSCommandPath start
    }

    "status" {
        $s = Get-Status
        if ($s.running) {
            Write-Output "FreeLLM: RUNNING (port $PORT)"
            Write-Output "Models: $($s.models) available"
            Write-Output "Providers: $($s.providers -join ', ')"
        } else {
            Write-Output "FreeLLM: STOPPED"
            if (Test-Path $ERR_LOG) {
                $err = Get-Content $ERR_LOG -Raw
                if ($err) { Write-Output "Last error: $err" }
            }
        }
    }

    "add-key" {
        Write-Output "Add a new provider key to FreeLLM .env"
        Write-Output ""
        Write-Output "Available providers to register (all free, no credit card):"
        Write-Output "  1) NVIDIA NIM    → https://build.nvidia.com          (Llama 3.3 70B, Nemotron 70B, ~40 req/min)"
        Write-Output "  2) Cerebras      → https://cloud.cerebras.ai         (GPT-OSS 120B, Qwen3 235B, ~30 req/min)"
        Write-Output "  3) Cloudflare    → https://dash.cloudflare.com       (Kimi K2, Llama 3.3 70B, ~20 req/min)"
        Write-Output "  4) GitHub Models → https://github.com/settings/tokens (GPT-4o-mini, Phi-4, ~15 req/min)"
        Write-Output "  5) Mistral       → https://console.mistral.ai        (Mistral Large/Small, ~5 req/min)"
        Write-Output "  6) Completions.me → https://completions.me           (Claude Opus 4.6, GPT-5.2, free, no CC)"
        Write-Output ""
        Write-Output "Add keys to: $ENV_FILE"
        Write-Output "Format: PROVIDER_KEY=your_key_here"
        Write-Output "Then run: freellm-launcher.ps1 restart"
    }
}

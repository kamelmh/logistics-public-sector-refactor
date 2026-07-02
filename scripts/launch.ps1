# Academix Launcher — Start FCC Proxy + OpenCode
# Usage: .\scripts\launch.ps1 [model]
# Example: .\scripts\launch.ps1 nvidia
#          .\scripts\launch.ps1 local
#          .\scripts\launch.ps1 openrouter

param(
    [string]$Model = "nvidia",
    [switch]$SkipFcc,
    [switch]$ClaudeCode
)

$ProjectRoot = "C:\Users\Admin\Logistics.Public.Sector.Refactor"

# Model mapping
$Models = @{
    "nvidia"    = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "openrouter"= "fcc/open_router/openrouter/free"
    "groq"      = "fcc/groq/llama-3.3-70b-versatile"
    "local"     = "ollama/phi4-mini:latest"
    "localbig"  = "ollama/llama3.3:70b"
    "gemini"    = "fcc/gemini/models/gemini-3.1-flash-lite"
}

$SelectedModel = $Models[$Model]
if (-not $SelectedModel) {
    Write-Host "Unknown model: $Model" -ForegroundColor Red
    Write-Host "Available: $($Models.Keys -join ', ')" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Academix v13.4 Launcher ===" -ForegroundColor Cyan
Write-Host "Model: $SelectedModel" -ForegroundColor Green

# Start FCC proxy if not skipped
if (-not $SkipFcc) {
    $fccRunning = Get-Process -Name "fcc-server" -ErrorAction SilentlyContinue
    if (-not $fccRunning) {
        Write-Host "Starting FCC Proxy..." -ForegroundColor Yellow
        Start-Process -NoNewWindow fcc-server
        Start-Sleep -Seconds 3
        
        try {
            $health = Invoke-RestMethod -Uri "http://127.0.0.1:8082/health"
            Write-Host "FCC Proxy: $($health.status)" -ForegroundColor Green
        } catch {
            Write-Host "FCC Proxy failed to start" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "FCC Proxy already running" -ForegroundColor Green
    }
}

# Launch OpenCode or Claude Code
Write-Host "Launching OpenCode..." -ForegroundColor Yellow
Set-Location $ProjectRoot

if ($ClaudeCode) {
    Write-Host "Using Claude Code via FCC proxy..." -ForegroundColor Yellow
    fcc-claude
} else {
    opencode -m $SelectedModel
}

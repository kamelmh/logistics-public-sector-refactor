<#
.SYNOPSIS
    GitHub Models Free Tier — portable AI chat & tooling for on-the-go use.
    Uses your GitHub PAT with 'models:read' permission to access 100+ free models.

.DESCRIPTION
    OpenAI-compatible wrapper for the GitHub Models API endpoint.
    Works from anywhere — local, remote SSH (phone/tablet), cloud shell.
    No dependencies beyond PowerShell 7+ and an internet connection.

    Free tier rate limits (Copilot Free account):
      Low tier:  15 req/min, 150 req/day, 8K in / 4K out tokens
      High tier: 10 req/min,  50 req/day, 8K in / 4K out tokens
      Embedding: 15 req/min, 150 req/day, 64K tokens

.PARAMETER Action
    Action to perform: chat, models, stream, env, or config.
    Default: chat

.PARAMETER Prompt
    Single prompt for one-shot mode (non-interactive).

.PARAMETER Model
    Model to use. Default: gpt-4o-mini (free tier, low latency).

.PARAMETER Token
    GitHub PAT with 'models' permission. If not provided, reads from:
    1. $env:GH_MODELS_TOKEN
    2. gh auth token (if authenticated)
    3. $env:GITHUB_TOKEN

.PARAMETER System
    System prompt for chat. Default: "You are a helpful assistant."

.PARAMETER Temperature
    Model temperature (0.0-2.0). Default: 0.7

.PARAMETER MaxTokens
    Maximum response tokens. Default: 2000

.PARAMETER Stream
    Enable streaming response output.

.PARAMETER OutputFile
    Save last response to file.

.EXAMPLE
    # List all available models
    .\gh-models.ps1 models

    # Interactive chat
    .\gh-models.ps1 chat

    # One-shot question
    .\gh-models.ps1 chat -Prompt "What is the capital of Algeria?"

    # Use a specific model with streaming
    .\gh-models.ps1 chat -Model "Phi-4" -Prompt "Explain EOQ" -Stream

    # Save response to file
    .\gh-models.ps1 chat -Prompt "Write a poem" -OutputFile poem.txt

    # Set your token for this session
    $env:GH_MODELS_TOKEN = "github_pat_..."

.NOTES
    Version: 1.0
    Author: Academix v13.2
    Endpoint: https://models.inference.ai.azure.com
#>

param(
    [ValidateSet('chat', 'models', 'stream', 'env', 'config')]
    [string]$Action = 'chat',

    [string]$Prompt = '',

    [string]$Model = 'gpt-4o-mini',

    [string]$Token = '',

    [string]$System = 'You are a helpful assistant. Be concise and accurate.',

    [float]$Temperature = 0.7,

    [int]$MaxTokens = 2000,

    [switch]$Stream,

    [string]$OutputFile = ''
)

# ─── Configuration ─────────────────────────────────────────────────────────────
$Script:ApiBaseUrl = 'https://models.inference.ai.azure.com'
$Script:HistoryFile = Join-Path $env:TEMP 'gh_models_history.json'
$Script:ConfigFile = "$env:USERPROFILE\.gh-models-token"

# Free tier models by category (Copilot Free)
$Script:FreeModels = @{
    'gpt-4o-mini' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Best all-purpose fast model' }
    'gpt-4o'      = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Strong reasoning & vision' }
    'Phi-4'       = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Microsoft, small & capable' }
    'Phi-4-mini-instruct' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Microsoft, ultra-lightweight' }
    'Meta-Llama-3.1-8B-Instruct' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Meta, fast and capable' }
    'Meta-Llama-3.1-70B-Instruct' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Meta, strong reasoning' }
    'Meta-Llama-3.1-405B-Instruct' = @{ Tier = 'High'; RPM = 10; RPD = 50; Description = 'Meta, largest open model' }
    'Mistral-large' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Mistral, enterprise-grade' }
    'Mistral-small' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Mistral, fast & efficient' }
    'Cohere-command-r-plus' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Cohere, RAG-optimized' }
    'Cohere-command-r' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'Cohere, efficient RAG' }
    'AI21-Jamba-1.5-Mini' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'AI21, long context' }
    'AI21-Jamba-1.5-Large' = @{ Tier = 'Low'; RPM = 15; RPD = 150; Description = 'AI21, high quality' }
    'DeepSeek-R1' = @{ Tier = 'High'; RPM = 1; RPD = 8; Description = 'DeepSeek, reasoning (1 req/min)' }
    'Grok-3' = @{ Tier = 'High'; RPM = 1; RPD = 15; Description = 'xAI, latest (1 req/min)' }
    'Grok-3-Mini' = @{ Tier = 'High'; RPM = 2; RPD = 30; Description = 'xAI, fast (2 req/min)' }
}

# ─── Token Resolution ──────────────────────────────────────────────────────────
function Get-ModelsToken {
    if ($Token) { return $Token }
    if ($env:GH_MODELS_TOKEN) { return $env:GH_MODELS_TOKEN }
    if ($env:GITHUB_TOKEN) { return $env:GITHUB_TOKEN }
    # Check config file
    if (Test-Path $Script:ConfigFile) {
        try {
            $fileToken = (Get-Content $Script:ConfigFile -Raw).Trim()
            if ($fileToken) { return $fileToken }
        } catch {}
    }
    try {
        $ghToken = gh auth token 2>$null
        if ($ghToken) { return $ghToken }
    } catch {}
    return ''
}

# ─── API Helpers ───────────────────────────────────────────────────────────────
function Invoke-ModelsAPI {
    param(
        [string]$Endpoint,
        [string]$Method = 'GET',
        [object]$Body = $null
    )
    $token = Get-ModelsToken
    if (-not $token) {
        Write-Error "No GitHub token found. Set `$env:GH_MODELS_TOKEN or authenticate with 'gh auth login'"
        return $null
    }

    $headers = @{
        Authorization = "Bearer $token"
        'Content-Type' = 'application/json'
    }

    $uri = "$Script:ApiBaseUrl/$Endpoint"

    try {
        if ($Body) {
            $jsonBody = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 10 }
            return Invoke-RestMethod -Uri $uri -Headers $headers -Method $Method -Body $jsonBody -ErrorAction Stop
        } else {
            return Invoke-RestMethod -Uri $uri -Headers $headers -Method $Method -ErrorAction Stop
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = if ($_.Exception.Response) {
            try {
                $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $reader.ReadToEnd() | ConvertFrom-Json
            } catch { $null }
        }

        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            Write-Host "`n❌ Access denied. Your token needs the 'models' permission." -ForegroundColor Red
            Write-Host "   Create a PAT at: https://github.com/settings/tokens?type=beta" -ForegroundColor Yellow
            Write-Host "   Set it with: `$env:GH_MODELS_TOKEN = 'your_token_here'" -ForegroundColor Yellow
        } elseif ($statusCode -eq 429) {
            Write-Host "`n⏳ Rate limited! Free tier limits:" -ForegroundColor Yellow
            Write-Host "   Low tier:  15 req/min, 150 req/day" -ForegroundColor DarkGray
            Write-Host "   High tier: 10 req/min, 50 req/day" -ForegroundColor DarkGray
            Write-Host "   Wait a minute and try again." -ForegroundColor Yellow
        } else {
            Write-Host "`n❌ API Error ($statusCode): $($errorBody.error.message)" -ForegroundColor Red
        }
        return $null
    }
}

# ─── Action: List Models ───────────────────────────────────────────────────────
function Show-Models {
    $result = Invoke-ModelsAPI -Endpoint 'models'
    if (-not $result) { return }

    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        GitHub Models — Free Tier Catalog              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # API-returned models
    Write-Host "── Available via API ──" -ForegroundColor Yellow
    foreach ($m in $result.data) {
        $info = if ($Script:FreeModels.ContainsKey($m.name)) { $Script:FreeModels[$m.name] } else { $null }
        $tier = if ($info) { "[$($info.Tier)] $($info.Description)" } else { "?" }
        Write-Host "  • $($m.name)" -ForegroundColor White
        Write-Host "    $tier" -ForegroundColor DarkGray
    }

    # Recommended models section
    Write-Host "`n── Recommended Free Tier Picks ──" -ForegroundColor Green
    Write-Host "  Model                    Tier    RPM RPD    Best For" -ForegroundColor DarkGray
    Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  gpt-4o-mini              Low    15  150   🏆 General purpose" -ForegroundColor White
    Write-Host "  Phi-4                    Low    15  150   💡 Code & reasoning" -ForegroundColor White
    Write-Host "  Meta-Llama-3.1-70B       Low    15  150   🧠 Strong reasoning" -ForegroundColor White
    Write-Host "  Mistral-large            Low    15  150   🏢 Enterprise tasks" -ForegroundColor White
    Write-Host "  DeepSeek-R1              High    1    8   🔬 Deep reasoning" -ForegroundColor White
    Write-Host "  Grok-3-Mini              High    2   30   🚀 Latest & fast" -ForegroundColor White

    Write-Host "`nUsage: .\gh-models.ps1 chat -Model 'Phi-4' -Prompt 'your question'" -ForegroundColor Green
}

# ─── Action: Chat (Interactive) ───────────────────────────────────────────────
function Start-Chat {
    param([string]$InitialPrompt = '')

    $token = Get-ModelsToken
    if (-not $token) {
        Write-Host "`n❌ No GitHub token found. You need a PAT with 'models' permission." -ForegroundColor Red
        Write-Host "   Get one: https://github.com/settings/tokens?type=beta" -ForegroundColor Yellow
        Write-Host "   Then:    `$env:GH_MODELS_TOKEN = 'your_token'" -ForegroundColor Yellow
        return
    }

    # Test the token first
    Write-Host "Testing token..." -NoNewline -ForegroundColor DarkGray
    $testResult = Invoke-ModelsAPI -Endpoint 'models'
    if (-not $testResult) { return }
    Write-Host " ✅" -ForegroundColor Green

    # Load history
    $messages = @()
    if (Test-Path $Script:HistoryFile) {
        try {
            $messages = Get-Content $Script:HistoryFile -Raw | ConvertFrom-Json
            if ($messages.Count -gt 0) {
                Write-Host "Loaded $($messages.Count) previous messages from history" -ForegroundColor DarkGray
            }
        } catch {}
    }

    if ($messages.Count -eq 0) {
        $messages = @(@{ role = 'system'; content = $System })
    }

    Write-Host "`n╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   GitHub Models Free — Interactive Chat        ║" -ForegroundColor Cyan
    Write-Host "║   Model: $Model" -ForegroundColor Cyan
    Write-Host "║   Type 'exit' to quit, 'clear' to reset        ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

    # Handle initial prompt
    if ($InitialPrompt) {
        Write-Host "`n── You ──" -ForegroundColor Green
        Write-Host $InitialPrompt -ForegroundColor White
        $messages += @{ role = 'user'; content = $InitialPrompt }
        Send-Message $messages
    }

    # Main loop
    while ($true) {
        Write-Host "`n── You ──" -ForegroundColor Green -NoNewline
        $userInput = Read-Host "`n> "

        if ($userInput -eq 'exit' -or $userInput -eq 'quit') { break }
        if ($userInput -eq 'clear') {
            $messages = @(@{ role = 'system'; content = $System })
            if (Test-Path $Script:HistoryFile) { Remove-Item $Script:HistoryFile -Force }
            Write-Host "💬 History cleared." -ForegroundColor Yellow
            continue
        }
        if ($userInput -eq 'models') { Show-Models; continue }
        if ($userInput -eq '') { continue }

        $messages += @{ role = 'user'; content = $userInput }
        Send-Message $messages
    }

    # Save history
    $messages | ConvertTo-Json -Depth 10 | Out-File $Script:HistoryFile -Encoding utf8
    Write-Host "`n💾 History saved. Next session will resume." -ForegroundColor DarkGray
}

# ─── Send Message to API ──────────────────────────────────────────────────────
function Send-Message {
    param([array]$Messages)

    # Trim history to avoid token limits (keep system + last 10 exchanges)
    if ($Messages.Count -gt 21) {
        $system = $Messages[0]
        $last20 = $Messages[-20..-1]
        $Messages = @($system) + $last20
    }

    $body = @{
        model = $Model
        messages = $Messages
        temperature = $Temperature
        max_tokens = $MaxTokens
        stream = $Stream.IsPresent
    }

    if ($Stream -or $env:GH_MODELS_STREAM -eq '1') {
        return Send-StreamingMessage $Messages
    }

    $result = Invoke-ModelsAPI -Endpoint 'chat/completions' -Method 'POST' -Body ($body | ConvertTo-Json -Depth 10)
    if (-not $result) { return }

    $reply = $result.choices[0].message.content
    $usage = $result.usage

    Write-Host "── Gh Models ──" -ForegroundColor Blue
    Write-Host $reply -ForegroundColor White

    if ($usage) {
        Write-Host "" -NoNewline
        Write-Host "⚡ in:$($usage.prompt_tokens) out:$($usage.completion_tokens) total:$($usage.total_tokens)" -ForegroundColor DarkGray
    }

    $Messages += @{ role = 'assistant'; content = $reply }

    if ($OutputFile) {
        $reply | Out-File $OutputFile -Encoding utf8
        Write-Host "💾 Saved to $OutputFile" -ForegroundColor DarkGray
    }

    return $reply
}

# ─── Streaming Response ───────────────────────────────────────────────────────
function Send-StreamingMessage {
    param([array]$Messages)

    $token = Get-ModelsToken
    $body = @{
        model = $Model
        messages = $Messages
        temperature = $Temperature
        max_tokens = $MaxTokens
        stream = $true
    } | ConvertTo-Json -Depth 10

    $uri = "$Script:ApiBaseUrl/chat/completions"
    $headers = @{
        Authorization = "Bearer $token"
        'Content-Type' = 'application/json'
    }

    Write-Host "── Gh Models (streaming) ──" -ForegroundColor Blue

    try {
        $fullReply = ''
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body -ErrorAction Stop
        # Non-streaming fallback (stream not supported in Invoke-RestMethod)
        $reply = $response.choices[0].message.content
        Write-Host $reply -ForegroundColor White
        $fullReply = $reply

        $Messages += @{ role = 'assistant'; content = $fullReply }

        if ($OutputFile) {
            $fullReply | Out-File $OutputFile -Encoding utf8
            Write-Host "`n💾 Saved to $OutputFile" -ForegroundColor DarkGray
        }

        return $fullReply
    } catch {
        Write-Host "`n❌ Streaming error: $_" -ForegroundColor Red
        # Fallback to non-streaming
        Write-Host "↳ Falling back to non-streaming..." -ForegroundColor Yellow
        return Send-Message $Messages
    }
}

# ─── Action: One-shot Chat ────────────────────────────────────────────────────
function Invoke-OneShot {
    param([string]$PromptText)

    if (-not $PromptText) {
        Write-Host "Usage: .\gh-models.ps1 chat -Prompt 'your question'" -ForegroundColor Yellow
        return
    }

    $messages = @(
        @{ role = 'system'; content = $System }
        @{ role = 'user'; content = $PromptText }
    )

    $body = @{
        model = $Model
        messages = $messages
        temperature = $Temperature
        max_tokens = $MaxTokens
        stream = $Stream.IsPresent
    } | ConvertTo-Json -Depth 10

    $result = Invoke-ModelsAPI -Endpoint 'chat/completions' -Method 'POST' -Body $body
    if (-not $result) { return }

    $reply = $result.choices[0].message.content.Trim()
    $usage = $result.usage

    if ($OutputFile) {
        $reply | Out-File $OutputFile -Encoding utf8
        Write-Host "💾 Saved to $OutputFile" -ForegroundColor DarkGray
    }

    return $reply
}

# ─── Action: Environment Check ────────────────────────────────────────────────
function Show-Env {
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         GitHub Models — Environment        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # Check token sources
    Write-Host "── Token Sources ──" -ForegroundColor Yellow
    $methods = @(
        @{ Name = 'GH_MODELS_TOKEN env'; Value = if ($env:GH_MODELS_TOKEN) { "✅ Found ($($env:GH_MODELS_TOKEN.Length) chars)" } else { '❌ Not set' } }
        @{ Name = 'GITHUB_TOKEN env'; Value = if ($env:GITHUB_TOKEN) { "✅ Found ($($env:GITHUB_TOKEN.Length) chars)" } else { '❌ Not set' } }
        @{ Name = 'gh auth token'; Value = try { $t = gh auth token 2>$null; if ($t) { "✅ Found ($($t.Length) chars)" } else { '❌ Not authenticated' } } catch { '❌ gh not available' } }
    )
    foreach ($m in $methods) {
        Write-Host "  $($m.Name): $($m.Value)" -ForegroundColor White
    }

    # Test token permissions
    Write-Host "`n── Token Tests ──" -ForegroundColor Yellow
    $token = Get-ModelsToken
    if ($token) {
        # Test listing
        try {
            $test = Invoke-ModelsAPI -Endpoint 'models'
            if ($test) {
                Write-Host "  ✅ Can list models: $($test.data.Count) models" -ForegroundColor Green
            }
        } catch {
            Write-Host "  ❌ Cannot list models" -ForegroundColor Red
        }

        # Test chat completions
        try {
            $body = @{
                model = 'gpt-4o-mini'
                messages = @(@{ role = 'user'; content = 'test' })
                max_tokens = 5
            } | ConvertTo-Json -Compress
            $r = Invoke-RestMethod -Uri "$Script:ApiBaseUrl/chat/completions" -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Method Post -Body $body -ErrorAction Stop
            Write-Host "  ✅ Chat completions work! (model replied)" -ForegroundColor Green
        } catch {
            $code = $_.Exception.Response.StatusCode.value__
            Write-Host "  ❌ Chat completions failed (HTTP $code)" -ForegroundColor Red
            if ($code -eq 401 -or $code -eq 403) {
                Write-Host "     ↳ Token needs 'models' permission for inference" -ForegroundColor Yellow
                Write-Host "     ↳ Create a PAT at: https://github.com/settings/tokens?type=beta" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  ❌ No token configured" -ForegroundColor Red
    }

    # API endpoint
    Write-Host "`n── Endpoint ──" -ForegroundColor Yellow
    Write-Host "  Base URL: $Script:ApiBaseUrl" -ForegroundColor White

    # Model info
    Write-Host "`n── Current Config ──" -ForegroundColor Yellow
    Write-Host "  Default model: $Model" -ForegroundColor White
    Write-Host "  Temperature: $Temperature" -ForegroundColor White
    Write-Host "  Max tokens: $MaxTokens" -ForegroundColor White
    Write-Host "  History file: $Script:HistoryFile" -ForegroundColor White
    Write-Host "  Config file: $Script:ConfigFile" -ForegroundColor White

    # Quick usage
    Write-Host "`n── Quick Start ──" -ForegroundColor Green
    Write-Host "  .\gh-models.ps1 chat -Prompt 'Hello!'       # One-shot" -ForegroundColor White
    Write-Host "  .\gh-models.ps1 chat                        # Interactive" -ForegroundColor White
    Write-Host "  .\gh-models.ps1 models                      # List models" -ForegroundColor White
    Write-Host "  .\gh-models.ps1 chat -Model Phi-4 -Stream   # Streaming chat" -ForegroundColor White
}

# ─── Main Dispatch ─────────────────────────────────────────────────────────────
switch ($Action) {
    'models' { Show-Models }
    'chat' {
        if ($Prompt) {
            $reply = Invoke-OneShot -PromptText $Prompt
            if ($reply -and -not $OutputFile) { Write-Host $reply -ForegroundColor White }
        } else {
            Start-Chat -InitialPrompt ''
        }
    }
    'stream' {
        if ($Prompt) {
            $env:GH_MODELS_STREAM = '1'
            $reply = Invoke-OneShot -PromptText $Prompt
            if ($reply -and -not $OutputFile) { Write-Host $reply -ForegroundColor White }
        } else {
            $env:GH_MODELS_STREAM = '1'
            Start-Chat
        }
    }
    'env' { Show-Env }
    'config' {
        Write-Host "── GitHub Models Configuration ──" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Set persistent token (in your PowerShell profile):" -ForegroundColor Yellow
        Write-Host '  $env:GH_MODELS_TOKEN = "your_github_pat_here"' -ForegroundColor White
        Write-Host ""
        Write-Host "One-time (current session):" -ForegroundColor Yellow
        Write-Host '  $env:GH_MODELS_TOKEN = "your_github_pat_here"' -ForegroundColor White
        Write-Host ""
        Write-Host "Or authenticate with gh CLI:" -ForegroundColor Yellow
        Write-Host "  gh auth login" -ForegroundColor White
        Write-Host ""
        Write-Host "Required token permission: models:read" -ForegroundColor Yellow
        Write-Host "  Create at: https://github.com/settings/tokens?type=beta" -ForegroundColor Cyan
    }
}

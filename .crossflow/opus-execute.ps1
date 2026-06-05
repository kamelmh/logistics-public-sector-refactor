<#
.SYNOPSIS
    CrossFlow-Opus Task Executor — picks up tasks from opus-tasks.md, runs via Claude Opus CLI.

.DESCRIPTION
    Reads the task board, finds the next PENDING task, builds a focused prompt
    with only the needed files, calls Claude CLI (--print --model opus), writes
    results to opus-results.md, and git commits.

.PARAMETER TaskId
    Specific task ID to run (e.g. "TASK-001"). If omitted, runs the next PENDING task.

.PARAMETER DryRun
    Show what would be executed without calling Claude.

.PARAMETER MaxBudgetUsd
    Maximum cost per task (default: $0.50).

.EXAMPLE
    .\opus-execute.ps1                    # Run next pending task
    .\opus-execute.ps1 -TaskId TASK-001   # Run specific task
    .\opus-execute.ps1 -DryRun            # Preview without executing
#>

param(
    [string]$TaskId,
    [switch]$DryRun,
    [float]$MaxBudgetUsd = 0.50
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$CrossflowDir = $PSScriptRoot
$TasksFile = Join-Path $CrossflowDir "opus-tasks.md"
$ResultsFile = Join-Path $CrossflowDir "opus-results.md"

# ─── Parse task board ───────────────────────────────────────────
function Get-PendingTasks {
    $content = Get-Content $TasksFile -Raw
    $tasks = @()
    $blocks = $content -split '(?=### \[TASK-)'

    foreach ($block in $blocks) {
        if ($block -match '### \[(TASK-\d+)\]\s+(.+)') {
            $id = $Matches[1]
            $title = $Matches[2]
            $status = "PENDING"
            if ($block -match '\*\*Status\*\*:\s*(\S+)') {
                $status = $Matches[1]
            }
            $type = "custom"
            if ($block -match '\*\*Type\*\*:\s*(\S+)') {
                $type = $Matches[1]
            }
            $input = ""
            if ($block -match '\*\*Input\*\*:\s*(.+)') {
                $input = $Matches[1].Trim()
            }
            $prompt = ""
            if ($block -match '\*\*Prompt\*\*:\s*\|\s*\n((?:.*\n)*?)(?=\s*- \*\*)') {
                $prompt = $Matches[1].Trim()
            }
            $priority = "MED"
            if ($block -match '\*\*Priority\*\*:\s*(\S+)') {
                $priority = $Matches[1]
            }

            $tasks += [PSCustomObject]@{
                Id = $id
                Title = $title
                Type = $type
                Input = $input
                Prompt = $prompt
                Priority = $priority
                Status = $status
                RawBlock = $block
            }
        }
    }
    return $tasks
}

function Get-NextTask {
    $tasks = Get-PendingTasks
    $pending = $tasks | Where-Object { $_.Status -eq "PENDING" } | Sort-Object Priority
    if ($TaskId) {
        return $pending | Where-Object { $_.Id -eq $TaskId }
    }
    return $pending | Select-Object -First 1
}

# ─── Build focused prompt ──────────────────────────────────────
function Build-Prompt {
    param([PSCustomObject]$Task)

    $promptParts = @()

    # System context (compact)
    $compactCtx = Join-Path $ProjectRoot ".opencode\erp-context-compact.md"
    if (Test-Path $compactCtx) {
        $ctx = Get-Content $compactCtx -Raw
        # Extract only ground truth + module summary (skip backends, paths)
        $groundTruth = ($ctx -split '## GROUND TRUTH')[1]
        if ($groundTruth) {
            $groundTruth = "## GROUND TRUTH`n" + ($groundTruth -split '## ')[0]
            $promptParts += $groundTruth
        }
    }

    # Task-specific input files
    $inputFiles = $Task.Input -split '\|'
    foreach ($file in $inputFiles) {
        $file = $file.Trim()
        $fullPath = Join-Path $ProjectRoot $file
        if (Test-Path $fullPath) {
            $content = Get-Content $fullPath -Raw
            $maxChars = 400000  # ~100K tokens (Nemotron 1M context)
            if ($content.Length -gt $maxChars) {
                $content = $content.Substring(0, $maxChars) + "`n... [TRUNCATED — file too large for token budget]"
            }
            $promptParts += "`n--- FILE: $file ---`n$content`n--- END: $file ---"
        } else {
            Write-Warning "Input file not found: $file"
        }
    }

    # Task prompt
    $promptParts += "`n--- TASK ---`n$($Task.Prompt)`n--- END TASK ---"

    return ($promptParts -join "`n")
}

# ─── Execute via OpenRouter API (free Nemotron 120B, 1M ctx) ───
function Invoke-Opus {
    param([string]$Prompt, [string]$TaskId)

    # Get OpenRouter API key from environment or secret store
    $apiKey = [Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User")
    if (-not $apiKey) { $apiKey = $env:OPENROUTER_API_KEY }
    if (-not $apiKey) {
        # Try the secret store
        $xmlPath = "$env:USERPROFILE\.academix-openrouter.xml"
        if (Test-Path $xmlPath) {
            try { $apiKey = (Import-Clixml $xmlPath).GetNetworkCredential().Password } catch { }
        }
    }
    if (-not $apiKey) {
        Write-Error "OPENROUTER_API_KEY not found"
        return $null
    }

    $model = "nvidia/nemotron-3-super-120b-a12b:free"  # Free, 1M context
    $maxTokens = 8192

    Write-Host "  Calling Nemotron 120B via OpenRouter (free, 1M ctx)..." -ForegroundColor Cyan
    Write-Host "  Prompt size: $($Prompt.Length) chars (~$([math]::Round($Prompt.Length / 4)) tokens)" -ForegroundColor DarkGray

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type"  = "application/json"
        "HTTP-Referer"  = "https://academix.local"
        "X-Title"       = "Academix CrossFlow-Opus"
    }

    $body = @{
        model       = $model
        messages    = @(
            @{
                role    = "user"
                content = $Prompt
            }
        )
        max_tokens  = $maxTokens
        temperature = 0.3
    } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-RestMethod `
            -Uri "https://openrouter.ai/api/v1/chat/completions" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -TimeoutSec 300  # 5 min for large prompts

        $output = $response.choices[0].message.content
        $usage = $response.usage

        Write-Host "  Tokens: input=$($usage.prompt_tokens) output=$($usage.completion_tokens) total=$($usage.total_tokens)" -ForegroundColor DarkGray

        # Store usage for result writing
        $script:LastUsage = $usage

        return $output
    } catch {
        Write-Error "API call failed: $($_.Exception.Message)"
        return $null
    }
}

# ─── Write result ───────────────────────────────────────────────
function Write-Result {
    param([PSCustomObject]$Task, [string]$Output)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $usage = $script:LastUsage
    $tokenLine = ""
    if ($usage) {
        $tokenLine = "- **Tokens**: input=$($usage.prompt_tokens) output=$($usage.completion_tokens) total=$($usage.total_tokens)"
    }
    $resultEntry = @"

### [$($Task.Id)] $($Task.Title)
- **Executed**: $timestamp
- **Model**: Nemotron 120B via OpenRouter (free, 1M context)
- **Status**: DONE
$tokenLine
- **Output**:

$Output

---
"@

    if (-not (Test-Path $ResultsFile)) {
        Set-Content -Path $ResultsFile -Value "# CrossFlow-Opus Results`n" -Encoding UTF8
    }

    Add-Content -Path $ResultsFile -Value $resultEntry -Encoding UTF8
}

# ─── Update task status ─────────────────────────────────────────
function Update-TaskStatus {
    param([string]$TaskId, [string]$NewStatus)

    $content = Get-Content $TasksFile -Raw
    $pattern = "(### \[$TaskId\].*?\*\*Status\*\*:\s*)\S+"
    $replacement = "`$1$NewStatus"
    $content = [regex]::Replace($content, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Set-Content -Path $TasksFile -Value $content -Encoding UTF8
}

# ─── Git commit ─────────────────────────────────────────────────
function Push-Result {
    param([string]$TaskId)

    Push-Location $ProjectRoot
    try {
        git add .crossflow/opus-tasks.md .crossflow/opus-results.md 2>$null
        $commitMsg = "chore(opus): $TaskId complete — see .crossflow/opus-results.md"
        git commit -m $commitMsg 2>$null
        Write-Host "  Committed: $commitMsg" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

# ─── Main ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  === CrossFlow-Opus Executor ===" -ForegroundColor Yellow
Write-Host ""

$task = Get-NextTask

if (-not $task) {
    Write-Host "  No pending tasks found in opus-tasks.md" -ForegroundColor Red
    Write-Host ""
    exit 0
}

Write-Host "  Task: [$($task.Id)] $($task.Title)" -ForegroundColor White
Write-Host "  Type: $($task.Type) | Priority: $($task.Priority)" -ForegroundColor DarkGray
Write-Host "  Input: $($task.Input)" -ForegroundColor DarkGray
Write-Host ""

if ($DryRun) {
    Write-Host "  [DRY RUN] Would execute:" -ForegroundColor Yellow
    $prompt = Build-Prompt -Task $task
    Write-Host "  Prompt length: $($prompt.Length) chars (~$([math]::Round($prompt.Length / 4)) tokens)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Prompt preview (first 500 chars):" -ForegroundColor Yellow
    Write-Host ($prompt.Substring(0, [Math]::Min(500, $prompt.Length))) -ForegroundColor DarkGray
    exit 0
}

# Mark as running
Update-TaskStatus -TaskId $task.Id -NewStatus "RUNNING"
Write-Host "  Status: RUNNING" -ForegroundColor Yellow

# Build prompt
$prompt = Build-Prompt -Task $task

# Execute
$output = Invoke-Opus -Prompt $prompt -TaskId $task.Id

if ($output) {
    # Write result
    Write-Result -Task $task -Output $output
    Write-Host "  Result written to opus-results.md" -ForegroundColor Green

    # Mark done
    Update-TaskStatus -TaskId $task.Id -NewStatus "DONE"
    Write-Host "  Status: DONE" -ForegroundColor Green

    # Git commit
    Push-Result -TaskId $task.Id

    # Show summary
    Write-Host ""
    Write-Host "  Output preview (first 300 chars):" -ForegroundColor Cyan
    Write-Host ($output.Substring(0, [Math]::Min(300, $output.Length))) -ForegroundColor White
} else {
    Update-TaskStatus -TaskId $task.Id -NewStatus "FAILED"
    Write-Host "  Status: FAILED" -ForegroundColor Red
}

Write-Host ""

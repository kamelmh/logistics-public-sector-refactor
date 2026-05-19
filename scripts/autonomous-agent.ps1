<#
.SYNOPSIS
    Autonomous Agent for Academix v13.2 Harness
.DESCRIPTION
    Implements the s11 idle/claim cycle.
    Scans .tasks/ for pending, unblocked tasks, claims them, and simulates execution.
    Integrates with worktree isolation (s12) and background tasks (s08).
.LAYER
    s11 - Autonomous Agents
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AgentName,

    [Parameter(Mandatory=$false)]
    [int]$PollInterval = 10 # seconds
)

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$HarnessScript = Join-Path $ProjectRoot "harness.ps1"
$BgWorkerScript = Join-Path $ProjectRoot "bg-worker.ps1"

if (-not (Test-Path $HarnessScript)) { Write-Error "Harness script not found at $HarnessScript"; exit 1 }
if (-not (Test-Path $BgWorkerScript)) { Write-Error "Background worker script not found at $BgWorkerScript"; exit 1 }

. $HarnessScript # Dot-source the harness functions

function Get-NextUnblockedTask {
    $tasks = & pwsh -NoProfile -File $HarnessScript task list | ConvertFrom-Json
    if (-not $tasks) { return $null }

    $pendingTasks = $tasks | Where-Object { $_.status -eq "pending" }
    if (-not $pendingTasks) { return $null }

    foreach ($task in $pendingTasks) {
        if ($task.blockedBy.Count -eq 0) {
            return $task
        }
    }
    return $null
}

function Execute-TaskPlaceholder {
    param($Task)
    Write-Output "[$AgentName] Executing task #$($Task.id): $($Task.subject)"
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 15) # Simulate work
    Write-Output "[$AgentName] Task #$($Task.id) completed."
    & pwsh -NoProfile -File $HarnessScript task update $($Task.id) completed
}

Write-Host "[$AgentName] Autonomous agent started. Polling every $PollInterval seconds..." -ForegroundColor Green

while ($true) {
    Write-Host "[$AgentName] Scanning for tasks..." -ForegroundColor DarkGray
    $nextTask = Get-NextUnblockedTask

    if ($nextTask) {
        Write-Host "[$AgentName] Found unblocked task #$($nextTask.id): $($nextTask.subject)" -ForegroundColor Yellow
        
        # Claim the task
        & pwsh -NoProfile -File $HarnessScript task claim $($nextTask.id) $AgentName
        Write-Host "[$AgentName] Claimed task #$($nextTask.id)" -ForegroundColor Cyan

        # Worktree integration (s12)
        if ($nextTask.layer -eq "s12" -and $nextTask.worktree -eq $null) {
             $worktreeName = "wt-$($AgentName)-task-$($nextTask.id)"
             Write-Host "[$AgentName] Creating worktree '$worktreeName' for task #$($nextTask.id)" -ForegroundColor Blue
             & pwsh -NoProfile -File $HarnessScript worktree create $worktreeName $($nextTask.id)
             # Update task with worktree path (assuming harness.ps1 will do this once implemented)
        }

        # Background task integration (s08)
        if ($nextTask.layer -eq "s08") {
            Write-Host "[$AgentName] Dispatching background task for #$($nextTask.id): $($nextTask.description)" -ForegroundColor Blue
            & pwsh -NoProfile -File $BgWorkerScript run -Pipeline ($nextTask.description -split ' ')[0] # Simple parsing for now
            Start-Sleep -Seconds 2 # Give bg job time to start
        }

        Execute-TaskPlaceholder $nextTask # Placeholder for actual execution logic
        
        # Remove worktree if created
        if ($worktreeName) {
            Write-Host "[$AgentName] Removing worktree '$worktreeName'" -ForegroundColor DarkMagenta
            & pwsh -NoProfile -File $HarnessScript worktree remove $worktreeName
            $worktreeName = $null
        }

    } else {
        Write-Host "[$AgentName] No unblocked tasks found. Idling..." -ForegroundColor DarkGray
    }
    Start-Sleep -Seconds $PollInterval
}

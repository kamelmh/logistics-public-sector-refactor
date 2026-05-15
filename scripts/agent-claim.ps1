# S11 Autonomous Agent Claim Logic
# Academix v13.2 Engineering Harness
# Handles atomic task acquisition and worktree binding

param (
    [Parameter(Mandatory=$true)]
    [string]$AgentId
)

$PROJECT_ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$TASKS_DIR = "$PROJECT_ROOT\.tasks"
$WORKTREE_MANAGER = "$PROJECT_ROOT\scripts\worktree-manager.ps1"
$LOCK_FILE = "$TASKS_DIR\claim.lock"

# --- Helper Functions ---

function Write-Log ([string]$Message, [string]$Color = "White") {
    Write-Host "[S11-Claim] $Message" -ForegroundColor $Color
}

function Acquire-Lock {
    $retryCount = 0
    $maxRetries = 10
    while ($retryCount -lt $maxRetries) {
        try {
            # Create lock file exclusively
            $stream = [System.IO.File]::Create($LOCK_FILE)
            $stream.Close()
            return $true
        } catch {
            $retryCount++
            Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
        }
    }
    return $false
}

function Release-Lock {
    if (Test-Path $LOCK_FILE) {
        Remove-Item -LiteralPath $LOCK_FILE -Force
    }
}

# --- Main Execution ---

Write-Log "Agent '$AgentId' attempting to claim a task..."

if (-not (Acquire-Lock)) {
    Write-Log "Could not acquire lock file. Another agent is claiming a task." -Color Red
    exit 1
}

try {
    $taskFiles = Get-ChildItem -Path $TASKS_DIR -Filter "*.json"
    $claimedTask = $null

    foreach ($file in $taskFiles) {
        $task = Get-Content $file.FullName | ConvertFrom-Json
        if ($task.status -eq "pending") {
            $claimedTask = $task
            $taskFile = $file.FullName
            break
        }
    }

    if ($null -eq $claimedTask) {
        Write-Log "No pending tasks found." -Color Yellow
        Release-Lock
        exit 0
    }

    Write-Log "Task found: $($claimedTask.subject). Claiming..." -Color Cyan

    # 1. Update Task Data using a hash table for flexibility
    $taskData = @{}
    $task.psobject.Properties | ForEach-Object { $taskData[$_.Name] = $_.Value }
    
    $taskData["status"] = "in_progress"
    $taskData["owner"] = $AgentId
    $taskData["startTime"] = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    # 2. Bind Worktree (S12 Integration)
    $worktreeName = "agent-$AgentId"
    # Check if worktree already exists
    $index = Get-Content "$PROJECT_ROOT\.worktrees\index.json" | ConvertFrom-Json
    $existingWt = $index | Where-Object { $_.Name -eq $worktreeName }

    if ($null -eq $existingWt) {
        Write-Log "Provisioning new worktree for agent..." -Color Gray
        & $WORKTREE_MANAGER create $worktreeName "master"
    }

    $worktreePath = "$PROJECT_ROOT\.worktrees\$worktreeName"
    $taskData["worktree"] = $worktreePath

    # 3. Save Updated Task
    $taskData | ConvertTo-Json -Depth 10 | Set-Content $taskFile

    # 4. Output result for agent consumption
    $result = @{
        taskId = $taskData["id"]
        subject = $taskData["subject"]
        worktreePath = $worktreePath
        status = "claimed"
        agentId = $AgentId
    }
    $result | ConvertTo-Json
    
    Write-Log "Task $($taskData['id']) successfully claimed by $AgentId." -Color Green

} catch {
    Write-Log "Error during claim process: $($_.Exception.Message)" -Color Red
} finally {
    Release-Lock
}

param(
    [Parameter(Position=0)]
    [ValidateSet("compact","task","bg","worktree","status","cleanup","sync","unlock")]
    [string]$Layer,

    [Parameter(Position=1)]
    [string]$Action,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$TASKS_DIR = "$ROOT\.tasks"
$TEAM_DIR = "$ROOT\.team"
$INBOX_DIR = "$TEAM_DIR\inbox"
$WORKTREES_DIR = "$ROOT\.worktrees"
$TRANSCRIPTS_DIR = "$ROOT\.opencode\memory\transcripts"
$WORKTREES_INDEX = "$WORKTREES_DIR\index.json"
$TEAM_CONFIG = "$TEAM_DIR\config.json"
$BG_DIR = "$ROOT\.tasks\bg"

function Safe-Json {
    param([string]$Path)
    try {
        if (Test-Path $Path) { return Get-Content $Path -Raw | ConvertFrom-Json }
    } catch {}
    return $null
}

function Safe-Read {
    param([string]$Path)
    try { if (Test-Path $Path) { return Get-Content $Path -Raw } } catch {}
    return $null
}

function Assert-Dir {
    param([string]$Path)
    $null = mkdir -Force $Path -ErrorAction SilentlyContinue
}

# ===== s02/s08: File Ownership & Lock Release =====
function Invoke-Unlock {
    param([string]$TargetDir = "$ROOT\Thesis_Surgical_Edit\output")
    Write-Output "=== Harness Unlock & Ownership Phase ==="
    
    # 1. Kill Word to release locks
    Write-Output "Releasing file locks (killing WINWORD)..."
    Stop-Process -Name "WINWORD" -Force -ErrorAction SilentlyContinue
    
    # 2. Take ownership recursively
    Write-Output "Taking ownership of $TargetDir..."
    takeown /f "$TargetDir" /r /d y | Out-Null
    
    # 3. Grant full control to Administrator
    Write-Output "Granting full control to Administrator..."
    icacls "$TargetDir" /grant "Administrator:F" /t | Out-Null
    
    Write-Output "Unlock complete. Target: $TargetDir"
}

# ===== s06: Context Compression =====
function Invoke-Compact {
    param([switch]$Auto)
    Assert-Dir $TRANSCRIPTS_DIR
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $path = "$TRANSCRIPTS_DIR\transcript-$ts.jsonl"

    # Gather live session state
    $session = @{
        ts = (Get-Date -Format "o")
        tasks = @(Get-ChildItem "$TASKS_DIR\task_*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            $t = Safe-Json $_.FullName
            if ($t) { @{id=$t.id; subject=$t.subject; status=$t.status; blockedBy=$t.blockedBy} }
        })
        worktrees = @(Get-WorktreeList)
        git = @{
            branch = (git -C $ROOT rev-parse --abbrev-ref HEAD 2>$null)
            commit = (git -C $ROOT log -1 --format="%h %s" 2>$null)
            status = (git -C $ROOT status --short 2>$null)
        }
    }
    $session | ConvertTo-Json -Depth 3 | Set-Content $path -ErrorAction Stop

    "Transcript saved: $path ($((Get-Item $path).Length / 1KB) KB)"
    if ($Auto) { "Auto-compact triggered" } else { "Manual compact triggered" }
    # Clean old transcripts (keep last 10)
    $old = Get-ChildItem "$TRANSCRIPTS_DIR\transcript-*.jsonl" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -Skip 10
    if ($old) { $old | Remove-Item -Force; "Purged $($old.Count) old transcripts" }
}

# ===== s07: Task DAG System =====
function Get-NextTaskId {
    $files = Get-ChildItem "$TASKS_DIR\task_*.json" -ErrorAction SilentlyContinue
    if (-not $files) { return 1 }
    $ids = try { $files | ForEach-Object { [int]($_.BaseName -replace 'task_','') } } catch { @(0) }
    if (-not $ids) { return 1 }
    ($ids | Measure-Object -Maximum).Maximum + 1
}

function New-Task {
    param([string]$Subject, [string]$Description, [string]$BlockedBy)
    $Subject = "$Subject".Trim()
    if (-not $Subject) { return "Error: subject is required" }
    $bIds = if ($BlockedBy -and $BlockedBy -match '\d') { @($BlockedBy -split ',' | ForEach-Object { [int]($_.Trim()) } | Where-Object { $_ -gt 0 }) } else { @() }
    Assert-Dir $TASKS_DIR
    $id = [int](Get-NextTaskId)
    $task = @{
        id = $id; subject = $Subject; description = "$Description".Trim()
        status = "pending"; owner = $null; blockedBy = $bIds
        worktree = $null; created = (Get-Date -Format "o")
    }
    $task | ConvertTo-Json | Set-Content "$TASKS_DIR\task_$id.json" -ErrorAction Stop
    $task | ConvertTo-Json
}

function Get-Task {
    param([int]$Id)
    $path = "$TASKS_DIR\task_$Id.json"
    if (-not (Test-Path $path)) { return "Error: Task $Id not found" }
    $task = Safe-Json $path
    if (-not $task) { return "Error: Corrupted task file for #$Id" }
    $task | ConvertTo-Json
}

function Set-Task {
    param([int]$Id, [string]$Status, [int[]]$AddBlockedBy, [int[]]$RemoveBlockedBy)
    $validStatus = @("pending","in_progress","completed","deleted")
    if ($Status -and ($Status -notin $validStatus)) { return "Error: Invalid status '$Status'. Use: $($validStatus -join ', ')" }
    $path = "$TASKS_DIR\task_$Id.json"
    if (-not (Test-Path $path)) { return "Error: Task $Id not found" }
    $task = Safe-Json $path
    if (-not $task) { return "Error: Corrupted task file for #$Id" }
    if ($Status) {
        $task.status = $Status
        if ($Status -eq "completed") {
            Get-ChildItem "$TASKS_DIR\task_*.json" -ErrorAction SilentlyContinue | ForEach-Object {
                $t = Safe-Json $_.FullName
                if ($t -and ($t.blockedBy -contains $Id)) {
                    $t.blockedBy = @($t.blockedBy | Where-Object { $_ -ne $Id })
                    $t | ConvertTo-Json | Set-Content $_.FullName
                }
            }
        }
        if ($Status -eq "deleted") {
            Remove-Item $path -Force -ErrorAction SilentlyContinue
            return "Task $Id deleted"
        }
    }
    if ($AddBlockedBy) {
        $current = @($task.blockedBy)
        $task.blockedBy = @($current + $AddBlockedBy | Select-Object -Unique)
    }
    if ($RemoveBlockedBy) {
        $task.blockedBy = @($task.blockedBy | Where-Object { $_ -notin $RemoveBlockedBy })
    }
    $task | ConvertTo-Json | Set-Content $path -ErrorAction Stop
    $task | ConvertTo-Json
}

function Set-TaskClaim {
    param([int]$Id, [string]$Owner)
    $path = "$TASKS_DIR\task_$Id.json"
    if (-not (Test-Path $path)) { return "Error: Task $Id not found" }
    $task = Safe-Json $path
    if (-not $task) { return "Error: Corrupted task file for #$Id" }
    $task.owner = "$Owner".Trim()
    $task.status = "in_progress"
    $task | ConvertTo-Json | Set-Content $path
    "Claimed task #$Id for $Owner"
}

function Get-TaskList {
    $files = Get-ChildItem "$TASKS_DIR\task_*.json" -ErrorAction SilentlyContinue | Sort-Object Name
    if (-not $files) { return "No tasks." }
    $files | ForEach-Object {
        $t = Safe-Json $_.FullName
        if (-not $t) { return }
        $icon = @{pending="[ ]"; in_progress="[>]"; completed="[x]"}[$t.status]
        if (-not $icon) { $icon = "[?]" }
        $owner = if ($t.owner) { " @$($t.owner)" } else { "" }
        $blocked = if ($t.blockedBy -and $t.blockedBy.Count -gt 0) { " (blocked by: $($t.blockedBy -join ','))" } else { "" }
        "$icon #$($t.id): $($t.subject)$owner$blocked"
    }
}

# ===== s08: Background Runner (file-based, cross-session) =====
function Start-BgTask {
    param([string]$Command, [int]$Timeout = 120)
    $Command = "$Command".Trim()
    if (-not $Command) { return "Error: command is required" }
    Assert-Dir $BG_DIR
    $id = [System.Guid]::NewGuid().ToString().Substring(0,8)
    $taskDir = "$BG_DIR\$id"
    Assert-Dir $taskDir
    @{status="running"; pid=$null; command=$Command; timeout=$Timeout; started=(Get-Date -Format "o")} |
        ConvertTo-Json | Set-Content "$taskDir\status.json"
    $Command | Set-Content "$taskDir\command.txt"
    $workerPath = "$ROOT\scripts\bg-worker.ps1"
    if (-not (Test-Path $workerPath)) { return "Error: bg-worker.ps1 not found at $workerPath" }
    try {
        $ps = Start-Process -WindowStyle Hidden -FilePath pwsh -ArgumentList @(
            "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $workerPath,
            "-TaskId", $id, "-TaskDir", $taskDir
        ) -PassThru
        $status = Safe-Json "$taskDir\status.json"
        if ($status) {
            $status.pid = $ps.Id
            $status | ConvertTo-Json | Set-Content "$taskDir\status.json"
        }
        "Background task $id started (pid: $($ps.Id)): $($Command.Substring(0, [Math]::Min($Command.Length, 80)))"
    } catch {
        "Error starting background task: $_"
    }
}

function Get-BgTask {
    param([string]$TaskId)
    if ($TaskId) {
        $taskDir = "$BG_DIR\$TaskId"
        if (-not (Test-Path $taskDir)) { return "Unknown: $TaskId" }
        $status = Safe-Json "$taskDir\status.json"
        if (-not $status) { return "[unknown]" }
        if ($status.status -eq "running" -and $status.pid) {
            $proc = Get-Process -Id $status.pid -ErrorAction SilentlyContinue
            if (-not $proc) { $status.status = "orphaned" }
        }
        $suffix = ""
        $resultRaw = Safe-Read "$taskDir\result.txt"
        if ($resultRaw) {
            $len = [Math]::Min($resultRaw.Length, 500)
            $suffix = ": $($resultRaw.Substring(0, $len))"
        }
        return "[$($status.status)] pid=$($status.pid)$suffix"
    }
    $dirs = Get-ChildItem "$BG_DIR" -Directory -ErrorAction SilentlyContinue
    if (-not $dirs) { return "No background tasks." }
    $dirs | ForEach-Object {
        $s = Safe-Json "$($_.FullName)\status.json"
        if ($s) {
            if ($s.status -eq "running" -and $s.pid) {
                $proc = Get-Process -Id $s.pid -ErrorAction SilentlyContinue
                if (-not $proc) { $s.status = "orphaned" }
            }
            $cmd = if ($s.command) { $s.command.Substring(0, [Math]::Min($s.command.Length, 60)) } else { "(no command)" }
            "$($_.Name): [$($s.status)] $cmd"
        } else { "$($_.Name): [unknown]" }
    } | Out-String
}

# ===== s12: Worktree Isolation =====
function New-Worktree {
    param([string]$Name, [int]$TaskId)
    $Name = "$Name".Trim()
    if (-not $Name) { return "Error: worktree name is required" }
    if ($Name -match '[<>:"/\\|?*]') { return "Error: Invalid characters in worktree name" }
    Assert-Dir $WORKTREES_DIR
    $wtPath = "$WORKTREES_DIR\$Name"
    if (Test-Path $wtPath) { return "Error: Worktree '$Name' already exists" }
    try {
        $gitCheck = git -C $ROOT rev-parse --git-dir 2>&1
        if (-not $?) { return "Error: Not a git repository: $ROOT" }
        $result = git -C $ROOT worktree add -b "wt/$Name" $wtPath HEAD 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) { return "Error: git worktree add failed: $result" }
        $idx = Safe-Json $WORKTREES_INDEX
        if (-not $idx) { $idx = @{worktrees=@()} }
        $entry = @{name=$Name; path=$wtPath; branch="wt/$Name"; task_id=$TaskId; status="active"; created=(Get-Date -Format "o")}
        $idx.worktrees += $entry
        $idx | ConvertTo-Json | Set-Content $WORKTREES_INDEX -ErrorAction Stop
        if ($TaskId) { Set-Task $TaskId -Status "in_progress" | Out-Null }
        "Created worktree '$Name' at $wtPath (branch: wt/$Name, task: #$TaskId)"
    } catch {
        "Error creating worktree: $_"
    }
}

function Remove-Worktree {
    param([string]$Name, [switch]$CompleteTask, [switch]$Force)
    $Name = "$Name".Trim()
    if (-not $Name) { return "Error: worktree name is required" }
    $idx = Safe-Json $WORKTREES_INDEX
    if (-not $idx) { return "Error: No worktrees registered" }
    $entry = $idx.worktrees | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    if (-not $entry) { return "Error: Worktree '$Name' not found" }
    try {
        $forceFlag = if ($Force) { "-f" } else { "" }
        $result = git -C $ROOT worktree remove $forceFlag $entry.path 2>&1 | Out-String
        if ($CompleteTask -and $entry.task_id) {
            Set-Task $entry.task_id -Status "completed" | Out-Null
        }
        $idx.worktrees = @($idx.worktrees | Where-Object { $_.name -ne $Name })
        $idx | ConvertTo-Json | Set-Content $WORKTREES_INDEX -ErrorAction Stop
        $evt = @{event="worktree.removed"; task_id=$entry.task_id; worktree=$Name; ts=(Get-Date -Format "o")}
        Add-Content "$WORKTREES_DIR\events.jsonl" ($evt | ConvertTo-Json -Compress)
        "Removed worktree '$Name'"
    } catch {
        "Error removing worktree: $_"
    }
}

function Get-WorktreeList {
    if (-not (Test-Path $WORKTREES_INDEX)) { return "No worktrees." }
    $idx = Safe-Json $WORKTREES_INDEX
    if (-not $idx -or -not $idx.worktrees -or $idx.worktrees.Count -eq 0) { return "No worktrees." }
    $idx.worktrees | ForEach-Object {
        $taskInfo = if ($_.task_id) { " (task #$($_.task_id))" } else { "" }
        "  $($_.name) → $($_.path)$taskInfo [$($_.status)]"
    }
}

# ===== status: unified health check =====
function Get-HarnessStatus {
    Write-Output "=== Engineering Harness Status ==="
    Write-Output ""

    Write-Output "-- s06: Context Compression --"
    $txDir = Get-ChildItem "$TRANSCRIPTS_DIR\*.jsonl" -ErrorAction SilentlyContinue
    $txCount = if ($txDir) { $txDir.Count } else { 0 }
    Write-Output "  Transcripts: $txCount"
    Write-Output ""

    Write-Output "-- s07: Task DAG --"
    $tasks = Get-ChildItem "$TASKS_DIR\task_*.json" -ErrorAction SilentlyContinue
    if ($tasks) {
        $pending = @($tasks | ForEach-Object { $t = Safe-Json $_.FullName; if ($t -and $t.status -eq "pending") { $_ } }).Count
        $inProg = @($tasks | ForEach-Object { $t = Safe-Json $_.FullName; if ($t -and $t.status -eq "in_progress") { $_ } }).Count
        $done = @($tasks | ForEach-Object { $t = Safe-Json $_.FullName; if ($t -and $t.status -eq "completed") { $_ } }).Count
        Write-Output "  Total: $($tasks.Count) | Pending: $pending | In Progress: $inProg | Completed: $done"
    } else {
        Write-Output "  (no tasks)"
    }
    Write-Output ""

    Write-Output "-- s08: Background Runner --"
    $bgDirs = Get-ChildItem "$BG_DIR" -Directory -ErrorAction SilentlyContinue
    if ($bgDirs) {
        $running = @($bgDirs | ForEach-Object { $s = Safe-Json "$($_.FullName)\status.json"; if ($s -and $s.status -eq "running") { $_ } }).Count
        $completed = @($bgDirs | ForEach-Object { $s = Safe-Json "$($_.FullName)\status.json"; if ($s -and $s.status -eq "completed") { $_ } }).Count
        Write-Output "  Running: $running | Completed: $completed | Total: $($bgDirs.Count)"
    } else {
        Write-Output "  (no background tasks)"
    }
    Write-Output ""

    Write-Output "-- s09: Agent Teams --"
    $team = Safe-Json $TEAM_CONFIG
    if ($team -and $team.members) {
        $team.members | ForEach-Object { Write-Output "  $($_.name) ($($_.role)): $($_.status)" }
    } else {
        Write-Output "  (no team config)"
    }
    Write-Output ""

    Write-Output "-- s12: Worktree Isolation --"
    $wt = Safe-Json $WORKTREES_INDEX
    if ($wt -and $wt.worktrees -and $wt.worktrees.Count -gt 0) {
        $wt.worktrees | ForEach-Object { Write-Output "  $($_.name): $($_.status) (task #$($_.task_id))" }
    } else {
        Write-Output "  (no worktrees)"
    }
}

# ===== cleanup: GC stale harness artifacts =====
function Invoke-Cleanup {
    param([int]$RetainDays = 7, [switch]$Force)
    $removed = @{bg=0; transcripts=0; worktrees=0}
    Write-Output "=== Harness Cleanup ==="

    # s08: remove completed/error bg tasks
    Get-ChildItem "$BG_DIR" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $s = Safe-Json "$($_.FullName)\status.json"
        if ($s -and ($s.status -in @("completed","error","orphaned"))) {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            $removed.bg++
        }
    }
    Write-Output "  s08: $($removed.bg) stale bg tasks removed"

    # s06: remove transcripts older than RetainDays
    $cutoff = (Get-Date).AddDays(-$RetainDays)
    Get-ChildItem "$TRANSCRIPTS_DIR\transcript-*.jsonl" -ErrorAction SilentlyContinue | Where-Object {
        $_.LastWriteTime -lt $cutoff
    } | ForEach-Object {
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        $removed.transcripts++
    }
    Write-Output "  s06: $($removed.transcripts) old transcripts removed (retention: $RetainDays days)"

    # s12: remove worktrees with stale (non-existent) directories
    $idx = Safe-Json $WORKTREES_INDEX
    if ($idx -and $idx.worktrees) {
        $valid = @()
        $idx.worktrees | ForEach-Object {
            if ($_.status -eq "active" -and (Test-Path $_.path)) {
                $valid += $_
            } else {
                git -C $ROOT worktree remove $_.path 2>&1 | Out-Null
                git -C $ROOT branch -D $_.branch 2>&1 | Out-Null
                $removed.worktrees++
            }
        }
        $idx.worktrees = $valid
        $idx | ConvertTo-Json | Set-Content $WORKTREES_INDEX -ErrorAction SilentlyContinue
    }
    Write-Output "  s12: $($removed.worktrees) orphaned worktrees cleaned"
    $total = ($removed.bg + $removed.transcripts + $removed.worktrees)
    Write-Output "Done. $total total removed."
}

# ===== sync: CrossFlow handoff update =====
function Invoke-Sync {
    param([string]$Message)
    $hfPath = "$ROOT\.crossflow\HANDOFF.md"
    $slPath = "$ROOT\.crossflow\SESSION_LOG.md"
    if (-not (Test-Path $hfPath)) { return "Error: .crossflow/HANDOFF.md not found" }

    # Read current handoff to preserve non-volatile fields
    $hf = Get-Content $hfPath -Raw
    $date = Get-Date -Format "yyyy-MM-dd"

    # Count session log lines
    $slCount = (Get-Content $slPath -ErrorAction SilentlyContinue | Where-Object { $_ -match '^\|' }).Count

    # Update HANDOFF.md
    $newHf = @"
# CrossFlow Handoff
> Current session state. Read by all agents on startup.

| Field | Value |
|-------|-------|
| **Date** | $date |
| **Last action** | $Message |
| **Active agent** | OpenCode (big-pickle) |
| **Pending files** | None |
| **Blockers** | None |

"@
    $newHf | Set-Content $hfPath
    "HANDOFF.md updated: $Message"

    # Append to SESSION_LOG.md
    $slEntry = "| $($slCount + 1) | $date | OpenCode (big-pickle) | $Message | ✅ |"
    Add-Content $slPath $slEntry
    "SESSION_LOG.md: entry #$($slCount + 1) appended"
}

# ===== Dispatch =====
switch ($Layer) {
    "compact" {
        switch ($Action) {
            "save" { Invoke-Compact }
            "auto" { Invoke-Compact -Auto }
            default { Invoke-Compact }
        }
    }
    "task" {
        switch ($Action) {
            "create" { New-Task -Subject $Args[0] -Description ($Args[1] ?? "") -BlockedBy ($Args[2] ?? "") }
            "get"    { if ($Args[0]) { Get-Task -Id $Args[0] } else { "Usage: task get <id>" } }
            "update" { if ($Args[0] -and $Args[1]) { Set-Task -Id $Args[0] -Status $Args[1] } else { "Usage: task update <id> <status>" } }
            "list"   { Get-TaskList }
            "claim"  { if ($Args[0] -and $Args[1]) { Set-TaskClaim -Id $Args[0] -Owner $Args[1] } else { "Usage: task claim <id> <owner>" } }
            default  { "Usage: task create|get|update|list|claim" }
        }
    }
    "bg" {
        switch ($Action) {
            "run"   { if ($Args[0]) { Start-BgTask -Command $Args[0] } else { "Usage: bg run <command>" } }
            "check" { Get-BgTask -TaskId $Args[0] }
            "list"  { Get-BgTask }
            default { "Usage: bg run|check|list" }
        }
    }
    "worktree" {
        switch ($Action) {
            "create" { New-Worktree -Name $Args[0] -TaskId ($Args[1] ?? 0) }
            "remove" { if ($Args[0]) { Remove-Worktree -Name $Args[0] } else { "Usage: worktree remove <name>" } }
            "list"   { Get-WorktreeList }
            default  { "Usage: worktree create|remove|list" }
        }
    }
    "status" {
        Get-HarnessStatus
    }
    "cleanup" {
        Invoke-Cleanup
    }
    "sync" {
        if ($Action) { Invoke-Sync -Message $Action } else { "Usage: sync <message text>" }
    }
    "unlock" {
        Invoke-Unlock
    }
}

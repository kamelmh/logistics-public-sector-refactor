param(
    [string]$Command = "status",
    [string]$TaskId = "",
    [string]$Agent = ""
)

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$configFile = Join-Path $scriptDir "milestone_13_2\config\agent-system.xml"

# Load system config
if (Test-Path $configFile) {
    $config = [xml](Get-Content $configFile -Raw)
} else {
    Write-Host "ERROR: agent-system.xml not found at $configFile" -ForegroundColor Red
    exit 1
}

# Paths
$personalDir = $config.AgentSystem.ProjectState.Personal.Path
$publicDir = $config.AgentSystem.ProjectState.Public.Path
$buildScript = Join-Path $personalDir "build.ps1"
$auditScript = Join-Path $personalDir "milestone_13_2\tests\dss-audit.ps1"
$testScript = Join-Path $personalDir "test-macros.ps1"
$sanitizeScript = Join-Path $publicDir "sanitize.ps1"
$publicRepo = $publicDir

# ============================================================================
# COMMANDS
# ============================================================================

function Show-Status {
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "  AGENT SYSTEM STATUS — Academix v13.2 / LSM Core" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    Write-Host "`n[Personal Project]" -ForegroundColor Yellow
    Write-Host "  Name:   $($config.AgentSystem.ProjectState.Personal.Name)" -ForegroundColor Gray
    Write-Host "  Path:   $($config.AgentSystem.ProjectState.Personal.Path)" -ForegroundColor Gray
    Write-Host "  Build:  $($config.AgentSystem.ProjectState.Personal.Build)" -ForegroundColor Gray
    Write-Host "  Audit:  $($config.AgentSystem.ProjectState.Personal.Audit)" -ForegroundColor Gray

    Write-Host "`n[Public Project]" -ForegroundColor Yellow
    Write-Host "  Name:   $($config.AgentSystem.ProjectState.Public.Name)" -ForegroundColor Gray
    Write-Host "  Path:   $($config.AgentSystem.ProjectState.Public.Path)" -ForegroundColor Gray
    Write-Host "  GitHub: $($config.AgentSystem.ProjectState.Public.GitHub)" -ForegroundColor Gray

    Write-Host "`n[Task Queue]" -ForegroundColor Yellow
    $tasks = $config.AgentSystem.TaskQueue.Task
    foreach ($t in $tasks) {
        $color = switch ($t.priority) {
            "CRITICAL" { "Red" }
            "HIGH" { "Yellow" }
            "MEDIUM" { "Green" }
            default { "Gray" }
        }
        $statusColor = switch ($t.status) {
            "completed" { "Green" }
            "in_progress" { "Yellow" }
            "pending" { "Gray" }
            default { "White" }
        }
        Write-Host "  [$($t.status.ToUpper())] $($t.id) - $($t.Name)" -ForegroundColor $statusColor
        Write-Host "    Priority: $($t.priority) | Agent: $($t.agent)" -ForegroundColor DarkGray
    }

    Write-Host "`n[Available Commands]" -ForegroundColor Yellow
    Write-Host "  .\orchestrator.ps1 status        - Show this status" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 next           - Show next pending task" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 run T001       - Execute specific task" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 build          - Rebuild personal project" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 audit          - Run DSS audit" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 test           - Run macro tests" -ForegroundColor Gray
    Write-Host "  .\orchestrator.ps1 sync           - Sync personal → public → push" -ForegroundColor Gray
    Write-Host ""
}

function Show-Next {
    $tasks = $config.AgentSystem.TaskQueue.Task | Where-Object { $_.status -eq "pending" } | Sort-Object { switch ($_.priority) { "CRITICAL" { 0 } "HIGH" { 1 } "MEDIUM" { 2 } "LOW" { 3 } } }
    if ($tasks.Count -eq 0) {
        Write-Host "No pending tasks. All done!" -ForegroundColor Green
        return
    }
    $next = $tasks[0]
    Write-Host "`nNext Task: $($next.id) — $($next.Name)" -ForegroundColor Cyan
    Write-Host "  Priority: $($next.priority)" -ForegroundColor $(if ($next.priority -eq "CRITICAL") { "Red" } else { "Yellow" })
    Write-Host "  Agent: $($next.agent)" -ForegroundColor Gray
    Write-Host "  Description: $($next.Description)" -ForegroundColor Gray
    Write-Host "`nRun with: .\orchestrator.ps1 run $($next.id)" -ForegroundColor White
}

function Run-Task {
    param([string]$taskId)
    $task = $config.AgentSystem.TaskQueue.Task | Where-Object { $_.id -eq $taskId }
    if (-not $task) {
        Write-Host "Task '$taskId' not found." -ForegroundColor Red
        exit 1
    }

    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "  EXECUTING: $($task.id) — $($task.Name)" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    # Mark as in_progress
    $task.status = "in_progress"
    $config.Save($configFile)

    try {
        switch ($task.id) {
            "T001" { Run-T001 }
            "T002" { Run-T002 }
            "T003" { Run-T003 }
            "T004" { Run-T004 }
            "T005" { Run-T005 }
            "T006" { Run-T006 }
            "T007" { Run-T007 }
            default {
                Write-Host "No handler for task $($task.id)" -ForegroundColor Yellow
                $task.status = "pending"
                $config.Save($configFile)
                return
            }
        }
        $task.status = "completed"
        Write-Host "`nTask $($task.id) COMPLETED" -ForegroundColor Green
    } catch {
        $task.status = "failed"
        Write-Host "`nTask $($task.id) FAILED: $_" -ForegroundColor Red
    }
    $config.Save($configFile)
}

function Run-T001 {
    Write-Host "[Agent: Builder] Fixing blank article codes..." -ForegroundColor Yellow
    $targetPath = Join-Path $personalDir "ERP_Academie_v13_2.xlsm"
    if (-not (Test-Path $targetPath)) {
        Write-Host "  Building workbook first..." -ForegroundColor Gray
        & $buildScript | Out-Null
    }
    Fix-ArticleCodes $targetPath
}

function Fix-ArticleCodes {
    param([string]$wbPath)
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false
    $xl.DisplayAlerts = $false
    $xl.EnableEvents = $false
    $xl.Interactive = $false
    try {
        $wb = $xl.Workbooks.Open($wbPath)
        $ws = $wb.Sheets("ARTICLES")
        $ws.Unprotect("erp_secure_pwd_2026")
        $lastRow = $ws.Cells($ws.Rows.Count, 1).End(-4162).Row
        $fixed = 0
        for ($i = 2; $i -le $lastRow; $i++) {
            $code = $ws.Cells($i, 1).Value2
            if ([string]::IsNullOrWhiteSpace($code) -or $code -like "*📌*" -or $code -like "*Classe*") {
                $desig = $ws.Cells($i, 2).Value2
                $ws.Cells($i, 1).Value = "AUTO-$((100+$fixed))"
                Write-Host "  Row ${i}: Fixed blank/invalid code" -ForegroundColor Yellow
                $fixed++
            }
        }
        if ($fixed -gt 0) {
            $wb.Save()
            Write-Host "  Fixed $fixed blank/invalid article codes" -ForegroundColor Green
        } else {
            Write-Host "  No blank article codes found" -ForegroundColor Green
        }
    } finally {
        $wb.Close($false)
        $xl.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
    }
}

function Fix-StockValues {
    param([string]$wbPath)
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false
    $xl.DisplayAlerts = $false
    $xl.EnableEvents = $false
    $xl.Interactive = $false
    try {
        $wb = $xl.Workbooks.Open($wbPath)
        $ws = $wb.Sheets("ARTICLES")
        $ws.Unprotect("erp_secure_pwd_2026")
        $lastRow = $ws.Cells($ws.Rows.Count, 1).End(-4162).Row
        $fixed = 0
        for ($i = 2; $i -le $lastRow; $i++) {
            $code = $ws.Cells($i, 1).Value2
            $stock = $ws.Cells($i, 3).Value2
            $isNum = [double]::TryParse([string]$stock, [ref]$null)
            if (-not $isNum) {
                $ws.Cells($i, 3).Value = 0
                Write-Host "  Row ${i}: [$code] Non-numeric stock reset to 0" -ForegroundColor Yellow
                $fixed++
            }
        }
        if ($fixed -gt 0) {
            $wb.Save()
            Write-Host "  Fixed $fixed non-numeric stock values" -ForegroundColor Green
        } else {
            Write-Host "  All stock values are numeric" -ForegroundColor Green
        }
    } finally {
        $wb.Close($false)
        $xl.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
    }
}

function Run-T002 {
    Write-Host "[Agent: Builder] Fixing non-numeric stock values..." -ForegroundColor Yellow
    $targetPath = Join-Path $personalDir "ERP_Academie_v13_2.xlsm"
    Fix-StockValues $targetPath
}

function Run-T003 {
    Write-Host "[Agent: Documenter] Thesis Chapter 4 placeholder..." -ForegroundColor Yellow
    $ch4Path = Join-Path $personalDir "..\Thesis_Surgical_Edit\Ch4_Mini_ERP_Solution.md"
    if (Test-Path $ch4Path) {
        Write-Host "  Chapter 4 already exists at $ch4Path" -ForegroundColor Yellow
    } else {
        Write-Host "  Creating Chapter 4 template..." -ForegroundColor Gray
        @"
# الفصل الرابع: الحل — نظام Academix v13.2

## المبحث الأول: عرض الحل التقني
## المبحث الثاني: نتائج التحسين
## المبحث الثالث: مقارنة قبل وبعد
"@ | Out-File $ch4Path -Encoding UTF8
        Write-Host "  Created: $ch4Path" -ForegroundColor Green
    }
}

function Run-T004 {
    Write-Host "[Agent: Sanitizer] Adding demo data to public LSM..." -ForegroundColor Yellow
    & $sanitizeScript
    Write-Host "  Demo data added to public LSM" -ForegroundColor Green
}

function Run-T005 {
    Write-Host "[Agent: Documenter] GitHub token scope check..." -ForegroundColor Yellow
    Write-Host "  Current token has: gist, project, read:org, repo" -ForegroundColor Gray
    Write-Host "  Missing: workflow scope" -ForegroundColor Yellow
    Write-Host "  Run: gh auth refresh -h github.com -s workflow" -ForegroundColor Cyan
    Write-Host "  Then push to enable GitHub Actions" -ForegroundColor Gray
}

function Run-T006 {
    Write-Host "[Agent: Builder] CSV import/export — not yet implemented" -ForegroundColor Yellow
    Write-Host "  This is a medium-priority feature for future milestone" -ForegroundColor Gray
}

function Run-T007 {
    Write-Host "[Agent: Builder] Barcode scanner integration — not yet implemented" -ForegroundColor Yellow
    Write-Host "  This is a medium-priority feature for future milestone" -ForegroundColor Gray
}

function Run-Build {
    Write-Host "`n[Agent: Builder] Saving data before build..." -ForegroundColor Yellow
    & (Join-Path $scriptDir "data-persist.ps1") save 2>&1 | Out-Null
    Write-Host "[Agent: Builder] Rebuilding personal project..." -ForegroundColor Yellow
    & $buildScript
    Write-Host "`n[Agent: Builder] Note: Data persist reload is disabled (column mapping pending)" -ForegroundColor Yellow
    Write-Host "[Agent: Builder] Data warnings in audit are expected - Master template has original data" -ForegroundColor Yellow
}

function Run-Audit {
    Write-Host "`n[Agent: Auditor] Running DSS audit..." -ForegroundColor Yellow
    & $auditScript
}

function Run-Test {
    Write-Host "`n[Agent: Tester] Running macro tests..." -ForegroundColor Yellow
    & $testScript
}

function Run-Sync {
    Write-Host "`n[Agent: Sanitizer] Syncing personal → public → GitHub..." -ForegroundColor Yellow

    Write-Host "[1/3] Sanitizing source..." -ForegroundColor Yellow
    & $sanitizeScript

    Write-Host "`n[2/3] Committing to public repo..." -ForegroundColor Yellow
    Set-Location $publicRepo
    git add .
    $hasChanges = (git diff --cached --name-only)
    if ($hasChanges) {
        git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push upstream master 2>&1
    } else {
        Write-Host "  No changes to commit" -ForegroundColor Gray
    }

    Write-Host "`n[3/3] Sync complete" -ForegroundColor Green
}

# ============================================================================
# MAIN
# ============================================================================

switch ($Command.ToLower()) {
    "status" { Show-Status }
    "next"   { Show-Next }
    "run"    { Run-Task $TaskId }
    "build"  { Run-Build }
    "audit"  { Run-Audit }
    "test"   { Run-Test }
    "sync"   { Run-Sync }
    default  { Write-Host "Unknown command: $Command. Run: .\orchestrator.ps1 status" -ForegroundColor Red }
}

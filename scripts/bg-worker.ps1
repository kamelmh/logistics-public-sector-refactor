<#
.SYNOPSIS
    Background Pipeline Runner for Academix v13.2
.DESCRIPTION
    Executes build, verify, audit, and test pipelines asynchronously.
    Results stored in .tasks/bg/ directory with status tracking.
    Notifications drained before each LLM call.
.LAYER
    s08 - Background Tasks
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('start', 'status', 'stop', 'drain', 'run')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet('build', 'verify', 'audit', 'test', 'thesis')]
    [string]$Pipeline,

    [Parameter(Mandatory=$false)]
    [string]$JobName
)

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$BgDir = Join-Path $ProjectRoot ".tasks\bg"
$LogDir = Join-Path $ProjectRoot "logs"

if (-not (Test-Path $BgDir)) { New-Item -ItemType Directory -Path $BgDir -Force | Out-Null }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Get-Timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }

function Start-Pipeline {
    param([string]$Name, [scriptblock]$Script)
    $job = Start-Job -Name "academix-$Name" -ScriptBlock $Script
    $status = @{
        job_id = $job.Id
        name = $name
        status = "running"
        started = Get-Timestamp
        result_file = Join-Path $BgDir "$Name-$(Get-Timestamp).json"
    }
    $status | ConvertTo-Json | Set-Content (Join-Path $BgDir "$Name-latest.json")
    Write-Output "[$Name] Started (Job ID: $($job.Id))"
    return $status
}

function Get-Status {
    $jobs = Get-Job -Name "academix-*" -ErrorAction SilentlyContinue
    if (-not $jobs) { Write-Output "No background jobs running"; return }
    foreach ($j in $jobs) {
        $state = $j.State
        $latest = Get-Content (Join-Path $BgDir "$($j.Name.Replace('academix-',''))-latest.json") -ErrorAction SilentlyContinue | ConvertFrom-Json
        Write-Output "[$($j.Name)] Status: $state"
        if ($state -eq "Completed") {
            $result = Receive-Job $j -ErrorAction SilentlyContinue
            Write-Output "  Result: $($result | Select-Object -First 3)"
        }
    }
}

function Stop-Pipeline {
    param([string]$Name)
    $job = Get-Job -Name "academix-$Name" -ErrorAction SilentlyContinue
    if ($job) { Stop-Job $job; Remove-Job $job; Write-Output "[$Name] Stopped" }
    else { Write-Output "[$Name] Not found" }
}

function Drain-Notifications {
    $jobs = Get-Job -Name "academix-*" -ErrorAction SilentlyContinue
    $notifications = @()
    foreach ($j in $jobs) {
        if ($j.State -eq "Completed") {
            $output = Receive-Job $j -ErrorAction SilentlyContinue
            $notifications += @{ job = $j.Name; output = $output; timestamp = Get-Timestamp }
            Remove-Job $j
        }
    }
    $notifications | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $BgDir "drain-$(Get-Timestamp).json")
    Write-Output "Drained $($notifications.Count) completed job(s)"
    return $notifications
}

function Run-Pipeline {
    param([string]$Name)
    $scripts = @{
        build = { & (Join-Path $using:ProjectRoot "vbe-auto\build.ps1") -ConfigPath (Join-Path $using:ProjectRoot "vbe-auto\config.json") 2>&1 }
        verify = { & (Join-Path $using:ProjectRoot "vbe-auto\verify.ps1") -ConfigPath (Join-Path $using:ProjectRoot "vbe-auto\config.json") 2>&1 }
        audit = { & (Join-Path $using:ProjectRoot "milestone_13_2\tests\dss-audit.ps1") 2>&1 }
        test = { & (Join-Path $using:ProjectRoot "Software_Surgical_Edit\test-macros.ps1") 2>&1 }
        thesis = { & (Join-Path $using:ProjectRoot "Thesis_Surgical_Edit\build-thesis.ps1") 2>&1 }
    }
    if ($scripts.ContainsKey($Name)) {
        Start-Pipeline -Name $Name -Script $scripts[$Name]
    } else {
        Write-Error "Unknown pipeline: $Name"
    }
}

switch ($Action) {
    'start' {
        if (-not $Pipeline) { Write-Error "Pipeline parameter required for start"; exit 1 }
        Run-Pipeline -Name $Pipeline
    }
    'status' { Get-Status }
    'stop' {
        if (-not $Pipeline) { Write-Error "Pipeline parameter required for stop"; exit 1 }
        Stop-Pipeline -Name $Pipeline
    }
    'drain' { Drain-Notifications | Out-Null }
    'run' {
        if (-not $Pipeline) { Write-Error "Pipeline parameter required for run"; exit 1 }
        Run-Pipeline -Name $Pipeline
    }
}

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Init", "Test", "Promote", "Abort")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$IterationId,

    [string]$MetricCommand = "& \".\vbe-auto\verify.ps1\" -ConfigPath \".\vbe-auto\config.json\""
)

$WorktreeRoot = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.opencode\sandboxes"
$SandboxPath = Join-Path $WorktreeRoot $IterationId

if ($Action -eq "Init") {
    if (!(Test-Path $WorktreeRoot)) { New-Item -ItemType Directory -Path $WorktreeRoot -Force }
    Write-Host "Creating sandbox for iteration: $IterationId"
    git worktree add $SandboxPath -b "sandbox-$IterationId"
    Write-Host "Sandbox created at: $SandboxPath"
}
elseif ($Action -eq "Test") {
    if (!(Test-Path $SandboxPath)) { throw "Sandbox $IterationId not found. Run Init first." }
    Write-Host "Running metric in sandbox $IterationId..."
    Push-Location $SandboxPath
    try {
        Invoke-Expression $MetricCommand
    }
    finally {
        Pop-Location
    }
}
elseif ($Action -eq "Promote") {
    if (!(Test-Path $SandboxPath)) { throw "Sandbox $IterationId not found." }
    Write-Host "Promoting changes from $IterationId to main..."
    # Stage and commit changes in the worktree
    Push-Location $SandboxPath
    git add .
    git commit -m "Autonomous Iteration $IterationId: Improvement"
    Pop-Location

    # Merge back to main
    git checkout main
    git merge "sandbox-$IterationId"
    
    # Cleanup
    git worktree remove $SandboxPath
    git branch -D "sandbox-$IterationId"
    Write-Host "Iteration $IterationId promoted and cleaned up."
}
elseif ($Action -eq "Abort") {
    if (!(Test-Path $SandboxPath)) { Write-Host "Sandbox $SandboxPath already gone." ; return }
    Write-Host "Aborting iteration $IterationId..."
    git worktree remove $SandboxPath
    git branch -D "sandbox-$IterationId"
    Write-Host "Sandbox $IterationId discarded."
}


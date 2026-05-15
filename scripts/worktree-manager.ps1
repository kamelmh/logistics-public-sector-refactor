# Worktree Manager for Academix v13.2 Engineering Harness
# Implements LCC Layer S12: Worktree Isolation

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("create", "remove", "list", "cleanup")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Name,

    [Parameter(Mandatory=$false)]
    [string]$Branch = "main"
)

$PROJECT_ROOT = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor"
$WORKTREE_DIR = "$PROJECT_ROOT\.worktrees"
$INDEX_FILE = "$WORKTREE_DIR\index.json"

if (-not (Test-Path $WORKTREE_DIR)) {
    New-Item -ItemType Directory -Path $WORKTREE_DIR | Out-Null
}

function Get-Index {
    if (Test-Path $INDEX_FILE) {
        return Get-Content $INDEX_FILE | ConvertFrom-Json
    }
    return @()
}

function Save-Index ([array]$Index) {
    $Index | ConvertTo-Json -Depth 10 | Set-Content $INDEX_FILE
}

switch ($Action) {
    "create" {
        if (-not $Name) { throw "Name is required for create action." }
        $Path = "$WORKTREE_DIR\$Name"
        
        if (Test-Path $Path) {
            Write-Error "Worktree '$Name' already exists at $Path"
            exit 1
        }

        Write-Host "[S12] Creating worktree '$Name'..." -ForegroundColor Cyan
        # Use -b to create a new branch for the worktree to avoid "already checked out" conflicts
        $BranchName = "wt-$Name"
        git worktree add -b $BranchName $Path $Branch
        
        if ($LASTEXITCODE -eq 0) {
            $Index = Get-Index
            $NewItem = [PSCustomObject]@{
                Name = $Name
                Path = $Path
                Branch = $BranchName
                Created = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
            $Index = @($Index) + $NewItem
            Save-Index $Index
            Write-Host "[S12] Worktree created successfully on branch $BranchName." -ForegroundColor Green
        } else {
            Write-Error "Git failed to create worktree."
            exit 1
        }
    }

    "remove" {
        if (-not $Name) { throw "Name is required for remove action." }
        $Path = "$WORKTREE_DIR\$Name"

        Write-Host "[S12] Removing worktree '$Name'..." -ForegroundColor Cyan
        git worktree remove $Path
        
        if ($LASTEXITCODE -eq 0) {
            $Index = Get-Index
            $NewIndex = $Index | Where-Object { $_.Name -ne $Name }
            Save-Index $NewIndex
            Write-Host "[S12] Worktree removed successfully." -ForegroundColor Green
        } else {
            Write-Error "Git failed to remove worktree."
            exit 1
        }
    }

    "list" {
        $Index = Get-Index
        if ($Index.Count -eq 0) {
            Write-Host "No managed worktrees found."
        } else {
            $Index | Format-Table Name, Branch, Created
        }
    }

    "cleanup" {
        Write-Host "[S12] Pruning stale worktrees..." -ForegroundColor Cyan
        git worktree prune
        Write-Host "[S12] Pruning complete." -ForegroundColor Green
    }
}

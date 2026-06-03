param(
    [switch]$Commit
)

$ROOT = Split-Path -Parent $PSScriptRoot
$OUT = Join-Path $ROOT "CLASSIFICATION.md"
$GITMODULES = Join-Path $ROOT ".gitmodules"

function Get-AllItems {
    param([string]$Dir)
    (Get-ChildItem $Dir -Recurse -File -ErrorAction SilentlyContinue).Count
}

function Get-DirSize {
    param([string]$Dir)
    $bytes = (Get-ChildItem $Dir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    if ($bytes -gt 1MB) { "{0:N1} MB" -f ($bytes / 1MB) }
    elseif ($bytes -gt 1KB) { "{0:N0} KB" -f ($bytes / 1KB) }
    else { "{0} B" -f $bytes }
}

$submodules = @{}
if (Test-Path $GITMODULES) {
    $content = Get-Content $GITMODULES -Raw
    $path = $null
    $url = $null
    foreach ($line in $content -split "`n") {
        if ($line -match '\[submodule "(.+)"\]') { $path = $matches[1] }
        elseif ($line -match '^\s*path\s*=\s*(.+)$' -and $path) { $path = $matches[1] }
        elseif ($line -match '^\s*url\s*=\s*(.+)$' -and $path) {
            $submodules[$path] = $matches[1]
            $path = $null
        }
    }
}

$categories = @{
    "Core Project" = @()
    "Platform & Configuration" = @()
    "Third-Party Submodules" = @()
    "Research Experiments" = @()
    "R&D Umbrella" = @()
    "External Dependencies" = @()
    "Reference" = @()
    "Scripts & Utility" = @()
    "Archive & Backups" = @()
}

$corePatterns = @('^Software_Surgical_Edit$', '^Thesis_Surgical_Edit$', '^Final_Delivery_Layout$', '^vbe-auto$', '^vbe-auto-template$')
$configPatterns = @('^\.opencode$', '^\.claude$', '^\.crossflow$', '^\.github$', '^\.tasks$')
$researchPatterns = @('^explore$', '^autoresearch_exploration$', '^cocoindex_exploration$', '^andrej-karpathy-skills$')
$referencePatterns = @('^Academic_References$', '^links$', '^docs$', '^references$')
$scriptPatterns = @('^scripts$', '^scripts-tools$', '^tests$', '^benchmarks$')
$archivePatterns = @('^_archive$', '^backups$')

# Classify each non-hidden top-level directory
$allDirs = Get-ChildItem $ROOT -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'node_modules' } | Sort-Object Name

# Also include hidden dirs that have files (config dirs)
$hiddenDirs = Get-ChildItem $ROOT -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^\.' } | Sort-Object Name

$classified = @{} # dirname -> category
$uncategorized = @()

foreach ($dir in ($allDirs + $hiddenDirs)) {
    $name = $dir.Name
    $fullPath = $dir.FullName
    $files = Get-AllItems $fullPath
    $isSubmodule = $submodules.ContainsKey($name)
    $hasSubmodules = @(Get-ChildItem $fullPath -Directory -ErrorAction SilentlyContinue | Where-Object { $submodules.ContainsKey($_) }).Count -gt 0

    if ($name -match '^(Software_Surgical_Edit|Thesis_Surgical_Edit|Final_Delivery_Layout|vbe-auto(-template)?)$') {
        $categories["Core Project"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Core"
    }
    elseif ($name -match '^\.(opencode|claude|crossflow|github|tasks)$') {
        $categories["Platform & Configuration"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Config"
    }
    elseif ($isSubmodule -and $name -notmatch '^Research_and_Development|^external|^milestone') {
        $categories["Third-Party Submodules"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Submodule"
    }
    elseif ($name -match '^(explore|autoresearch_exploration|cocoindex_exploration|andrej-karpathy-skills)$') {
        $categories["Research Experiments"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Research"
    }
    elseif ($name -eq 'Research_and_Development') {
        $categories["R&D Umbrella"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "RnD"
    }
    elseif ($name -eq 'external') {
        $categories["External Dependencies"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "External"
    }
    elseif ($name -eq 'milestone_13_2') {
        $categories["External Dependencies"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "External"
    }
    elseif ($name -match '^(Academic_References|links|docs|references)$') {
        $categories["Reference"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Reference"
    }
    elseif ($name -match '^(scripts|scripts-tools|tests|benchmarks)$') {
        $categories["Scripts & Utility"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Utility"
    }
    elseif ($name -match '^_archive|backups$') {
        $categories["Archive & Backups"] += @{Name=$name; Files=$files; Submodule=$isSubmodule}
        $classified[$name] = "Archive"
    }
    else {
        $uncategorized += @{Name=$name; Files=$files; Submodule=$isSubmodule}
    }
}

# Generate MARKDOWN
$sb = [System.Text.StringBuilder]::new()

$sb.AppendLine("# Project Directory Classification") | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine("**Academix v13.3** — Direction de l'Éducation, El Bayadh") | Out-Null
$sb.AppendLine("**Author:** Mahi Kamel Abdelghani") | Out-Null
$sb.AppendLine("**Auto-generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')") | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine("---") | Out-Null
$sb.AppendLine() | Out-Null

# Summary table
$sb.AppendLine("## Summary") | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine("| Category | Dirs | Files |") | Out-Null
$sb.AppendLine("|----------|------|-------|") | Out-Null
$totalDirs = 0; $totalFiles = 0
foreach ($cat in $categories.Keys) {
    $dirs = $categories[$cat]
    if ($dirs.Count -eq 0) { continue }
    $f = ($dirs | Measure-Object Files -Sum).Sum
    $sb.AppendLine("| $cat | $($dirs.Count) | $f |") | Out-Null
    $totalDirs += $dirs.Count; $totalFiles += $f
}
if ($uncategorized.Count -gt 0) {
    $f = ($uncategorized | Measure-Object Files -Sum).Sum
    $sb.AppendLine("| Uncategorized | $($uncategorized.Count) | $f |") | Out-Null
    $totalDirs += $uncategorized.Count; $totalFiles += $f
}
$sb.AppendLine("| **Total** | **$totalDirs** | **$totalFiles** |") | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine("---") | Out-Null
$sb.AppendLine() | Out-Null

# Helper function to write a category section
function Write-CategorySection {
    param($Sb, $Title, $Dirs, $Descriptions)
    if ($Dirs.Count -eq 0) { return }
    $Sb.AppendLine("## $Title`n") | Out-Null
    $Sb.AppendLine("| Directory | Files | Submodule | Size |") | Out-Null
    $Sb.AppendLine("|-----------|-------|-----------|------|") | Out-Null
    foreach ($d in $Dirs) {
        $fullPath = Join-Path $ROOT $d.Name
        $size = if (Test-Path $fullPath) { Get-DirSize $fullPath } else { "?" }
        $sub = if ($d.Submodule) { "Yes" } else { "—" }
        $desc = if ($Descriptions -and $Descriptions.ContainsKey($d.Name)) { " — $($Descriptions[$d.Name])" } else { "" }
        $sb.AppendLine("| `$($d.Name)` | $($d.Files) | $sub | $size |") | Out-Null
    }
    $Sb.AppendLine() | Out-Null
}

# Built-in descriptions
$descriptions = @{
    "Software_Surgical_Edit" = "VBA source (canonical) — .bas, .frm, .xlsm"
    "Thesis_Surgical_Edit" = "Thesis documents — chapters, style scripts, defense/"
    "Final_Delivery_Layout" = "Client-ready delivery mirror"
    "vbe-auto" = "Build pipeline — build.ps1, verify.ps1"
    "vbe-auto-template" = "Scaffolding template"
    ".opencode" = "OpenCode platform — skills, bootstrap, plugins"
    ".claude" = "Claude Code settings"
    ".crossflow" = "Multi-agent orchestration"
    ".github" = "GitHub CI/CD workflows"
    ".tasks" = "Task tracking + background queue"
    "Research_and_Development" = "5 submodules + local thesis copy"
    "external" = "Shared VBA core library (lsm-vba-core)"
    "milestone_13_2" = "Workspace with public-lsm submodule"
    "Academic_References" = "Course materials, ERP data"
    "links" = "Cross-reference path markers"
    "docs" = "Planning, superpowers, test-generator"
    "references" = "Seance examples"
    "scripts" = "harness.ps1 + bg-worker.ps1"
    "scripts-tools" = "API key management"
    "tests" = "Test generator utility"
    "benchmarks" = "Performance benchmark snapshots"
    "_archive" = "Legacy .xlsm builds"
    "backups" = "Daily auto-backups"
}

foreach ($cat in $categories.Keys) {
    $dirs = $categories[$cat]
    if ($dirs.Count -eq 0) { continue }
    Write-CategorySection $sb $cat $dirs $descriptions
}

# Uncategorized
if ($uncategorized.Count -gt 0) {
    $sb.AppendLine("## Uncategorized`n") | Out-Null
    $sb.AppendLine("| Directory | Files | Submodule |") | Out-Null
    $sb.AppendLine("|-----------|-------|-----------|") | Out-Null
    foreach ($d in $uncategorized) {
        $sub = if ($d.Submodule) { "Yes" } else { "—" }
        $sb.AppendLine("| `$($d.Name)` | $($d.Files) | $sub |") | Out-Null
    }
    $sb.AppendLine() | Out-Null
}

# Submodule appendix
$sb.AppendLine("## Git Submodules ($($submodules.Count) total)`n") | Out-Null
$sb.AppendLine("| Path | URL |") | Out-Null
$sb.AppendLine("|------|-----|") | Out-Null
foreach ($sm in ($submodules.GetEnumerator() | Sort-Object Key)) {
    # Shorten common prefixes
    $url = $sm.Value
    $sb.AppendLine("| `$($sm.Key)` | $url |") | Out-Null
}
$sb.AppendLine() | Out-Null

# Quick reference
$sb.AppendLine("## Daily Workflow`n") | Out-Null
$sb.AppendLine('```powershell') | Out-Null
$sb.AppendLine('# Build ERP from source') | Out-Null
$sb.AppendLine('& "vbe-auto\build.ps1" -ConfigPath "vbe-auto\config.json"') | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine('# Verify ERP (105 checks)') | Out-Null
$sb.AppendLine('& "vbe-auto\verify.ps1" -ConfigPath "vbe-auto\config.json"') | Out-Null
$sb.AppendLine() | Out-Null
$sb.AppendLine('# Build thesis PDF') | Out-Null
$sb.AppendLine('& "Thesis_Surgical_Edit\build-thesis.ps1"') | Out-Null
$sb.AppendLine('```') | Out-Null
$sb.AppendLine() | Out-Null

$content = $sb.ToString()
$content | Set-Content $OUT -Encoding UTF8 -Force
Write-Host "Written: $OUT ($($content.Length) chars)"

if ($Commit) {
    git -C $ROOT add $OUT
    git -C $ROOT commit -m "chore: auto-update CLASSIFICATION.md ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    Write-Host "Committed CLASSIFICATION.md"
}

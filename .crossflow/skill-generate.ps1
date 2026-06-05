<#
.SYNOPSIS
    CrossFlow Skill Generator — auto-generates SKILL.md from successful task results.

.DESCRIPTION
    Reads opus-results.md, finds DONE tasks, and generates hermes-agent compatible
    SKILL.md files in .crossflow/skills/ directory.

.EXAMPLE
    .\skill-generate.ps1                    # Generate from all DONE tasks
    .\skill-generate.ps1 -TaskId TASK-001   # Generate from specific task
#>

param(
    [string]$TaskId,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$CrossflowDir = $PSScriptRoot
$ResultsFile = Join-Path $CrossflowDir "opus-results.md"
$SkillsDir = Join-Path $CrossflowDir "skills"

# ─── Parse Results ──────────────────────────────────────────────
function Get-DoneTasks {
    param([string]$TaskIdFilter)

    $content = Get-Content $ResultsFile -Raw
    $tasks = @()
    $blocks = $content -split '(?=### \[TASK-)'

    foreach ($block in $blocks) {
        if ($block -match '### \[(TASK-\d+)\]\s+(.+)') {
            $id = $Matches[1]
            $title = $Matches[2]

            if ($TaskIdFilter -and $id -ne $TaskIdFilter) { continue }

            $status = "PENDING"
            if ($block -match '\*\*Status\*\*:\s*(\S+)') {
                $status = $Matches[1]
            }

            if ($status -ne "DONE") { continue }

            $output = ""
            if ($block -match '\*\*Output\*\*:\s*\n((?:.*\n)*?)(?=\n---|\z)') {
                $output = $Matches[1].Trim()
            }

            $tasks += [PSCustomObject]@{
                Id = $id
                Title = $title
                Output = $output
            }
        }
    }
    return $tasks
}

# ─── Generate SKILL.md ─────────────────────────────────────────
function New-SkillFile {
    param(
        [string]$TaskId,
        [string]$Title,
        [string]$Output
    )

    # Generate skill name from title
    $skillName = $Title -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-' -replace '-+', '-'
    $skillName = $skillName.ToLower()

    # Extract tags from output
    $tags = @("ERP", "VBA", "CrossFlow")
    if ($Output -match 'security|audit|vulnerability') { $tags += "Security" }
    if ($Output -match 'thesis|defense|jury') { $tags += "Thesis" }
    if ($Output -match 'refactor|module|architecture') { $tags += "Architecture" }
    if ($Output -match 'review|quality|correctness') { $tags += "Quality" }

    # Extract related skills
    $relatedSkills = @()
    if ($TaskId -eq "TASK-001") { $relatedSkills = @("security-audit") }
    if ($TaskId -eq "TASK-002") { $relatedSkills = @("thesis-review") }
    if ($TaskId -eq "TASK-003") { $relatedSkills = @("refactoring") }
    if ($TaskId -eq "TASK-004") { $relatedSkills = @("defense-qa") }

    # Generate SKILL.md content
    $skillContent = @"
---
name: $skillName
description: "Auto-generated from ${TaskId}: ${Title}"
version: 1.0.0
author: CrossFlow-Opus
license: MIT
platforms: [windows, linux, macos]
metadata:
  crossflow:
    tags: [$($tags -join ', ')]
    related_skills: [$($relatedSkills -join ', ')]
    source_task: $TaskId
    generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
---

# $Title

Auto-generated skill from CrossFlow-Opus task execution.

## Source

- **Task**: $TaskId
- **Title**: $Title
- **Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Output

$Output

## Usage

This skill was auto-generated from a successful task execution.
Use the knowledge above to guide similar tasks in the future.

## Ground Truth

| Param | Value |
|-------|-------|
| D | 789 |
| Q* | 37 |
| ROP | 206 |
| SS | 200 |
| LT | 2 days |
| S | 801.45 DZD |
| PU | 4,500 DZD |
| I | 20% |

## Changelog

- v1.0.0: Auto-generated from $TaskId
"@

    return $skillContent
}

# ─── Main ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  === CrossFlow Skill Generator ===" -ForegroundColor Yellow
Write-Host ""

$tasks = Get-DoneTasks -TaskIdFilter $TaskId

if (-not $tasks) {
    Write-Host "  No DONE tasks found in opus-results.md" -ForegroundColor Red
    exit 0
}

$generated = 0

foreach ($task in $tasks) {
    Write-Host "  Processing: [$($task.Id)] $($task.Title)" -ForegroundColor White

    $skillContent = New-SkillFile -TaskId $task.Id -Title $task.Title -Output $task.Output
    $skillFile = Join-Path $SkillsDir "$($task.Id.ToLower())-skill.md"

    if (-not $DryRun) {
        Set-Content -Path $skillFile -Value $skillContent -Encoding UTF8
        Write-Host "    Generated: $skillFile" -ForegroundColor Green
    } else {
        Write-Host "    [DRY RUN] Would generate: $skillFile" -ForegroundColor Yellow
    }

    $generated++
}

Write-Host ""
Write-Host "  Generated: $generated skill files" -ForegroundColor Cyan
Write-Host ""

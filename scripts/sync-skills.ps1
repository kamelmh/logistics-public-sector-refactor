# sync-skills.ps1 — Regenerates all missing SKILL.md files and fixes links/09-Skills pointers
$ocSkills = Join-Path $env:USERPROFILE ".opencode\skills"
$root = Split-Path -Parent $PSScriptRoot
$specRoot = Join-Path $root ".opencode\skills_spectrum"

$coreSkills = @{
    "crossflow" = @"
# crossflow — Multi-Agent Cross-Window Flow

## When to use
For coordinating work across multiple agent windows (A/B/C/D) that need synchronized context via .crossflow/HANDOFF.md.

## Workflow
1. Read .crossflow/HANDOFF.md — single source of truth
2. Read .crossflow/MASTER_CONTEXT.md for multi-window orchestration
3. Write updates to HANDOFF.md after each significant action
4. Use OVERFLOW/ for out-of-band messages
"@
    "crossflow-orchestrator" = @"
# crossflow-orchestrator — Multi-Window Session Coordinator

## When to use
When orchestrating 2+ agent windows in parallel. Each window has a distinct role (Scout, Master, Inspector).

## Workflow
1. Assign roles (A=explore, B=build, C=audit, D=master-review)
2. Write to SESSION_LOG.md after each window completes
3. Sync via .crossflow/HANDOFF.md after each phase
4. Use trio-identity protocol for handoffs
"@
    "python-docx-tools" = @"
# python-docx-tools — Thesis DOCX Manipulation

## When to use
For direct python-docx operations on thesis DOCX files: footnote injection, table formatting, section manipulation, style application.

## Tools
- footnotes.py — CNEPD format footnote injection from master-references.json
- all-footnotes.py — Comprehensive footnote pass on all citations
- add-page-numbers.py — Section breaks + Abjad/decimal page numbering
- add-toc.py — Table of contents via Word fields
- format-tables.py — Table styling and captioning
"@
    "semantic-memory" = @"
# semantic-memory — Session Memory Management

## When to use
For saving and recalling cross-session memory. Complements notepad.md and project-memory.json.

## Workflow
1. `./scripts/checkpoint.ps1 save <label>` — snapshot current state
2. `./scripts/checkpoint.ps1 list` — view available checkpoints
3. `./scripts/checkpoint.ps1 restore <label>` — restore to checkpoint
4. Memory is auto-pruned to last 10 checkpoints
"@
    "ssd-tools" = @"
# ssd-tools — SSD Health & System Tools

## When to use
For monitoring system health, SSD trim, disk space, and performance metrics.

## Commands
- `.\scripts\system-health-test.ps1` — full diagnostics
- `.\scripts\checkpoint.ps1` — snapshot management
- Monitor disk space on C: drive
- Check WINWORD process for stale COM locks
"@
    "vba-deployer" = @"
# vba-deployer — VBA Module Deployment

## When to use
When deploying VBA modules from source (.bas, .frm) into the target .xlsm workbook. Always use via vbe-auto pipeline.

## Pipeline
1. `vbe-auto\build.ps1` — compile .bas→.xlsm
2. `vbe-auto\verify.ps1` — 105 checks on output
3. Check config.json for module include/exclude rules
4. Source canonical: Software_Surgical_Edit/VBA_Modules/
"@
    "workspace-setup" = @"
# workspace-setup — Project Workspace Initialization

## When to use
When setting up a fresh workspace or validating workspace integrity after git operations.

## Checks
1. Verify project root exists and has .git
2. Check vbe-auto/build.ps1 + verify.ps1 accessible
3. Verify VBA module directories have .bas files
4. Run `.\workzone.ps1 status` for full health dashboard
5. Run `.\scripts\update-classification.ps1` to regenerate CLASSIFICATION.md
"@
}

$workspaceSkills = @{
    "autonomous-iteration" = @"
# autonomous-iteration — Self-Improving Auto-Iteration

## When to use
For running improvement cycles where each iteration builds on the previous one: build → measure → improve → repeat.

## Workflow
1. Run `.\scripts\autonomous-mode.ps1 -Mode full` for first pass
2. Review output for variance from target metrics
3. Apply targeted fixes
4. Re-run pipeline and compare metrics
5. Use `learn:compare` in thesis-doctor REPL for side-by-side analysis
"@
    "engineering-harness" = @"
# engineering-harness — Central Orchestration System

## When to use
Always. This is the primary orchestrator that dispatches all sub-systems. Use before any multi-step workflow.

## Architecture
| Layer | Purpose | Script |
|-------|---------|--------|
| s01 | Agent Loop | scripts/autonomous-mode.ps1 |
| s02 | Tool Dispatch | thesis-doctor.ps1 pipeline commands |
| s05 | Skill Loading | autonomous-mode.ps1 Invoke-SkillLoader |
| s06 | Context Compact | scripts/checkpoint.ps1 |
| s08 | Background Tasks | scripts/bg-worker.ps1 |
| s11 | Autonomous Agents | autonomous-mode.ps1 full pipeline |

## Entry
```powershell
.\workzone.ps1          # REPL mode
.\workzone.ps1 pipeline # Full autonomous pipeline
```
"@
    "thesis-to-docx" = @"
# thesis-to-docx — Markdown to DOCX Conversion

## When to use
When converting thesis markdown source to DOCX format via pandoc, with python-docx post-processing.

## Pipeline
1. pandoc Memoire_DSS_Logistique_ElBayadh.md → output.docx
2. footnotes.py injects CNEPD footnotes from master-references.json
3. add-page-numbers.py adds section breaks + page numbering
4. add-toc.py generates table of contents fields
5. customize-reference.py applies CNEPD-compliant reference format
6. thesis-doctor.ps1 COM inspection validates output
"@
}

$spectrumSkills = @{
    "algerian-thesis" = "Use for Algerian CNEPD thesis compliance: Arabic MSA, RTL formatting, 4-chapter structure, footnotes in CNEPD format (Author, Title, Publisher, Year, Page)."
    "doc-coauthoring" = "Use for collaborative document writing with AI review cycles. Generate, review, revise until acceptance criteria met."
    "github-workflow" = "Use for GitHub operations: PR creation, issue management, CI/CD configuration, and release management via gh CLI."
    "mcp-builder" = "Use for building custom MCP servers that connect AI agents to external tools, APIs, and data sources."
    "path-orchestrator" = "Use for resolving project paths, maintaining path registry, and ensuring cross-platform path compatibility."
}

$simpleSpectrum = @{
    "algorithmic-art" = "Use for generating algorithmic art and data visualizations from structured data."
    "brand-guidelines" = "Use for maintaining brand consistency across project documentation and deliverables."
    "canvas-design" = "Use for UI/UX wireframing, mockups, and design system creation."
    "internal-comms" = "Use for drafting internal memos, status reports, and team communications."
    "slack-gif-creator" = "Use for creating Slack emoji and GIF assets for team channels."
    "theme-factory" = "Use for generating consistent color themes, typography systems, and CSS design tokens."
    "web-artifacts-builder" = "Use for building web-based artifacts: HTML reports, interactive dashboards, documentation sites."
}

# Write all core skills
foreach ($kv in $coreSkills.GetEnumerator()) {
    $p = Join-Path $ocSkills $kv.Key "SKILL.md"
    $kv.Value | Set-Content $p -Encoding UTF8 -Force
}
Write-Host "Written $($coreSkills.Count) core skill SKILL.md files" -ForegroundColor Green

# Write all workspace skills
foreach ($kv in $workspaceSkills.GetEnumerator()) {
    $p = Join-Path $ocSkills $kv.Key "SKILL.md"
    $kv.Value | Set-Content $p -Encoding UTF8 -Force
}
Write-Host "Written $($workspaceSkills.Count) workspace skill SKILL.md files" -ForegroundColor Green

# Write Spectrum Drivers
foreach ($kv in $spectrumSkills.GetEnumerator()) {
    $dir = Join-Path $specRoot $kv.Key
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    ($kv.Value + "`n") | Set-Content (Join-Path $dir "SKILL.md") -Encoding UTF8 -Force
}
foreach ($kv in $simpleSpectrum.GetEnumerator()) {
    $dir = Join-Path $specRoot $kv.Key
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    ($kv.Value + "`n") | Set-Content (Join-Path $dir "SKILL.md") -Encoding UTF8 -Force
}
Write-Host "Written $($spectrumSkills.Count + $simpleSpectrum.Count) Spectrum Driver skill SKILL.md files" -ForegroundColor Green

# Write Spectrum REGISTRY.md
$registry = @"
# AI OS Spectrum — Driver Registry
> Academic v13.3 Project Workspace
> Auto-generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## Layers
| Layer | Purpose | Skills |
|-------|---------|--------|
| L0-L4 | AI OS Spectrum layers | 12 drivers |
| Global | Global skill registry | OpenCode + Claude |
| Shell | Engineering harness | harness.ps1 |
| Registry | Skill pointers | links/09-Skills/ |

## Drivers ($($spectrumSkills.Count + $simpleSpectrum.Count) total)
| Driver | Purpose |
|--------|---------|
"@
foreach ($kv in ($spectrumSkills.GetEnumerator() + $simpleSpectrum.GetEnumerator() | Sort-Object Key)) {
    $registry += "`n| $($kv.Key) | $($kv.Value) |"
}
$registry | Set-Content (Join-Path $specRoot "REGISTRY.md") -Encoding UTF8 -Force
Write-Host "Written Spectrum REGISTRY.md" -ForegroundColor Green

# Verify all 32 pointers now resolve
Write-Host "`n=== Verification ===" -ForegroundColor Cyan
$fail = 0
$checks = @(
    @{Name="01/crossflow"; Target="$ocSkills\crossflow\SKILL.md"}
    @{Name="01/crossflow-orchestrator"; Target="$ocSkills\crossflow-orchestrator\SKILL.md"}
    @{Name="01/python-docx-tools"; Target="$ocSkills\python-docx-tools\SKILL.md"}
    @{Name="01/semantic-memory"; Target="$ocSkills\semantic-memory\SKILL.md"}
    @{Name="01/ssd-tools"; Target="$ocSkills\ssd-tools\SKILL.md"}
    @{Name="01/vba-deployer"; Target="$ocSkills\vba-deployer\SKILL.md"}
    @{Name="01/workspace-setup"; Target="$ocSkills\workspace-setup\SKILL.md"}
    @{Name="02/auto-thesis"; Target="$ocSkills\auto-thesis\SKILL.md"}
    @{Name="02/autonomous-iteration"; Target="$ocSkills\autonomous-iteration\SKILL.md"}
    @{Name="02/engineering-harness"; Target="$ocSkills\engineering-harness\SKILL.md"}
    @{Name="02/thesis-docx"; Target="$ocSkills\thesis-docx\SKILL.md"}
    @{Name="02/thesis-to-docx"; Target="$ocSkills\thesis-to-docx\SKILL.md"}
    @{Name="03/algerian-thesis"; Target="$specRoot\algerian-thesis\SKILL.md"}
    @{Name="03/algorithmic-art"; Target="$specRoot\algorithmic-art\SKILL.md"}
    @{Name="03/brand-guidelines"; Target="$specRoot\brand-guidelines\SKILL.md"}
    @{Name="03/canvas-design"; Target="$specRoot\canvas-design\SKILL.md"}
    @{Name="03/doc-coauthoring"; Target="$specRoot\doc-coauthoring\SKILL.md"}
    @{Name="03/github-workflow"; Target="$specRoot\github-workflow\SKILL.md"}
    @{Name="03/internal-comms"; Target="$specRoot\internal-comms\SKILL.md"}
    @{Name="03/mcp-builder"; Target="$specRoot\mcp-builder\SKILL.md"}
    @{Name="03/path-orchestrator"; Target="$specRoot\path-orchestrator\SKILL.md"}
    @{Name="03/slack-gif-creator"; Target="$specRoot\slack-gif-creator\SKILL.md"}
    @{Name="03/theme-factory"; Target="$specRoot\theme-factory\SKILL.md"}
    @{Name="03/web-artifacts-builder"; Target="$specRoot\web-artifacts-builder\SKILL.md"}
    @{Name="04/global-opencode"; Target="$ocSkills"}
    @{Name="05/global-claude"; Target="C:\Users\Administrator\.claude\skills"}
    @{Name="06/crossflow-orchestrator"; Target="$ocSkills\crossflow-orchestrator\SKILL.md"}
    @{Name="06/engineering-harness"; Target="$ocSkills\engineering-harness\SKILL.md"}
    @{Name="06/bg-worker-ps1"; Target="$root\scripts\bg-worker.ps1"}
    @{Name="06/harness-ps1"; Target="$root\scripts\harness.ps1"}
)
foreach ($c in $checks) {
    $exists = Test-Path $c.Target
    if (-not $exists) { 
        Write-Host "✗ $($c.Name) → $($c.Target)" -ForegroundColor Red
        $fail++
    } else { 
        Write-Host "✓ $($c.Name)" -ForegroundColor Green
    }
}
Write-Host "`nResult: $fail failures out of $($checks.Count)" -ForegroundColor $(if($fail -eq 0){"Green"}else{"Red"})

<#
.SYNOPSIS
    CrossFlow Knowledge Extractor — extracts structured knowledge from task results.

.DESCRIPTION
    Reads opus-results.md, extracts knowledge items (findings, recommendations, metrics),
    and writes them to a structured knowledge base in JSON format.
    Based on quant-mind's Paper flow pattern.

.EXAMPLE
    .\knowledge-extract.ps1                    # Extract from all results
    .\knowledge-extract.ps1 -TaskId TASK-001   # Extract from specific task
#>

param(
    [string]$TaskId,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$CrossflowDir = $PSScriptRoot
$ResultsFile = Join-Path $CrossflowDir "opus-results.md"
$KnowledgeFile = Join-Path $CrossflowDir "knowledge-base.json"

# ─── Knowledge Item Schema ──────────────────────────────────────
# Based on quant-mind's BaseKnowledge with SourceRef provenance
function New-KnowledgeItem {
    param(
        [string]$TaskId,
        [string]$Type,        # finding, recommendation, metric, question, answer
        [string]$Content,
        [string]$Severity,    # CRITICAL, HIGH, MED, LOW
        [string]$SourceFile,
        [string]$SourceLine,
        [hashtable]$Metadata = @{}
    )

    return @{
        id = "$TaskId-$(Get-Date -Format 'yyyyMMddHHmmss')-$(Get-Random -Maximum 9999)"
        task_id = $TaskId
        type = $Type
        content = $Content
        severity = $Severity
        source = @{
            file = $SourceFile
            line = $SourceLine
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
        metadata = $Metadata
        embedding_text = "$Type $Content"  # For future vector search
    }
}

# ─── Parse Results ──────────────────────────────────────────────
function Get-TaskResults {
    param([string]$TaskIdFilter)

    $content = Get-Content $ResultsFile -Raw
    $results = @()
    $blocks = $content -split '(?=### \[TASK-)'

    foreach ($block in $blocks) {
        if ($block -match '### \[(TASK-\d+)\]\s+(.+)') {
            $id = $Matches[1]
            $title = $Matches[2]

            if ($TaskIdFilter -and $id -ne $TaskIdFilter) { continue }

            $output = ""
            if ($block -match '\*\*Output\*\*:\s*\n((?:.*\n)*?)(?=\n---|\z)') {
                $output = $Matches[1].Trim()
            }

            $results += [PSCustomObject]@{
                Id = $id
                Title = $title
                Output = $output
                RawBlock = $block
            }
        }
    }
    return $results
}

# ─── Extract Knowledge from Output ──────────────────────────────
function Extract-Knowledge {
    param([string]$TaskId, [string]$Output)

    $items = @()

    # Extract findings (lines starting with numbers or bullets)
    $findings = $Output | Select-String -Pattern '^\d+\.\s+\*\*(.+?)\*\*' -AllMatches
    foreach ($match in $findings.Matches) {
        $content = $match.Groups[1].Value
        $severity = "MED"
        if ($content -match 'CRITICAL|HIGH') { $severity = "HIGH" }
        if ($content -match 'LOW|MEDIUM') { $severity = "LOW" }

        $items += New-KnowledgeItem -TaskId $TaskId -Type "finding" -Content $content -Severity $severity
    }

    # Extract recommendations
    $recs = $Output | Select-String -Pattern '(?:Recommend|Propose|Suggest)\w*:\s*(.+?)(?:\n|$)' -AllMatches
    foreach ($match in $recs.Matches) {
        $items += New-KnowledgeItem -TaskId $TaskId -Type "recommendation" -Content $match.Groups[1].Value -Severity "MED"
    }

    # Extract metrics (numbers with units)
    $metrics = $Output | Select-String -Pattern '(\d+(?:\.\d+)?)\s*(tokens?|DZD|unités?|%)' -AllMatches
    foreach ($match in $metrics.Matches) {
        $items += New-KnowledgeItem -TaskId $TaskId -Type "metric" -Content $match.Value -Severity "LOW" -Metadata @{
            value = [double]$match.Groups[1].Value
            unit = $match.Groups[2].Value
        }
    }

    # Extract questions (from defense Q&A)
    $questions = $Output | Select-String -Pattern '\|\s*\d+\s*\|\s*\*\*(.+?)\*\*' -AllMatches
    foreach ($match in $questions.Matches) {
        $items += New-KnowledgeItem -TaskId $TaskId -Type "question" -Content $match.Groups[1].Value -Severity "LOW"
    }

    return $items
}

# ─── Write Knowledge Base ───────────────────────────────────────
function Write-KnowledgeBase {
    param([array]$Items)

    $existing = @()
    if (Test-Path $KnowledgeFile) {
        $existing = (Get-Content $KnowledgeFile -Raw | ConvertFrom-Json)
    }

    $allItems = $existing + $Items
    $allItems | ConvertTo-Json -Depth 10 | Set-Content $KnowledgeFile -Encoding UTF8

    Write-Host "  Knowledge base: $($allItems.Count) total items ($($Items.Count) new)" -ForegroundColor Green
}

# ─── Main ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  === CrossFlow Knowledge Extractor ===" -ForegroundColor Yellow
Write-Host ""

$results = Get-TaskResults -TaskIdFilter $TaskId

if (-not $results) {
    Write-Host "  No results found in opus-results.md" -ForegroundColor Red
    exit 0
}

$totalItems = 0

foreach ($result in $results) {
    Write-Host "  Processing: [$($result.Id)] $($result.Title)" -ForegroundColor White

    $items = Extract-Knowledge -TaskId $result.Id -Output $result.Output
    $totalItems += $items.Count

    Write-Host "    Extracted: $($items.Count) knowledge items" -ForegroundColor DarkGray

    if (-not $DryRun) {
        Write-KnowledgeBase -Items $items
    }
}

Write-Host ""
Write-Host "  Total: $totalItems knowledge items extracted" -ForegroundColor Cyan
Write-Host ""

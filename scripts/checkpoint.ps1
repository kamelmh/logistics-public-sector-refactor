param(
    [Parameter(Position=0)]
    [ValidateSet("save","restore","list","clean","status")]
    [string]$Command = "status",

    [Parameter(Position=1)]
    [string]$Label = ""
)

$ROOT = Split-Path -Parent $PSScriptRoot
$CHECKPOINT_DIR = Join-Path $ROOT ".checkpoints"
$DOCX_SRC = Join-Path $ROOT "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
$DOCX_OUT = Join-Path $ROOT "Research_and_Development\Thesis_Surgical_Edit\output"
$METRICS_DIR = Join-Path $ROOT "Research_and_Development\Thesis_Surgical_Edit\metrics"

if (-not (Test-Path $CHECKPOINT_DIR)) { New-Item -ItemType Directory -Path $CHECKPOINT_DIR -Force | Out-Null }

function Save-Checkpoint {
    param([string]$Label)
    if (-not $Label) { Write-Error "Usage: checkpoint.ps1 save <label>"; return }

    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeLabel = $Label -replace '[^\w-]', '_'
    $cpDir = Join-Path $CHECKPOINT_DIR "${ts}_${safeLabel}"
    New-Item -ItemType Directory -Path $cpDir -Force | Out-Null

    $manifest = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        label = $Label
        checkpoint_dir = $cpDir
    }

    # Save thesis markdown source
    if (Test-Path $DOCX_SRC) {
        Copy-Item $DOCX_SRC (Join-Path $cpDir "Memoire_DSS_Logistique_ElBayadh.md") -Force
        $manifest.source_md = $true
        $manifest.source_md_size = (Get-Item $DOCX_SRC).Length
    }

    # Save output DOCX + PDF
    if (Test-Path $DOCX_OUT) {
        Get-ChildItem $DOCX_OUT -File | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $cpDir $_.Name) -Force
        }
        $manifest.output_files = @(Get-ChildItem $DOCX_OUT -File | Select-Object -ExpandProperty Name)
    }

    # Save build metrics
    if (Test-Path $METRICS_DIR) {
        Get-ChildItem $METRICS_DIR -File -Filter "build-*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $cpDir $_.Name) -Force
        }
        $manifest.metrics_saved = $true
    }

    # Save HANDOFF + notepad
    $handoffSrc = Join-Path $ROOT ".crossflow\HANDOFF.md"
    $notepadSrc = "C:\Users\Administrator\.opencode\notepad.md"
    if (Test-Path $handoffSrc) { Copy-Item $handoffSrc (Join-Path $cpDir "HANDOFF.md") -Force }
    if (Test-Path $notepadSrc) { Copy-Item $notepadSrc (Join-Path $cpDir "notepad.md") -Force }

    $manifest | ConvertTo-Json | Set-Content (Join-Path $cpDir "checkpoint.json") -Encoding UTF8

    # Prune old checkpoints (keep last 10)
    $all = @(Get-ChildItem $CHECKPOINT_DIR -Directory | Sort-Object Name -Descending)
    if ($all.Count -gt 10) {
        $all[$all.Count-1] | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "[CHECKPOINT] Saved: $cpDir" -ForegroundColor Green
    return $cpDir
}

function Restore-Checkpoint {
    param([string]$Label)
    $dirs = @(Get-ChildItem $CHECKPOINT_DIR -Directory | Sort-Object Name -Descending)

    if ($Label -and $Label -match '^\d{8}-\d{6}') {
        $dirs = $dirs | Where-Object { $_.Name -match "^$Label" }
    } elseif ($Label) {
        $dirs = $dirs | Where-Object { $_.Name -match $Label }
    }

    if ($dirs.Count -eq 0) {
        Write-Error "[CHECKPOINT] No checkpoint found matching: $Label"
        return
    }

    if ($dirs.Count -gt 1) {
        Write-Host "[CHECKPOINT] Multiple matches — using latest:" -ForegroundColor Yellow
        $dirs | Select-Object -First 5 | ForEach-Object { Write-Host "  $($_.Name)" }
    }

    $cp = $dirs[0]
    $cpPath = $cp.FullName

    # Restore source markdown
    $srcMd = Join-Path $cpPath "Memoire_DSS_Logistique_ElBayadh.md"
    if (Test-Path $srcMd) {
        Copy-Item $srcMd $DOCX_SRC -Force
        Write-Host "[CHECKPOINT] Restored source MD" -ForegroundColor Green
    }

    # Restore output files
    Get-ChildItem $cpPath -File | Where-Object { $_.Name -match '\.(docx|pdf)$' } | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $DOCX_OUT $_.Name) -Force
        Write-Host "[CHECKPOINT] Restored: $($_.Name)" -ForegroundColor Green
    }

    # Restore HANDOFF
    $handoffCp = Join-Path $cpPath "HANDOFF.md"
    if (Test-Path $handoffCp) {
        Copy-Item $handoffCp (Join-Path $ROOT ".crossflow\HANDOFF.md") -Force
    }

    Write-Host "[CHECKPOINT] Restored from: $($cp.Name)" -ForegroundColor Green
}

function List-Checkpoints {
    $dirs = @(Get-ChildItem $CHECKPOINT_DIR -Directory | Sort-Object Name -Descending)
    if ($dirs.Count -eq 0) { Write-Host "[CHECKPOINT] No checkpoints found."; return }
    Write-Host "`n=== Checkpoints ===" -ForegroundColor Cyan
    foreach ($d in $dirs) {
        $manifest = Join-Path $d.FullName "checkpoint.json"
        $label = "?"
        if (Test-Path $manifest) {
            $data = Get-Content $manifest -Raw | ConvertFrom-Json
            $label = $data.label
        }
        $size = (Get-ChildItem $d.FullName -File | Measure-Object Length -Sum).Sum
        $sizeStr = if ($size -gt 1KB) { "{0:N0} KB" -f ($size/1KB) } else { "{0} B" -f $size }
        Write-Host "  $($d.Name)  [$label]  ($sizeStr)"
    }
}

function Clean-Checkpoints {
    $dirs = @(Get-ChildItem $CHECKPOINT_DIR -Directory | Sort-Object Name -Descending)
    if ($dirs.Count -le 5) { Write-Host "[CHECKPOINT] Only $($dirs.Count) checkpoints — no cleanup needed."; return }
    $keep = 5
    $remove = $dirs | Select-Object -Skip $keep
    foreach ($d in $remove) {
        Remove-Item -Recurse -Force $d.FullName -ErrorAction SilentlyContinue
    }
    Write-Host "[CHECKPOINT] Cleaned $($remove.Count) old checkpoints (keeping last $keep)" -ForegroundColor Yellow
}

switch ($Command) {
    "save"    { Save-Checkpoint $Label }
    "restore" { Restore-Checkpoint $Label }
    "list"    { List-Checkpoints }
    "clean"   { Clean-Checkpoints }
    "status"  {
        List-Checkpoints
        Write-Host "`nCheckpoint directory: $CHECKPOINT_DIR" -ForegroundColor Gray
        Write-Host "Usage: checkpoint.ps1 save|restore|list|clean [label]" -ForegroundColor Gray
    }
}

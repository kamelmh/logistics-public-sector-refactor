param(
    [string]$Command = "",
    [string]$Path = "",
    [switch]$Json,
    [switch]$Quiet
)

# thesis-doctor.ps1 — Enhanced thesis quality system
# Mahi Kamel Abdelghani | Direction de l'Education El Bayadh
#
# Usage:
#   .\thesis-doctor.ps1                          REPL interactive mode
#   .\thesis-doctor.ps1 inspect:all               Full COM inspection
#   .\thesis-doctor.ps1 score:all                 Full quality scorecard
#   .\thesis-doctor.ps1 learn:report              Learner trend analysis
#   .\thesis-doctor.ps1 fix:all                   Apply all fixes via COM
#   .\thesis-doctor.ps1 pipeline:full             Full build verify score
#   .\thesis-doctor.ps1 save:report               Save scorecard to file
#   .\thesis-doctor.ps1 help                      Show all commands

$ErrorActionPreference = "Continue"
$script:root = Split-Path $MyInvocation.MyCommand.Path -Parent
$script:projectRoot = Split-Path (Split-Path $script:root -Parent) -Parent  # two up: R&D/TSE → project root
$script:styleDir = Join-Path $script:root "style"
$script:outDir = Join-Path $script:root "output"
$script:metricsDir = Join-Path $script:outDir "metrics"
$script:reportDir = Join-Path $script:root "reports"
$null = New-Item -ItemType Directory -Path $script:reportDir -Force

if (-not $Path) { $script:docxPath = Join-Path $script:outDir "Memoire_DSS_Logistique_ElBayadh.docx" }
else { $script:docxPath = $Path }
$script:sourcePath = Join-Path $script:projectRoot "Thesis_Surgical_Edit\Memoire_DSS_Logistique_ElBayadh.md"
$script:pdfPath = Join-Path $script:outDir "Memoire_DSS_Logistique_ElBayadh.pdf"

$script:GOLDEN = @{
    bodyFont       = "Traditional Arabic"
    bodySize       = 14
    heading1Size   = 22; heading1Color = "#1B2631"
    heading2Size   = 18; heading2Color = "#0C447C"
    heading3Size   = 16; heading3Color = "#0C447C"
    margins        = 2.5
    lineSpacing    = 1.5
    pageWidth      = 21.0; pageHeight = 29.7
    tableHeadFill  = "#0C447C"
    tableAltFill   = "#EBF5FB"
    minH1          = 4; minH2 = 6; minH3 = 10
    minParagraphs  = 600
    minTables      = 21
    minFootnotes   = 46
    minTocEntries  = 40
    minSeqFields   = 21
    minSections    = 4
    minSizeKb      = 100
    minPdfKb       = 800
    coverTitle     = "الجمهورية الجزائرية"
}

$script:COMMANDS = @{
    "inspect:body"      = @{ desc = "Inspect body text fonts, alignment, spacing"; group = "Inspect" }
    "inspect:headings"  = @{ desc = "Inspect heading structure (H1/H2/H3) and sizes"; group = "Inspect" }
    "inspect:tables"    = @{ desc = "Inspect table count and formatting"; group = "Inspect" }
    "inspect:footnotes" = @{ desc = "Inspect footnote count and bidi validity"; group = "Inspect" }
    "inspect:toc"       = @{ desc = "Inspect TOC/LOT/SEQ fields and entries"; group = "Inspect" }
    "inspect:pagesetup" = @{ desc = "Inspect page size, margins, sections"; group = "Inspect" }
    "inspect:styles"    = @{ desc = "Inspect named styles in use"; group = "Inspect" }
    "inspect:all"       = @{ desc = "Run all inspections (default)"; group = "Inspect" }
    "score:structure"   = @{ desc = "Grade heading hierarchy, sections, chapters"; group = "Scorecard" }
    "score:formatting"  = @{ desc = "Grade fonts, alignment, spacing"; group = "Scorecard" }
    "score:content"     = @{ desc = "Grade paragraphs, tables, footnotes volume"; group = "Scorecard" }
    "score:toc"         = @{ desc = "Grade TOC/LOT/SEQ field health"; group = "Scorecard" }
    "score:all"         = @{ desc = "Full scorecard (12 categories)"; group = "Scorecard" }
    "fix:font"          = @{ desc = "Set body font to Traditional Arabic 14pt"; group = "Fix" }
    "fix:margins"       = @{ desc = "Set all margins to 2.5cm"; group = "Fix" }
    "fix:rtl"           = @{ desc = "Set all paragraphs to RTL alignment"; group = "Fix" }
    "fix:spacing"       = @{ desc = "Set all paragraphs to 1.5 spacing"; group = "Fix" }
    "fix:toc"           = @{ desc = "Update TOC/LOT fields and page numbers"; group = "Fix" }
    "fix:headings"      = @{ desc = "Fix heading styles and sizes"; group = "Fix" }
    "fix:tables"        = @{ desc = "Format tables (header color, alternating)"; group = "Fix" }
    "fix:footers"       = @{ desc = "Fix page numbering in footers"; group = "Fix" }
    "fix:all"           = @{ desc = "Apply all fixes via Word COM"; group = "Fix" }
    "learn:trends"      = @{ desc = "Show trends across all historical builds"; group = "Learn" }
    "learn:compare"     = @{ desc = "Compare last 2 builds side-by-side"; group = "Learn" }
    "learn:regressions" = @{ desc = "Show regressions across build history"; group = "Learn" }
    "learn:bib"         = @{ desc = "Analyze bibliography integrity"; group = "Learn" }
    "learn:report"      = @{ desc = "Full learner report with recommendations"; group = "Learn" }
    "file:info"         = @{ desc = "Show file info (DOCX/PDF sizes, hashes)"; group = "File" }
    "file:manifest"     = @{ desc = "Show build manifest"; group = "File" }
    "file:history"      = @{ desc = "Show build history from metrics"; group = "File" }
    "pipeline:build"    = @{ desc = "Run build pipeline (pandoc python COM)"; group = "Pipeline" }
    "pipeline:verify"   = @{ desc = "Run verify-thesis.ps1 (25 checks)"; group = "Pipeline" }
    "pipeline:metrics"  = @{ desc = "Run measure + compare metrics"; group = "Pipeline" }
    "pipeline:full"     = @{ desc = "Build verify scorecard"; group = "Pipeline" }
    "save:report"       = @{ desc = "Save inspection + scorecard to report file"; group = "Save" }
    "save:pdf"          = @{ desc = "Save DOCX as PDF via Word COM"; group = "Save" }
    "save:json"         = @{ desc = "Export current metrics as JSON"; group = "Save" }
    "help"              = @{ desc = "Show this help"; group = "System" }
    "quit"              = @{ desc = "Exit interactive mode"; group = "System" }
    "exit"              = @{ desc = "Exit interactive mode"; group = "System" }
}

function Show-Help {
    $groups = $script:COMMANDS.Values | ForEach-Object { $_.group } | Sort-Object -Unique
    Write-Host ""; Write-Host "COMMAND REFERENCE" -ForegroundColor Cyan
    Write-Host "  Usage: .\thesis-doctor.ps1 <command>" -ForegroundColor Gray
    Write-Host "         .\thesis-doctor.ps1    (REPL mode)" -ForegroundColor Gray
    foreach ($g in $groups) {
        Write-Host "`n--- $g ---" -ForegroundColor Yellow
        $script:COMMANDS.GetEnumerator() | Where-Object { $_.Value.group -eq $g } | Sort-Object Name | ForEach-Object {
            Write-Host ("  {0,-24} {1}" -f $_.Key, $_.Value.desc)
        }
    }
}

function Open-WordDoc {
    param([string]$DocxPath, [bool]$ReadOnly = $false, [bool]$Visible = $false)
    try {
        $word = New-Object -ComObject Word.Application
        $word.Visible = $Visible
        $word.DisplayAlerts = 0
        $doc = $word.Documents.Open((Resolve-Path $DocxPath).Path, $false, $ReadOnly)
        return @{ Word = $word; Doc = $doc }
    } catch {
        Write-Host "  [COM ERROR] $_" -ForegroundColor Red
        return $null
    }
}

function Close-WordDoc {
    param($Session)
    if (-not $Session) { return }
    try {
        if ($Session.Doc) {
            $Session.Doc.Close() | Out-Null
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Session.Doc) | Out-Null
        }
        if ($Session.Word) {
            $Session.Word.Quit() | Out-Null
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Session.Word) | Out-Null
        }
    } catch {}
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Start-Sleep -Milliseconds 300
    Get-Process -Name WINWORD -ErrorAction SilentlyContinue | Stop-Process -Force | Out-Null
}

function Kill-Word {
    Get-Process -Name WINWORD -ErrorAction SilentlyContinue | Stop-Process -Force | Out-Null
    Start-Sleep -Milliseconds 500
}

function Invoke-InspectAll {
    $pyScript = Join-Path $script:projectRoot "Thesis_Surgical_Edit\style\inspect_docx_metrics.py"
    if (-not (Test-Path $pyScript)) {
        $pyScript = Join-Path $script:styleDir "inspect_docx_metrics.py"
    }

    if (-not (Test-Path $pyScript)) {
        Write-Host "  [INSPECT] Python script not found, falling back to Word COM..." -ForegroundColor Yellow
        return Invoke-InspectAllCom
    }

    Write-Host "  [INSPECT] Analyzing DOCX via python-docx..." -ForegroundColor Cyan
    try {
        $json = python $pyScript $script:docxPath --json 2>&1 | Out-String
        $obj = $json | ConvertFrom-Json
        $R = @{}
        $obj.psobject.Properties | ForEach-Object {
            $val = $_.Value
            if ($val -is [PSCustomObject]) {
                $ht = @{}
                $val.psobject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
                $val = $ht
            }
            $R[$_.Name] = $val
        }
        Write-Host "  [INSPECT] Done. $( $R.Count ) metrics captured in ~1s." -ForegroundColor Green
        return $R
    } catch {
        Write-Host "  [INSPECT] Python failed ($_), falling back to Word COM..." -ForegroundColor Yellow
        return Invoke-InspectAllCom
    }
}

function Invoke-InspectAllCom {
    Write-Host "  [INSPECT] Opening DOCX in Word COM..." -ForegroundColor Yellow
    $ses = Open-WordDoc $script:docxPath -ReadOnly $true
    if (-not $ses) { return $null }

    $R = @{}
    try {
        $doc = $ses.Doc
        $R["paragraph_count"] = $doc.Paragraphs.Count

        $sec = $doc.Sections.Item(1)
        $R["page_width_cm"]  = [math]::Round($sec.PageSetup.PageWidth * 0.0352778, 1)
        $R["page_height_cm"] = [math]::Round($sec.PageSetup.PageHeight * 0.0352778, 1)
        $R["margins"] = @{ top=0; bottom=0; left=0; right=0 }
        $R["section_count"] = $doc.Sections.Count

        $bodyFontOk = 0; $bodyFontBad = 0; $bodySizeOk = 0; $bodySizeBad = 0
        $rtlOk = 0; $rtlBad = 0; $spacingOk = 0; $spacingBad = 0
        $h1 = 0; $h2 = 0; $h3 = 0; $headings = @()
        $stylesInUse = @{}
        $found = $false
        for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
            $p = $doc.Paragraphs.Item($i)
            $txt = try { $p.Range.Text.Trim() } catch { "" }
            $style = $p.Style.NameLocal

            if ($i -le 10 -and $txt -match $script:GOLDEN.coverTitle) { $found = $true }
            if ($style -eq "Heading 1" -or $style -eq "Titre 1") { $h1++; $headings += @{ level=1; text=$txt.Substring(0,[Math]::Min(60,$txt.Length)) } }
            elseif ($style -eq "Heading 2" -or $style -eq "Titre 2") { $h2++; $headings += @{ level=2; text=$txt.Substring(0,[Math]::Min(60,$txt.Length)) } }
            elseif ($style -eq "Heading 3" -or $style -eq "Titre 3") { $h3++; $headings += @{ level=3; text=$txt.Substring(0,[Math]::Min(60,$txt.Length)) } }

            if ($style -match "Heading|Titre|TOC|Table des|Caption|Légende|Footnote|Note de fin") { continue }
            $f = $p.Range.Font
            if ($f.Name -eq $script:GOLDEN.bodyFont) { $bodyFontOk++ } else { $bodyFontBad++ }
            if ([math]::Abs($f.Size - $script:GOLDEN.bodySize) -lt 0.5) { $bodySizeOk++ } else { $bodySizeBad++ }
            try { if ($p.Range.ParagraphFormat.Alignment -eq 3) { $rtlOk++ } else { $rtlBad++ } } catch { $rtlBad++ }
            try { if ($p.LineSpacing -ge 1.4 -and $p.LineSpacing -le 1.6) { $spacingOk++ } else { $spacingBad++ } } catch { $spacingBad++ }

            $stylesInUse[$style] = $stylesInUse.ContainsKey($style) ? ($stylesInUse[$style] + 1) : 1
        }
        $R["body_font_ok"] = $bodyFontOk; $R["body_font_bad"] = $bodyFontBad
        $R["body_size_ok"] = $bodySizeOk; $R["body_size_bad"] = $bodySizeBad
        $R["rtl_ok"] = $rtlOk; $R["rtl_bad"] = $rtlBad
        $R["spacing_ok"] = $spacingOk; $R["spacing_bad"] = $spacingBad
        $R["h1_count"] = $h1; $R["h2_count"] = $h2; $R["h3_count"] = $h3
        $R["headings"] = $headings
        $R["styles"] = $stylesInUse
        $R["cover_detected"] = $found

        $R["table_count"] = $doc.Tables.Count
        $R["footnote_count"] = $doc.Footnotes.Count
        $R["seq_field_count"] = 0
        try { for ($i = 1; $i -le $doc.Fields.Count; $i++) { $code = $doc.Fields.Item($i).Code.Text; if ($code -match "SEQ") { $R["seq_field_count"]++ } } } catch {}
        $R["toc_entry_count"] = 0
    } catch {
        Write-Host "  [INSPECT ERROR] $_" -ForegroundColor Red
        return $null
    } finally { Close-WordDoc $ses }
    $R["timestamp"] = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "  [INSPECT] COM fallback done." -ForegroundColor Green
    return $R
}

function Show-InspectReport {
    param($R, $Filter = "all")
    if (-not $R) { Write-Host "  No inspection data." -ForegroundColor Red; return }

    Write-Host ""; Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "      THESIS DOCTOR — INSPECTION REPORT" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Timestamp: $($R.timestamp)" -ForegroundColor Gray

    if ($Filter -eq "all" -or $Filter -eq "body") {
        Write-Host "`n─── Body Text ───" -ForegroundColor Green
        Write-Host "  Paragraphs: $($R.paragraph_count)" -ForegroundColor White
        Write-Host "  Body font OK: $($R.body_font_ok) / Bad: $($R.body_font_bad)" -ForegroundColor $(if ($R.body_font_bad -eq 0) { "Green" } else { "Red" })
        Write-Host "  Body size OK: $($R.body_size_ok) / Bad: $($R.body_size_bad)" -ForegroundColor $(if ($R.body_size_bad -eq 0) { "Green" } else { "Red" })
        Write-Host "  RTL OK: $($R.rtl_ok) / Bad: $($R.rtl_bad)" -ForegroundColor $(if ($R.rtl_bad -eq 0) { "Green" } else { "Red" })
        Write-Host "  Spacing 1.5 OK: $($R.spacing_ok) / Bad: $($R.spacing_bad)" -ForegroundColor $(if ($R.spacing_bad -eq 0) { "Green" } else { "Red" })
    }

    if ($Filter -eq "all" -or $Filter -eq "headings") {
        Write-Host "`n─── Heading Structure ───" -ForegroundColor Green
        Write-Host "  H1: $($R.h1_count)  H2: $($R.h2_count)  H3: $($R.h3_count)" -ForegroundColor White
        Write-Host "  Cover detected: $($R.cover_detected)" -ForegroundColor White
        if ($Json) { $R.headings | ConvertTo-Json -Depth 1 } else {
            foreach ($h in $R.headings) {
                $icon = @{1="";2=" ";3="  "}[$h.level]
                Write-Host "  ${icon}H$($h.level): $($h.text)" -ForegroundColor Gray
            }
        }
    }

    if ($Filter -eq "all" -or $Filter -eq "tables") {
        Write-Host "`n─── Tables ───" -ForegroundColor Green
        Write-Host "  Total tables: $($R.table_count)" -ForegroundColor White
    }

    if ($Filter -eq "all" -or $Filter -eq "footnotes") {
        Write-Host "`n─── Footnotes ───" -ForegroundColor Green
        Write-Host "  Footnotes: $($R.footnote_count)" -ForegroundColor White
        Write-Host "  Footnote RTL OK: $($R.footnote_bidi_ok) / Bad: $($R.footnote_bidi_bad)" -ForegroundColor $(if ($R.footnote_bidi_bad -eq 0) { "Green" } else { "Red" })
    }

    if ($Filter -eq "all" -or $Filter -eq "toc") {
        Write-Host "`n─── TOC / SEQ Fields ───" -ForegroundColor Green
        Write-Host "  SEQ fields: $($R.seq_field_count)" -ForegroundColor White
        Write-Host "  TOC entries: $($R.toc_entry_count)" -ForegroundColor White
    }

    if ($Filter -eq "all" -or $Filter -eq "pagesetup") {
        Write-Host "`n─── Page Setup ───" -ForegroundColor Green
        Write-Host "  Page: $($R.page_width_cm) x $($R.page_height_cm) cm" -ForegroundColor White
        Write-Host "  Margins (cm): T=$($R.margins.top) B=$($R.margins.bottom) L=$($R.margins.left) R=$($R.margins.right)" -ForegroundColor White
        Write-Host "  Sections: $($R.section_count)" -ForegroundColor White
    }

    if ($Filter -eq "all" -or $Filter -eq "styles") {
        Write-Host "`n─── Styles in Use ───" -ForegroundColor Green
        $R.styles.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
        }
    }
    Write-Host ""; Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
}

function Invoke-Scorecard {
    param($R)
    if (-not $R) { return $null, $null, $null }
    $G = $script:GOLDEN

    $grades = @{}
    $totals = @{}
    $outOf = @{}

    $gHeading = 0; $maxHeading = 4
    if ($R.h1_count -ge $G.minH1) { $gHeading++ }; if ($R.h2_count -ge $G.minH2) { $gHeading++ }; if ($R.h3_count -ge $G.minH3) { $gHeading++ }
    if ($R.section_count -ge $G.minSections) { $gHeading++ }
    $grades.heading_hierarchy = [math]::Round($gHeading / $maxHeading * 100, 0)
    $totals.heading_hierarchy = $gHeading; $outOf.heading_hierarchy = $maxHeading

    $gSect = $R.section_count -ge 4 ? 100 : ($R.section_count / 4 * 100)
    $grades.sections = [math]::Round([Math]::Min($gSect, 100), 0)
    $totals.sections = $grades.sections; $outOf.sections = 100

    $pCover = $R.cover_detected ? 100 : 0
    $grades.cover_page = $pCover
    $totals.cover_page = $pCover; $outOf.cover_page = 100

    $structScore = [math]::Round(($grades.heading_hierarchy + $grades.sections + $grades.cover_page) / 3, 0)
    $grades.structure = $structScore

    $gFont = $R.body_font_bad -eq 0 -and $R.body_size_bad -eq 0 ? 100 : [math]::Round((1 - ($R.body_font_bad + $R.body_size_bad) / [Math]::Max($R.paragraph_count, 1)) * 100, 0)
    $grades.fonts = $gFont; $totals.fonts = $gFont; $outOf.fonts = 100

    $gRtl = $R.rtl_bad -eq 0 ? 100 : [math]::Round((1 - $R.rtl_bad / [Math]::Max($R.paragraph_count, 1)) * 100, 0)
    $grades.rtl_alignment = $gRtl; $totals.rtl_alignment = $gRtl; $outOf.rtl_alignment = 100

    $gSpacing = $R.spacing_bad -eq 0 ? 100 : [math]::Round((1 - $R.spacing_bad / [Math]::Max($R.paragraph_count, 1)) * 100, 0)
    $grades.line_spacing = $gSpacing; $totals.line_spacing = $gSpacing; $outOf.line_spacing = 100

    $fmtScore = [math]::Round(($grades.fonts + $grades.rtl_alignment + $grades.line_spacing) / 3, 0)
    $grades.formatting = $fmtScore

    $gPara = $R.paragraph_count -ge $G.minParagraphs ? 100 : [math]::Round($R.paragraph_count / $G.minParagraphs * 100, 0)
    $grades.paragraph_volume = [Math]::Min($gPara, 100); $totals.paragraph_volume = $grades.paragraph_volume; $outOf.paragraph_volume = 100

    $gTab = $R.table_count -ge $G.minTables ? 100 : [math]::Round($R.table_count / $G.minTables * 100, 0)
    $grades.table_volume = [Math]::Min($gTab, 100); $totals.table_volume = $grades.table_volume; $outOf.table_volume = 100

    $gFn = $R.footnote_count -ge $G.minFootnotes ? 100 : [math]::Round($R.footnote_count / $G.minFootnotes * 100, 0)
    $grades.footnote_volume = [Math]::Min($gFn, 100); $totals.footnote_volume = $grades.footnote_volume; $outOf.footnote_volume = 100

    $contentScore = [math]::Round(($grades.paragraph_volume + $grades.table_volume + $grades.footnote_volume) / 3, 0)
    $grades.content = $contentScore

    $gSeq = $R.seq_field_count -ge $G.minSeqFields ? 100 : [math]::Round($R.seq_field_count / $G.minSeqFields * 100, 0)
    $grades.seq_fields = [Math]::Min($gSeq, 100); $totals.seq_fields = $grades.seq_fields; $outOf.seq_fields = 100

    $gToc = $R.toc_entry_count -ge $G.minTocEntries ? 100 : [math]::Round($R.toc_entry_count / $G.minTocEntries * 100, 0)
    $grades.toc_entries = [Math]::Min($gToc, 100); $totals.toc_entries = $grades.toc_entries; $outOf.toc_entries = 100

    $tocScore = [math]::Round(($grades.seq_fields + $grades.toc_entries) / 2, 0)
    $grades.toc = $tocScore

    $overall = [math]::Round(($grades.structure + $grades.formatting + $grades.content + $grades.toc) / 4, 0)
    $grades.overall = $overall

    return $grades, $totals, $outOf
}

function Show-ScorecardReport {
    param($grades, $totals, $outOf, $Filter = "all")
    if (-not $grades) { Write-Host "  No scorecard data." -ForegroundColor Red; return }

    $stars = { param($s) if ($s -ge 90) { "⭐⭐⭐⭐⭐" } elseif ($s -ge 80) { "⭐⭐⭐⭐" } elseif ($s -ge 70) { "⭐⭐⭐" } elseif ($s -ge 60) { "⭐⭐" } else { "⭐" } }

    Write-Host ""; Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       THESIS DOCTOR — QUALITY SCORECARD    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan

    $groups = @(
        @{ name="Structure"; keys=@("heading_hierarchy","sections","cover_page") }
        @{ name="Formatting"; keys=@("fonts","rtl_alignment","line_spacing") }
        @{ name="Content"; keys=@("paragraph_volume","table_volume","footnote_volume") }
        @{ name="TOC"; keys=@("seq_fields","toc_entries") }
    )

    foreach ($grp in $groups) {
        Write-Host "`n─── $($grp.name) ───" -ForegroundColor Green
        foreach ($k in $grp.keys) {
            if ($grades.ContainsKey($k)) {
                $s = $grades[$k]; $c = if ($s -ge 90) { "Green" } elseif ($s -ge 70) { "Yellow" } else { "Red" }
                $t = $totals.ContainsKey($k) ? " ($($totals[$k])/$($outOf[$k]))" : ""
                Write-Host "  $(&$stars $s) $($k): $s%$t" -ForegroundColor $c
            }
        }
    }

    Write-Host "`n─── AGGREGATE ───" -ForegroundColor Green
    foreach ($k in @("structure","formatting","content","toc")) {
        $s = $grades[$k]; $c = if ($s -ge 90) { "Green" } elseif ($s -ge 70) { "Yellow" } else { "Red" }
        Write-Host "  $($k): $s%" -ForegroundColor $c
    }

    $ov = $grades.overall; $oc = if ($ov -ge 90) { "Green" } elseif ($ov -ge 70) { "Yellow" } else { "Red" }
    Write-Host "`n  $( &$stars $ov ) OVERALL: $ov%" -ForegroundColor $oc
    Write-Host ""
    if ($Json) { $grades | ConvertTo-Json }
}

function Get-MetricsHistory {
    if (-not (Test-Path $script:metricsDir)) { return @() }
    $builds = @(Get-ChildItem (Join-Path $script:metricsDir "build-*.json") | Sort-Object LastWriteTime)
    $history = @()
    foreach ($b in $builds) {
        try {
            $data = Get-Content $b.FullName -Raw | ConvertFrom-Json
            $history += @{
                build_id = $data.build_id
                timestamp = $data.timestamp
                source = $data.source
                docx = $data.docx
                verify = $data.verify
                buildSteps = $data.build.steps
            }
        } catch {}
    }
    $history
}

function Show-LearnReport {
    $history = Get-MetricsHistory
    if ($history.Count -lt 2) {
        Write-Host "  [LEARN] Need at least 2 builds for trend analysis (found $($history.Count))" -ForegroundColor Yellow
        return
    }

    Write-Host "`n─── LEARNER — TREND ANALYSIS ───" -ForegroundColor Cyan
    Write-Host "  Analyzing $($history.Count) builds: $($history[0].build_id) $($history[-1].build_id)" -ForegroundColor Gray

    $series = @{
        paragraphs = $history | Where-Object { $_.docx.paragraph_count } | ForEach-Object { @{ b = $_.build_id; v = $_.docx.paragraph_count } }
        tables     = $history | Where-Object { $_.docx.table_count } | ForEach-Object { @{ b = $_.build_id; v = $_.docx.table_count } }
        footnotes  = $history | Where-Object { $_.docx.footnote_count } | ForEach-Object { @{ b = $_.build_id; v = $_.docx.footnote_count } }
        size_kb    = $history | Where-Object { $_.docx.file_size_kb } | ForEach-Object { @{ b = $_.build_id; v = $_.docx.file_size_kb } }
        failed     = $history | Where-Object { $_.verify.failed -ne $null } | ForEach-Object { @{ b = $_.build_id; v = $_.verify.failed } }
    }

    Write-Host "`n─── TRENDS ───" -ForegroundColor Green
    foreach ($kv in $series.GetEnumerator()) {
        $vals = $kv.Value | Sort-Object { $_.b }
        if ($vals.Count -lt 2) { continue }
        $first = $vals[0].v; $last = $vals[-1].v
        $dir = if ($last -gt $first) { "UP" } elseif ($last -lt $first) { "DOWN" } else { "STABLE" }
        $arrow = @{UP="↑"; DOWN="↓"; STABLE="→"}[$dir]
        $color = if ($kv.Key -eq "failed") { if ($dir -eq "DOWN") { "Green" } elseif ($dir -eq "UP") { "Red" } else { "Gray" } }
                 else { if ($dir -eq "UP") { "Green" } elseif ($dir -eq "DOWN") { "Red" } else { "Gray" } }
        Write-Host "  $($kv.Key): $($first) $arrow $($last)" -ForegroundColor $color
    }

    $lastVerify = $history[-1].verify
    if ($lastVerify) {
        Write-Host "`n─── LAST VERIFY ───" -ForegroundColor Green
        Write-Host "  Passed: $($lastVerify.passed) / $($lastVerify.total)" -ForegroundColor $(if ($lastVerify.failed -eq 0) { "Green" } else { "Red" })
        Write-Host "  Failed: $($lastVerify.failed)" -ForegroundColor $(if ($lastVerify.failed -eq 0) { "Green" } else { "Red" })
    }
    Write-Host ""
}

function Show-LearnCompare {
    $history = Get-MetricsHistory
    if ($history.Count -lt 2) { Write-Host "  Need at least 2 builds." -ForegroundColor Yellow; return }
    $prev = $history[-2]; $curr = $history[-1]
    Write-Host "`n─── COMPARE: $($prev.build_id) vs $($curr.build_id) ───" -ForegroundColor Cyan
    foreach ($key in @("paragraph_count","table_count","footnote_count","file_size_kb")) {
        $pv = $prev.docx.$key; $cv = $curr.docx.$key
        if ($pv -ne $null -and $cv -ne $null) {
            $diff = $cv - $pv; $sign = if ($diff -gt 0) { "+" } else { "" }
            Write-Host "  ${key}: $pv -> $cv ($sign$diff)" -ForegroundColor Gray
        }
    }
}

function Invoke-FixCmd {
    param([string]$FixCommand)
    Write-Host "  [FIX] Opening DOCX for editing..." -ForegroundColor Yellow
    $ses = Open-WordDoc $script:docxPath -ReadOnly $false -Visible $false
    if (-not $ses) { return }
    $doc = $ses.Doc
    try {
        switch -Wildcard ($FixCommand) {
            "fix:font" {
                $c = 0
                for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
                    $p = $doc.Paragraphs.Item($i)
                    if ($p.Range.Font.Name -ne $script:GOLDEN.bodyFont -or $p.Range.Font.Size -ne $script:GOLDEN.bodySize) {
                        $p.Range.Font.Name = $script:GOLDEN.bodyFont
                        $p.Range.Font.Size = $script:GOLDEN.bodySize
                        $c++
                    }
                }
                Write-Host "  Font set to $($script:GOLDEN.bodyFont) $($script:GOLDEN.bodySize)pt on $c paragraphs" -ForegroundColor Green
            }
            "fix:margins" {
                $cmToPt = $script:GOLDEN.margins * 28.3465
                for ($i = 1; $i -le $doc.Sections.Count; $i++) {
                    $s = $doc.Sections.Item($i)
                    $s.PageSetup.TopMargin = $cmToPt
                    $s.PageSetup.BottomMargin = $cmToPt
                    $s.PageSetup.LeftMargin = $cmToPt
                    $s.PageSetup.RightMargin = $cmToPt
                }
                Write-Host "  All margins set to $($script:GOLDEN.margins)cm across $($doc.Sections.Count) sections" -ForegroundColor Green
            }
            "fix:rtl" {
                $c = 0
                for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
                    $p = $doc.Paragraphs.Item($i)
                    try { if ($p.Range.ParagraphFormat.Alignment -ne 3) { $p.Range.ParagraphFormat.Alignment = 3; $c++ } } catch {}
                }
                Write-Host "  $c paragraphs set to RTL" -ForegroundColor Green
            }
            "fix:spacing" {
                $c = 0
                for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
                    $p = $doc.Paragraphs.Item($i)
                    if ($p.LineSpacing -ne $script:GOLDEN.lineSpacing) {
                        $p.LineSpacing = $script:GOLDEN.lineSpacing
                        $c++
                    }
                }
                Write-Host "  $c paragraphs set to $($script:GOLDEN.lineSpacing) line spacing" -ForegroundColor Green
            }
            "fix:toc" {
                for ($i = 1; $i -le $doc.Fields.Count; $i++) {
                    try { $doc.Fields.Item($i).Update() } catch {}
                }
                Write-Host "  All fields updated" -ForegroundColor Green
            }
            "fix:headings" {
                $h1Size = $script:GOLDEN.heading1Size
                $h2Size = $script:GOLDEN.heading2Size
                $h3Size = $script:GOLDEN.heading3Size
                $c = 0
                for ($i = 1; $i -le $doc.Paragraphs.Count; $i++) {
                    $p = $doc.Paragraphs.Item($i)
                    $style = $p.Style.NameLocal
                    if ($style -match 'Heading\s*1' -or $style -match 'Titre\s*1') { $p.Range.Font.Size = $h1Size; $p.Range.Font.Bold = $true; $c++ }
                    elseif ($style -match 'Heading\s*2' -or $style -match 'Titre\s*2') { $p.Range.Font.Size = $h2Size; $p.Range.Font.Bold = $true; $c++ }
                    elseif ($style -match 'Heading\s*3' -or $style -match 'Titre\s*3') { $p.Range.Font.Size = $h3Size; $p.Range.Font.Bold = $true; $c++ }
                }
                Write-Host "  Fixed $c headings: H1=$h1Size H2=$h2Size H3=$h3Size" -ForegroundColor Green
            }
            "fix:tables" {
                $tc = 0; $ac = 0; $alt = $false
                for ($i = 1; $i -le $doc.Tables.Count; $i++) {
                    $t = $doc.Tables.Item($i)
                    for ($r = 1; $r -le $t.Rows.Count; $r++) {
                        for ($c = 1; $c -le $t.Columns.Count; $c++) {
                            $cell = $t.Cell($r, $c)
                            if ($r -eq 1) { $cell.Shading.BackgroundPatternColor = 0; $tc++ }
                            elseif ($alt) { $cell.Shading.BackgroundPatternColor = 0; $ac++ }
                        }
                    }
                    $alt = !$alt
                }
                Write-Host "  Formatted $($doc.Tables.Count) tables" -ForegroundColor Green
            }
            "fix:footers" {
                for ($i = 1; $i -le $doc.Sections.Count; $i++) {
                    $s = $doc.Sections.Item($i)
                    try {
                        $footer = $s.Footers.Item(1)
                        if ($footer.Range.Fields.Count -gt 0) { $footer.PageNumbers.Add() | Out-Null }
                    } catch {}
                }
                Write-Host "  Page numbers added to footers" -ForegroundColor Green
            }
            "fix:all" {
                Close-WordDoc $ses; $ses = $null
                $pyFormat = Join-Path $script:projectRoot "Thesis_Surgical_Edit\style\fix_docx_formatting.py"
                $pySect = Join-Path $script:projectRoot "Thesis_Surgical_Edit\style\fix_docx_sections.py"
                Write-Host "  [PYTHON] Formatting (font/size/rtl/spacing/headings/tables)..." -ForegroundColor Cyan
                python $pyFormat $script:docxPath --save 2>&1 | Where-Object { $_ -match '"Saved"' -or $_ -match '^{' -or $_ }
                Write-Host "  [PYTHON] Section breaks..." -ForegroundColor Cyan
                python $pySect $script:docxPath --save 2>&1
                Write-Host "  [NOTE] TOC fields update automatically when opened in Word. Skipping COM to avoid lock conflicts." -ForegroundColor Yellow
                Write-Host "  All fixes applied (formatting + sections)." -ForegroundColor Green
            }
            default {
                Write-Host "  Unknown fix command: $FixCommand" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "  [FIX ERROR] $_" -ForegroundColor Red
    } finally {
        $doc.Save() | Out-Null
        Close-WordDoc $ses
    }
}

function Invoke-Pipeline {
    param([string]$Step)
    switch ($Step) {
        "build" {
            Write-Host "  [PIPELINE] Running build..." -ForegroundColor Yellow
            & (Join-Path $script:projectRoot "Thesis_Surgical_Edit\build-thesis.ps1") 2>&1
        }
        "verify" {
            Write-Host "  [PIPELINE] Running verify..." -ForegroundColor Yellow
            & (Join-Path $script:projectRoot "links\03-Build\verify-thesis.ps1") 2>&1
        }
        "metrics" {
            Write-Host "  [PIPELINE] Running metrics..." -ForegroundColor Yellow
            python (Join-Path $script:styleDir "measure-thesis.py") $script:docxPath $script:sourcePath 2>&1
            python (Join-Path $script:styleDir "compare-thesis.py") 2>&1
        }
        "full" {
            Invoke-Pipeline "build"; Invoke-Pipeline "verify"; Invoke-Pipeline "metrics"
            Write-Host "  [PIPELINE] Full pipeline complete." -ForegroundColor Green
        }
    }
}

function Show-FileInfo {
    Write-Host "`n─── File Info ───" -ForegroundColor Green
    if (Test-Path $script:docxPath) {
        $f = Get-Item $script:docxPath
        $hash = (Get-FileHash $script:docxPath -Algorithm MD5).Hash.Substring(0,12)
        Write-Host "  DOCX: $($script:docxPath)" -ForegroundColor White
        Write-Host "  Size: $($f.Length / 1KB -as [int]) KB  MD5: $hash" -ForegroundColor Gray
        Write-Host "  Modified: $($f.LastWriteTime)" -ForegroundColor Gray
    } else { Write-Host "  DOCX not found: $($script:docxPath)" -ForegroundColor Yellow }
    if (Test-Path $script:sourcePath) {
        $f = Get-Item $script:sourcePath
        $hash = (Get-FileHash $script:sourcePath -Algorithm MD5).Hash.Substring(0,12)
        Write-Host "  SOURCE: $($script:sourcePath)" -ForegroundColor White
        Write-Host "  Size: $($f.Length / 1KB -as [int]) KB  MD5: $hash" -ForegroundColor Gray
    } else { Write-Host "  SOURCE not found at $($script:sourcePath)" -ForegroundColor Yellow }
    if (Test-Path $script:pdfPath) {
        $f = Get-Item $script:pdfPath
        Write-Host "  PDF: $($f.Length / 1KB -as [int]) KB" -ForegroundColor Gray
    }
}

function Show-Manifest {
    if (-not (Test-Path $script:outDir)) { Write-Host "  No output directory." -ForegroundColor Yellow; return }
    $manifest = Join-Path $script:outDir "build-manifest.json"
    if (Test-Path $manifest) {
        Get-Content $manifest -Raw | ConvertFrom-Json | Format-List
    } else { Write-Host "  No manifest found." -ForegroundColor Yellow }
}

function Show-History {
    $history = Get-MetricsHistory
    if ($history.Count -eq 0) { Write-Host "  No build history." -ForegroundColor Yellow; return }
    Write-Host "`n─── Build History ───" -ForegroundColor Green
    foreach ($h in $history) {
        Write-Host "  $($h.build_id) | $($h.timestamp) | Size=$($h.docx.file_size_kb)KB | P=$($h.docx.paragraph_count) T=$($h.docx.table_count) F=$($h.docx.footnote_count)" -ForegroundColor Gray
    }
}

function Save-Report {
    $inspect = $global:lastInspect
    if (-not $inspect) { $inspect = Invoke-InspectAll }
    if (-not $inspect) { return }
    $grades, $null, $null = Invoke-Scorecard $inspect
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportPath = Join-Path $script:reportDir "thesis-doctor-report-$timestamp.md"

    $report = @"
# Thesis Doctor Report — $timestamp
## Inspection
| Metric | Value |
|--------|-------|
| Paragraphs | $($inspect.paragraph_count) |
| H1/H2/H3 | $($inspect.h1_count)/$($inspect.h2_count)/$($inspect.h3_count) |
| Tables | $($inspect.table_count) |
| Footnotes | $($inspect.footnote_count) |
| SEQ Fields | $($inspect.seq_field_count) |
| TOC Entries | $($inspect.toc_entry_count) |
| Sections | $($inspect.section_count) |
| Cover | $($inspect.cover_detected) |
| Page | $($inspect.page_width_cm)x$($inspect.page_height_cm)cm |
| Font OK/Bad | $($inspect.body_font_ok)/$($inspect.body_font_bad) |
| RTL OK/Bad | $($inspect.rtl_ok)/$($inspect.rtl_bad) |
| Spacing OK/Bad | $($inspect.spacing_ok)/$($inspect.spacing_bad) |

## Scorecard
"@
    foreach ($kv in $grades.GetEnumerator()) {
        $report += "| $($kv.Key) | $($kv.Value)% |`n"
    }
    $report | Set-Content $reportPath -Encoding UTF8
    Write-Host "  Report saved: $reportPath" -ForegroundColor Green
}

function Save-Pdf {
    Write-Host "  [SAVE] Opening DOCX to save as PDF..." -ForegroundColor Yellow
    $ses = Open-WordDoc $script:docxPath -ReadOnly $false -Visible $false
    if (-not $ses) { return }
    try {
        $pdf = Join-Path $script:outDir "Memoire_DSS_Logistique_ElBayadh.pdf"
        $ses.Doc.SaveAs2((Resolve-Path $script:outDir).Path + "\Memoire_DSS_Logistique_ElBayadh.pdf", 17) | Out-Null
        Write-Host "  PDF saved: $pdf" -ForegroundColor Green
    } catch {
        Write-Host "  [PDF ERROR] $_" -ForegroundColor Red
    } finally {
        Close-WordDoc $ses
    }
}

function Save-Json {
    $inspect = $global:lastInspect
    if (-not $inspect) { Write-Host "  Run inspect:all first." -ForegroundColor Yellow; return }
    $grades, $null, $null = Invoke-Scorecard $inspect
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $jsonPath = Join-Path $script:reportDir "thesis-doctor-metrics-$timestamp.json"
    @{ timestamp = $timestamp; inspect = $inspect; scorecard = $grades } | ConvertTo-Json -Depth 3 | Set-Content $jsonPath -Encoding UTF8
    Write-Host "  Metrics saved: $jsonPath" -ForegroundColor Green
}

$global:lastInspect = $null

function Dispatch {
    param([string]$Cmd)

    switch -Wildcard ($Cmd) {
        "help"              { Show-Help }
        "quit"              { return $false }
        "exit"              { return $false }
        "inspect:all"       { $global:lastInspect = Invoke-InspectAll; Show-InspectReport $global:lastInspect "all" }
        "inspect:body"      { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "body" }
        "inspect:headings"  { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "headings" }
        "inspect:tables"    { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "tables" }
        "inspect:footnotes" { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "footnotes" }
        "inspect:toc"       { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "toc" }
        "inspect:pagesetup" { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "pagesetup" }
        "inspect:styles"    { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; Show-InspectReport $global:lastInspect "styles" }
        "score:all"         { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; $g, $t, $o = Invoke-Scorecard $global:lastInspect; Show-ScorecardReport $g $t $o "all" }
        "score:structure"   { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; $g, $t, $o = Invoke-Scorecard $global:lastInspect; Show-ScorecardReport $g $t $o "structure" }
        "score:formatting"  { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; $g, $t, $o = Invoke-Scorecard $global:lastInspect; Show-ScorecardReport $g $t $o "formatting" }
        "score:content"     { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; $g, $t, $o = Invoke-Scorecard $global:lastInspect; Show-ScorecardReport $g $t $o "content" }
        "score:toc"         { if (-not $global:lastInspect) { $global:lastInspect = Invoke-InspectAll }; $g, $t, $o = Invoke-Scorecard $global:lastInspect; Show-ScorecardReport $g $t $o "toc" }
        "learn:trends"      { Show-LearnReport }
        "learn:compare"     { Show-LearnCompare }
        "learn:regressions" { Show-LearnReport }
        "learn:bib"         { Show-LearnReport }
        "learn:report"      { Show-LearnReport }
        "file:info"         { Show-FileInfo }
        "file:manifest"     { Show-Manifest }
        "file:history"      { Show-History }
        "pipeline:build"    { Invoke-Pipeline "build" }
        "pipeline:verify"   { Invoke-Pipeline "verify" }
        "pipeline:metrics"  { Invoke-Pipeline "metrics" }
        "pipeline:full"     { Invoke-Pipeline "full" }
        "save:report"       { Save-Report }
        "save:pdf"          { Save-Pdf }
        "save:json"         { Save-Json }
        "fix:*"             { Invoke-FixCmd $Cmd }
        default {
            if ($Cmd -and $Cmd -ne "") {
                Write-Host "  Unknown command: $Cmd. Type 'help' for available commands." -ForegroundColor Red
            }
        }
    }
    return $true
}

Kill-Word

if ($Command -ne "") {
    if (-not $script:COMMANDS.ContainsKey($Command)) {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
    Dispatch $Command | Out-Null
} else {
    Write-Host "`n  THESIS DOCTOR v2  Interactive Mode" -ForegroundColor Cyan
    Write-Host "  Type 'help' for commands, 'quit' to exit." -ForegroundColor Cyan
    Write-Host "  DOCX: $(Split-Path $script:docxPath -Leaf)" -ForegroundColor Gray
    Write-Host ""
    $running = $true
    while ($running) {
        $input = Read-Host "  thesis-doctor> "
        if ($input -eq "quit" -or $input -eq "exit") { break }
        if ($input -eq "") { continue }
        $running = Dispatch $input
    }
    Write-Host "`n  Goodbye." -ForegroundColor Green
}

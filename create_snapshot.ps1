$thesisDir = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Thesis_Surgical_Edit"
$outputFile = Join-Path $thesisDir "context_snapshot_v13.2.xml"

$xmlContent = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<thesis_context version=`"13.2`" timestamp=`"`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`">"

function Add-Section {
    param($sectionName, $filePath)
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $xmlContent += "`n  <$sectionName>`n$content`n  </$sectionName>"
    } else {
        $xmlContent += "`n  <$sectionName>FILE_NOT_FOUND: $filePath</$sectionName>"
    }
}

Add-Section "ground_truth" (Join-Path $thesisDir "THESIS_GROUND_TRUTH.md")
Add-Section "outline" (Join-Path $thesisDir "THESIS_CHAPTER_OUTLINE.md")
Add-Section "terminology" (Join-Path $thesisDir "THESIS_TERMINOLOGY_MAPPING.md")
Add-Section "formatting_rules" (Join-Path $thesisDir "style\CNEPD_Footnotes_Guide.md")

$xmlContent += "`n  <chapters>"
$chapters = @("Ch1_Theoretical_Framework.md", "Ch2_Field_Diagnosis.md", "Ch3_System_Design.md", "Ch4_Testing_Results.md")
foreach ($ch in $chapters) {
    $chPath = Join-Path $thesisDir "Chapters\$ch"
    if (Test-Path $chPath) {
        $chContent = Get-Content -Path $chPath -Raw
        $xmlContent += "`n    <chapter filename=`"$ch`">`n$chContent`n    </chapter>"
    }
}
$xmlContent += "`n  </chapters>"

Add-Section "master_document" (Join-Path $thesisDir "Memoire_DSS_Logistique_ElBayadh.md")

$xmlContent += "`n</thesis_context>"
$xmlContent | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Context snapshot created at: $outputFile"

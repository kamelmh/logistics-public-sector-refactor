param([string]$Command)
Write-Host "Command is: $Command"
$docxPath = "output/Memoire_DSS_Logistique_ElBayadh.docx"
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
Write-Host "Opening..."
$doc = $word.Documents.Open((Resolve-Path $docxPath).Path, $false, $true)
Write-Host "Opened! Paragraphs: $($doc.Paragraphs.Count)"
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
Write-Host "Done"

param(
    [string]$Action = "save",
    [string]$WorkbookPath = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\ERP_v13.2.xlsm",
    [string]$DataPath = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\Software_Surgical_Edit\data-persist.json"
)

$ErrorActionPreference = "Stop"

function Save-Data {
    Write-Host "Saving workbook data to JSON..." -ForegroundColor Cyan
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false; $xl.DisplayAlerts = $false; $xl.EnableEvents = $false; $xl.Interactive = $false
    try {
        $wb = $xl.Workbooks.Open($WorkbookPath)
        $data = @{ ARTICLES = @(); MOUVEMENTS = @() }

        $wsArt = $wb.Sheets("ARTICLES")
        $lastRow = $wsArt.Cells($wsArt.Rows.Count, 1).End(-4162).Row
        for ($i = 2; $i -le $lastRow; $i++) {
            $row = @{
                CODE = $wsArt.Cells($i, 1).Value2
                DESIGNATION = $wsArt.Cells($i, 2).Value2
                STOCK = $wsArt.Cells($i, 3).Value2
                UNITE = $wsArt.Cells($i, 4).Value2
                CATEGORIE = $wsArt.Cells($i, 5).Value2
                CLASSE_ABC = $wsArt.Cells($i, 6).Value2
                CMUP = $wsArt.Cells($i, 8).Value2
                SECU = $wsArt.Cells($i, 9).Value2
            }
            $data.ARTICLES += $row
        }

        $wsMouv = $wb.Sheets("MOUVEMENTS")
        $lastMouv = $wsMouv.Cells($wsMouv.Rows.Count, 1).End(-4162).Row
        for ($i = 2; $i -le $lastMouv; $i++) {
            $row = @{
                N_MVT = $wsMouv.Cells($i, 1).Value2
                DATE = $wsMouv.Cells($i, 2).Value2
                CODE_ARTICLE = $wsMouv.Cells($i, 3).Value2
                TYPE_MVT = $wsMouv.Cells($i, 4).Value2
                QTE_ENTREE = $wsMouv.Cells($i, 5).Value2
                QTE_SORTIE = $wsMouv.Cells($i, 6).Value2
                PU = $wsMouv.Cells($i, 7).Value2
                VALEUR = $wsMouv.Cells($i, 8).Value2
                REF_DOC = $wsMouv.Cells($i, 9).Value2
                TIERS = $wsMouv.Cells($i, 10).Value2
            }
            $data.MOUVEMENTS += $row
        }

        $data | ConvertTo-Json -Depth 5 | Out-File $DataPath -Encoding UTF8
        Write-Host "  Saved: ARTICLES ($($data.ARTICLES.Count) rows), MOUVEMENTS ($($data.MOUVEMENTS.Count) rows)" -ForegroundColor Green
    } finally {
        if ($null -ne $wb) { $wb.Close($false) }
        if ($null -ne $xl) { $xl.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null }
    }
}

function Load-Data {
    Write-Host "Loading data from JSON into workbook..." -ForegroundColor Cyan
    if (-not (Test-Path $DataPath)) {
        Write-Host "  No data file found at $DataPath" -ForegroundColor Yellow
        return
    }

    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false; $xl.DisplayAlerts = $false; $xl.EnableEvents = $false; $xl.Interactive = $false
    try {
        $wb = $xl.Workbooks.Open($WorkbookPath)
        $data = Get-Content $DataPath -Raw | ConvertFrom-Json

        $wsArt = $wb.Sheets("ARTICLES")
        $wsArt.Unprotect("erp_secure_pwd_2026")
        # Clear existing data (keep header row)
        $lastRow = $wsArt.Cells($wsArt.Rows.Count, 1).End(-4162).Row
        if ($lastRow -gt 1) { $wsArt.Range("A2:I$lastRow").ClearContents() }

        $row = 2
        foreach ($item in $data.ARTICLES) {
            $wsArt.Cells($row, 1).Value = $item.CODE
            $wsArt.Cells($row, 2).Value = $item.DESIGNATION
            $wsArt.Cells($row, 3).Value = $item.STOCK
            $wsArt.Cells($row, 4).Value = $item.UNITE
            $wsArt.Cells($row, 5).Value = $item.CATEGORIE
            $wsArt.Cells($row, 6).Value = $item.CLASSE_ABC
            $wsArt.Cells($row, 8).Value = $item.CMUP
            $wsArt.Cells($row, 9).Value = $item.SECU
            $row++
        }
        Write-Host "  Loaded ARTICLES: $($data.ARTICLES.Count) rows" -ForegroundColor Green

        $wsMouv = $wb.Sheets("MOUVEMENTS")
        $wsMouv.Unprotect("erp_secure_pwd_2026")
        $lastMouv = $wsMouv.Cells($wsMouv.Rows.Count, 1).End(-4162).Row
        if ($lastMouv -gt 1) { $wsMouv.Range("A2:J$lastMouv").ClearContents() }

        $row = 2
        foreach ($item in $data.MOUVEMENTS) {
            $wsMouv.Cells($row, 1).Value = $item.N_MVT
            $wsMouv.Cells($row, 2).Value = $item.DATE
            $wsMouv.Cells($row, 3).Value = $item.CODE_ARTICLE
            $wsMouv.Cells($row, 4).Value = $item.TYPE_MVT
            $wsMouv.Cells($row, 5).Value = $item.QTE_ENTREE
            $wsMouv.Cells($row, 6).Value = $item.QTE_SORTIE
            $wsMouv.Cells($row, 7).Value = $item.PU
            $wsMouv.Cells($row, 8).Value = $item.VALEUR
            $wsMouv.Cells($row, 9).Value = $item.REF_DOC
            $wsMouv.Cells($row, 10).Value = $item.TIERS
            $row++
        }
        Write-Host "  Loaded MOUVEMENTS: $($data.MOUVEMENTS.Count) rows" -ForegroundColor Green

        $wb.Save()
        Write-Host "  Data loaded and saved" -ForegroundColor Green
    } finally {
        if ($null -ne $wb) { $wb.Close($false) }
        if ($null -ne $xl) { $xl.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null }
    }
}

switch ($Action.ToLower()) {
    "save"   { Save-Data }
    "load"   { Load-Data }
    default  { Write-Host "Usage: .\data-persist.ps1 [save|load]" -ForegroundColor Red }
}

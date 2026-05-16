param (
    [Parameter(Mandatory=$true)] [string]$Action,
    [Parameter()] [string]$Tag,
    [Parameter()] [string]$Observation,
    [Parameter()] [string]$Query,
    [Parameter()] [string]$Id
)

$MemFile = "C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.opencode\memory-store.json"

if ($Action -eq "capture") {
    $Data = Get-Content $MemFile | ConvertFrom-Json
    $NewId = $Data.observations.Count + 1
    $NewObs = [PSCustomObject]@{
        id = $NewId
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        tag = $Tag
        text = $Observation
    }
    $Data.observations += $NewObs
    $Data.metadata.total_observations = $Data.observations.Count
    $Data | ConvertTo-Json -Depth 10 | Set-Content $MemFile
    Write-Host "Captured Observation #$NewId" -ForegroundColor Green
}
elseif ($Action -eq "search") {
    $Data = Get-Content $MemFile | ConvertFrom-Json
    $Results = $Data.observations | Where-Object { $_.text -like "*$Query*" -or $_.tag -like "*$Query*" }
    if ($Results) {
        $Results | ForEach-Object { Write-Host "[$($_.id)] ($($_.tag)) $($_.text)" }
    } else {
        Write-Host "No matching memories found." -ForegroundColor Yellow
    }
}
elseif ($Action -eq "detail") {
    $Data = Get-Content $MemFile | ConvertFrom-Json
    $Obs = $Data.observations | Where-Object { $_.id -eq $Id }
    if ($Obs) {
        $Obs | ConvertTo-Json
    } else {
        Write-Host "Observation #$Id not found." -ForegroundColor Red
    }
}

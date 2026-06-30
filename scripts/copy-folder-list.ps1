param([string]$path)
try {
    $list = Get-ChildItem -Path $path | Select-Object -ExpandProperty Name
    $list | Set-Clipboard
} catch {
    Write-Error "Failed to copy folder list: $($_.Exception.Message)"
}

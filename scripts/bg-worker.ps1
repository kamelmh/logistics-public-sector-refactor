param(
    [string]$TaskId,
    [string]$TaskDir
)

$CommandFile = "$TaskDir\command.txt"
if (-not (Test-Path $CommandFile)) {
    @{status="error"; pid=$PID; error="command.txt not found at $CommandFile"; finished=(Get-Date -Format "o")} |
        ConvertTo-Json | Set-Content "$TaskDir\status.json"
    exit 1
}

$Command = Get-Content $CommandFile -Raw
try {
    $result = Invoke-Expression $Command 2>&1 | Out-String -Width 4096
    $exitCode = $LASTEXITCODE
    $output = $result.Substring(0, [Math]::Min($result.Length, 50000))
    @{status="completed"; pid=$PID; exitCode=$exitCode; finished=(Get-Date -Format "o")} |
        ConvertTo-Json | Set-Content "$TaskDir\status.json"
    $output | Set-Content "$TaskDir\result.txt"
} catch {
    @{status="error"; pid=$PID; error=$_.Exception.Message; finished=(Get-Date -Format "o")} |
        ConvertTo-Json | Set-Content "$TaskDir\status.json"
    $_.Exception.Message | Set-Content "$TaskDir\result.txt"
}

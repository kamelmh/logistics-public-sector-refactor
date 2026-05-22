# Delegates to vbe-auto/verify.ps1
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
& "$scriptDir\..\vbe-auto\verify.ps1" @PSBoundParameters
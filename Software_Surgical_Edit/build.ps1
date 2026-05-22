# Delegates to vbe-auto/build.ps1
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
& "$scriptDir\..\vbe-auto\build.ps1" @PSBoundParameters
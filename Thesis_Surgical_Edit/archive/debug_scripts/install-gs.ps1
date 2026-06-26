$url = 'https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10040/gs10040w64.exe'
$out = 'C:\Temp\gs10040w64.exe'
New-Item -ItemType Directory -Force -Path C:\Temp
Write-Host "Downloading Ghostscript..."
Invoke-WebRequest -Uri $url -OutFile $out
Write-Host "Installing..."
Start-Process -FilePath $out -ArgumentList '/S' -Wait
Write-Host "Done"
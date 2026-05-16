# SSD & Drive Health Tools

## Purpose
Check SSD/USB drive health, reliability, and prepare for workspace deployment.

## Commands
- `check drive` — detect and report all removable drives
- `check health` — check SSD SMART status via WMI
- `check speed` — quick read/write benchmark
- `setup ssd` — deploy workspace to SSD
- `setup usb` — mount and extract USB contents

## Drive Health Check
```powershell
# Check disk health via WMI
Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, Size, MediaType, Status

# Check logical disk performance
Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object DriveType -eq 3 | Select-Object DeviceID, Size, FreeSpace, VolumeName

# Check for pending errors
Get-CimInstance -ClassName Win32_DiskDrive | Where-Object Status -ne "OK" | Select-Object Model, Status
```

## SSD Benchmark (Quick)
```powershell
# Write test file
$testFile = "$env:TEMP\ssd_test.tmp"
$data = [byte[]]::new(100MB)  # 100MB test
[System.IO.File]::WriteAllBytes($testFile, $data)
$sw = [System.Diagnostics.Stopwatch]::StartNew()
[System.IO.File]::ReadAllBytes($testFile) | Out-Null
$sw.Stop()
Remove-Item $testFile -Force
"Read speed: $([Math]::Round(100/$sw.Elapsed.TotalSeconds, 0)) MB/s"
```

## Deployment to SSD
When SSD detected:
1. Create `{SSD}:\Academix\` directory
2. Deploy:
   - `VBA_Modules\` (source code)
   - `build.ps1` + `verify.ps1` (build tools)
   - `ERP_Academie_v13_Master.xlsm` (master template)
3. Run `build.ps1` on SSD path
4. Run `verify.ps1` to confirm
5. Set session.json `drive_config.ssd_expected` to SSD drive letter

# VBA PC Control Skill (MCP-Style)

## Overview
Model Context Protocol (MCP)-style PC control toolset for VBA. Provides shell execution, WMI system queries, Registry access, FileSystem operations, Windows API window management, process control, clipboard, keyboard simulation, and network tools — all from Excel VBA.

## Module
`mod_PCControl.bas` in `Software_Surgical_Edit/VBA_Modules/`

## Capabilities

### 1. Shell Execution
| Function | Description |
|----------|-------------|
| `Shell_RunCommand(cmd, show, wait)` | Execute shell command, return exit code |
| `Shell_CaptureOutput(cmd)` | Run command and capture stdout |
| `Shell_StartProcess(exe, args, dir)` | Launch process asynchronously |

### 2. Process Management
| Function | Description |
|----------|-------------|
| `Process_List()` | Get all processes (Name, PID, Memory) |
| `Process_Kill(name)` | Terminate process by name |
| `Process_GetInfo(name)` | Detailed process info (path, threads, CPU) |

### 3. WMI System Queries
| Function | Description |
|----------|-------------|
| `WMI_GetSystemInfo()` | OS, CPU, RAM, Disk info |
| `WMI_GetNetworkInfo()` | IP, MAC, gateway, DNS |
| `WMI_GetBatteryInfo()` | Battery charge/status |
| `WMI_GetServices()` | Running services list |

### 4. Window Management (WinAPI)
| Function | Description |
|----------|-------------|
| `Window_Find(title)` | Find window by title |
| `Window_BringToFront(hWnd)` | Activate and restore window |
| `Window_Hide/Show/Close(hWnd)` | Window control |
| `Window_EnumerateAll()` | List all visible windows |

### 5. Registry Access
| Function | Description |
|----------|-------------|
| `Registry_Read(key, value)` | Read registry value |
| `Registry_Write(key, value, data, type)` | Write registry value |
| `Registry_Delete(key, value)` | Delete registry value |
| `Registry_GetExcelVersion()` | Find installed Excel version |

### 6. FileSystem
| Function | Description |
|----------|-------------|
| `FS_FileExists/FolderExists(path)` | Path existence check |
| `FS_CopyFile/MoveFile/DeleteFile(s, d)` | File operations |
| `FS_FindFiles(folder, pattern)` | Search files recursively |
| `FS_GetFileSize(path)` | File size in bytes |

### 7. Environment & Clipboard
| Function | Description |
|----------|-------------|
| `Env_Get(name)` | Get environment variable |
| `Env_GetAll()` | Get all environment variables |
| `Clipboard_SetText/GetText(text)` | Clipboard operations |
| `Keyboard_SendKeys/TypeText(keys)` | Keyboard simulation |

### 8. Network
| Function | Description |
|----------|-------------|
| `Net_Ping(host)` | Ping test with result parsing |
| `Net_GetIPConfig()` | Full IP configuration |
| `Net_GetDNS()` | DNS server info |

## Entry Points (MAIN_MACROS.bas)
| Macro | Description |
|-------|-------------|
| `PcShowSystemInfo` | Display OS/CPU/RAM/Disk info |
| `PcShowDiagnostics` | Full system diagnostic report |
| `PcShowNetwork` | IP configuration |
| `PcShowWindows` | List all open windows |
| `PcRunCommand` | Interactive command execution |
| `PcListProcesses` | List running processes |
| `PcKillProcess` | Kill a process interactively |
| `PcShowEnv` | Show environment variables |
| `PcCheckExcelVersion` | Check installed Excel version |

## WMI Query Examples
```vb
Dim systemInfo As String
systemInfo = mod_PCControl.WMI_GetSystemInfo()
' Returns: OS name, version, architecture, RAM, CPU cores/threads, disk space
```

## Shell Execution (with output capture)
```vb
Dim output As String
output = mod_PCControl.Shell_CaptureOutput("systeminfo | findstr /i ""OS Name""")
```

## Data Safety
- All tools are **read-only by default** (registry, file system queries)
- Destructive operations (kill, delete, write) require explicit calls
- No system modifications are made without user intent

## Dependencies
- None — pure VBA + Windows API + WMI + COM (WScript.Shell, Scripting.FileSystemObject)
- Requires Windows (WMI, WinAPI, COM objects)
- Excel 2010+ compatible

## Verification
Run each `Pc*` macro from `Macros` menu or call via Immediate window:
```vb
?mod_PCControl.WMI_GetSystemInfo()
?mod_PCControl.Net_Ping("8.8.8.8")
?mod_PCControl.Process_List()
```

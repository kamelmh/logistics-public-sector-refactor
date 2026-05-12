# model-picker.ps1 — OpenCode Model Picker TUI
# Arrow-key grid selector with live Ollama status
# Usage: pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\model-picker.ps1
# Part of OpenCode.bat via: OpenCode picker

# ─── Helpers ──────────────────────────────────────────────────
function Find-OpenCodeExe {
    $root = Split-Path $PSScriptRoot -Parent
    $searches = @(
        Join-Path $root "opencode.exe"
        Join-Path $root "bin\opencode.exe"
        "$env:USERPROFILE\Desktop\opencode-windows-x64-baseline\opencode.exe"
    )
    foreach ($p in $searches) { if (Test-Path $p) { return $p } }
    $cmd = Get-Command "opencode.exe" -ErrorAction SilentlyContinue
    return if ($cmd) { $cmd.Source } else { $null }
}

function Get-OllamaStatus {
    try { $null = Invoke-RestMethod 'http://localhost:11434/api/tags' -TimeoutSec 2; return $true }
    catch { return $false }
}

function Get-OllamaModelNames {
    try {
        $r = Invoke-RestMethod 'http://localhost:11434/api/tags' -TimeoutSec 3 -ErrorAction Stop
        return $r.models.name
    } catch { return @() }
}

# ─── Model Registry ───────────────────────────────────────────
# Keep in sync with OpenCode.bat CLI_MODES
$models = @(
    [PSCustomObject]@{ Name="big-pickle (default)";  ModelId="opencode/big-pickle";                                 Provider="Built-in";  Ctx="—";    Speed="instant";   Group="Default"; Mode="cli";          IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Llama 3.3 70B";         ModelId="groq/llama-3.3-70b-versatile";                       Provider="Groq";      Ctx="32K";  Speed="~2s";       Group="Cloud";   Mode="llama";       IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Qwen3 32B (fast)";      ModelId="groq/qwen/qwen3-32b";                                Provider="Groq";      Ctx="32K";  Speed="~1s";       Group="Cloud";   Mode="groq";        IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Gemini 3 Flash";         ModelId="google/gemini-3-flash-preview";                      Provider="Google";    Ctx="1M";   Speed="~2s";       Group="Cloud";   Mode="gemini3";     IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Gemma 4 26B (256K)";     ModelId="google/gemma-4-26b-a4b-it";                         Provider="Google";    Ctx="256K"; Speed="~2s";       Group="Cloud";   Mode="gemma";       IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Gemma 4 31B IT";         ModelId="google/gemma-4-31b-it";                             Provider="Google";    Ctx="32K";  Speed="~2s";       Group="Cloud";   Mode="gemma-31b";   IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Ring 2.6 1T (Kimi)";     ModelId="openrouter/inclusionai/ring-2.6-1t:free";           Provider="OpenRouter"; Ctx="262K"; Speed="~3s";       Group="Cloud";   Mode="ring";        IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }
    [PSCustomObject]@{ Name="Nemotron 120B 1M";       ModelId="openrouter/nvidia/nemotron-3-super-120b-a12b:free"; Provider="OpenRouter"; Ctx="1M";   Speed="~3s";       Group="Cloud";   Mode="nemotron";    IsCloud=$true;  IsOllama=$false; IsPaid=$false; Pulled=$true }

    [PSCustomObject]@{ Name="Gemma 4 e2b (128K)";     ModelId="ollama/gemma4:e2b";                                 Provider="Ollama";    Ctx="128K"; Speed="~40-60s";  Group="Local";   Mode="gemma-local"; IsCloud=$false; IsOllama=$true;  IsPaid=$false; Pulled=$false }
    [PSCustomObject]@{ Name="Phi4-mini 3.8B";          ModelId="ollama/phi4-mini:3.8b-q4_K_M";                     Provider="Ollama";    Ctx="16K";  Speed="~25s";     Group="Local";   Mode="phi4";        IsCloud=$false; IsOllama=$true;  IsPaid=$false; Pulled=$false }
    [PSCustomObject]@{ Name="Qwen3 1.7B";              ModelId="ollama/qwen3:1.7b";                                Provider="Ollama";    Ctx="16K";  Speed="~40s";     Group="Local";   Mode="qwen3";       IsCloud=$false; IsOllama=$true;  IsPaid=$false; Pulled=$false }
    [PSCustomObject]@{ Name="Qwen2.5 Coder 7B";        ModelId="ollama/qwen2.5-coder:7b";                          Provider="Ollama";    Ctx="8K";   Speed="~30s";     Group="Local";   Mode="ollama";      IsCloud=$false; IsOllama=$true;  IsPaid=$false; Pulled=$false }
    [PSCustomObject]@{ Name="Qwen2.5 Coder 1.5B";      ModelId="ollama/qwen2.5-coder:1.5b";                        Provider="Ollama";    Ctx="4K";   Speed="~95s";     Group="Local";   Mode="cli";         IsCloud=$false; IsOllama=$true;  IsPaid=$false; Pulled=$false }

    [PSCustomObject]@{ Name="Claude 4 Sonnet";          ModelId="anthropic/claude-4-sonnet-20250514";                Provider="Anthropic"; Ctx="200K"; Speed="~3s";      Group="Paid";    Mode="cli";         IsCloud=$true;  IsOllama=$false; IsPaid=$true;  Pulled=$true }
    [PSCustomObject]@{ Name="GPT-4o";                   ModelId="openai/gpt-4o";                                    Provider="OpenAI";    Ctx="128K"; Speed="~2s";      Group="Paid";    Mode="cli";         IsCloud=$true;  IsOllama=$false; IsPaid=$true;  Pulled=$true }
)

# ─── Render ───────────────────────────────────────────────────
try { $W = [Math]::Max(60, $Host.UI.RawUI.WindowSize.Width) } catch { $W = 80 }

function Render {
    param($Sel)
    try { $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 0 } catch { }
    $idx = 0

    Write-Host "┌$('─' * ($W-2))┐" -ForegroundColor Cyan
    $title = "  OpenCode Model Picker — ↑↓ Enter=launch Esc=exit R=refresh  "
    Write-Host "│" -NoNewline -ForegroundColor Cyan
    Write-Host $title.PadRight($W-2) -NoNewline -ForegroundColor White
    Write-Host "│" -ForegroundColor Cyan

    if (-not $ocExe) {
        Write-Host "│" -NoNewline -ForegroundColor Cyan
        Write-Host "  [X] opencode.exe not found — check PATH or Desktop baseline".PadRight($W-4) -NoNewline -ForegroundColor Red
        Write-Host "  │" -ForegroundColor Cyan
    }

    Write-Host "├$('─' * ($W-2))┤" -ForegroundColor Cyan

    foreach ($group in $groups) {
        $gModels = $models | Where-Object Group -eq $group
        if (-not $gModels) { continue }

        Write-Host "│" -NoNewline -ForegroundColor Cyan
        Write-Host "  $group".PadRight($W-4) -NoNewline -ForegroundColor Magenta
        Write-Host "  │" -ForegroundColor Cyan

        foreach ($m in $gModels) {
            $isSel = ($idx -eq $Sel)

            # Build line content
            $avail = if ($m.Pulled) { "●" } else { "○" }
            $p = $m.Provider.PadRight(11).Substring(0, 11)
            $n = $m.Name.PadRight(24).Substring(0, 24)
            $c = $m.Ctx.PadRight(6).Substring(0, 6)
            $s = $m.Speed.PadRight(12).Substring(0, 12)
            $mark = if ($isSel) { ">" } else { " " }
            $line = " $mark $avail $p $n $c $s"

            Write-Host "│" -NoNewline -ForegroundColor Cyan
            if ($isSel) {
                Write-Host $line.PadRight($W-4) -NoNewline -ForegroundColor Black -BackgroundColor Cyan
            } else {
                Write-Host $line.PadRight($W-4) -NoNewline
            }
            Write-Host "  │" -ForegroundColor Cyan
            $idx++
        }
    }

    Write-Host "└$('─' * ($W-2))┘" -ForegroundColor Cyan
    Write-Host "Status: " -NoNewline -ForegroundColor DarkGray
    if ($ollamaOk) { Write-Host "Ollama running" -NoNewline -ForegroundColor Green }
    else { Write-Host "Ollama offline" -NoNewline -ForegroundColor Red }
    Write-Host " | " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($models.Count) models" -NoNewline -ForegroundColor DarkGray
    Write-Host " | " -NoNewline -ForegroundColor DarkGray
    Write-Host "big-pickle = default" -NoNewline -ForegroundColor DarkGray
    Write-Host "   " -NoNewline
}

# ─── Launch function ──────────────────────────────────────────
function Launch-Model {
    param($M, $Exe)
    $root = Split-Path $PSScriptRoot -Parent
    try { $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor; $Host.UI.RawUI.BackgroundColor = $Host.UI.RawUI.BackgroundColor } catch { }
    try { $Host.UI.RawUI.Clear() } catch { }

    Write-Host "Launching: $($M.Name)" -ForegroundColor Cyan
    Write-Host "  Model:   $($M.ModelId)" -ForegroundColor Gray
    Write-Host "  Mode:    $($M.Mode)" -ForegroundColor Gray
    Write-Host "  Project: $root" -ForegroundColor Gray
    Write-Host ""

    if ($M.Mode -eq "fcc") {
        # FCC proxy mode: set env vars, no --model flag
        Write-Host "Starting FCC proxy (background)..." -ForegroundColor Yellow
        $fccDir = "$env:USERPROFILE\.opencode\plugins\fcc-proxy"
        $fccPort = 8082
        $env:ANTHROPIC_BASE_URL = "http://localhost:$fccPort"
        $env:ANTHROPIC_AUTH_TOKEN = "freecc"
        & $Exe $root
    } else {
        & $Exe --model $M.ModelId $root
    }
}

# ─── Main Loop ────────────────────────────────────────────────
try {
    try { $Host.UI.RawUI.Clear() } catch { }
    Render -Sel $selected

    do {
        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        $total = $models.Count

        switch ($key.VirtualKeyCode) {
            38 {  # Up
                $selected = ($selected - 1 + $total) % $total
                Render -Sel $selected
            }
            40 {  # Down
                $selected = ($selected + 1) % $total
                Render -Sel $selected
            }
            13 {  # Enter
                $chosen = $models[$selected]
                if ($chosen.IsPaid -and -not $chosen.Pulled) {
                    Write-Host "  [X] $($chosen.Name) needs billing — not available." -ForegroundColor Yellow
                    Start-Sleep 1
                    Render -Sel $selected
                } elseif (-not $chosen.Pulled) {
                    Write-Host "  [X] $($chosen.Name) not installed. Pull with: ollama pull $($chosen.ModelId -replace '^ollama/','')" -ForegroundColor Yellow
                    Start-Sleep 2
                    Render -Sel $selected
                } else {
                    Launch-Model $chosen $ocExe
                    break
                }
            }
            27 {  # Escape
                Write-Host ""; break
            }
            82 {  # R
                $ollamaOk = Get-OllamaStatus
                $installedOllama = if ($ollamaOk) { Get-OllamaModelNames } else { @() }
                $installedNames = $installedOllama | ForEach-Object { $_ -replace ':.*', '' }
                foreach ($m in $models) {
                    if ($m.IsOllama) {
                        $sn = $m.ModelId -replace '^ollama/', '' -replace ':.*', ''
                        $m.Pulled = $ollamaOk -and ($installedNames -contains $sn)
                    }
                }
                Render -Sel $selected
            }
        }
    } while ($key.VirtualKeyCode -ne 13 -and $key.VirtualKeyCode -ne 27)

} finally {
    try { $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor; $Host.UI.RawUI.BackgroundColor = $Host.UI.RawUI.BackgroundColor } catch { }
}

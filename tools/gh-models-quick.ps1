<#
.SYNOPSIS
    Quick-access menu for GitHub Models Free Tier.
    Run this for an interactive menu in any terminal (desktop, SSH from phone, etc.)
#>

function Show-Menu {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     GitHub Models Free — On the Go      ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Ask a question (one-shot)" -ForegroundColor White
    Write-Host "  2. Interactive chat" -ForegroundColor White
    Write-Host "  3. List available models" -ForegroundColor White
    Write-Host "  4. Check environment status" -ForegroundColor White
    Write-Host "  5. Lite mode (minimal, good for SSH)" -ForegroundColor White
    Write-Host "  0. Exit" -ForegroundColor White
    Write-Host ""
}

do {
    Show-Menu
    $choice = Read-Host "Choice"
    switch ($choice) {
        '1' {
            $q = Read-Host "`nYour question"
            if ($q) {
                .\gh-models.ps1 chat -Prompt $q
            }
            Write-Host "`nPress Enter to continue..." -NoNewline; Read-Host
        }
        '2' {
            .\gh-models.ps1 chat
        }
        '3' {
            .\gh-models.ps1 models
            Write-Host "`nPress Enter to continue..." -NoNewline; Read-Host
        }
        '4' {
            .\gh-models.ps1 env
            Write-Host "`nPress Enter to continue..." -NoNewline; Read-Host
        }
        '5' {
            $q = Read-Host "`nYour question"
            if ($q) {
                .\gh-models-lite.ps1 -p $q
            }
            Write-Host "`nPress Enter to continue..." -NoNewline; Read-Host
        }
    }
} while ($choice -ne '0')

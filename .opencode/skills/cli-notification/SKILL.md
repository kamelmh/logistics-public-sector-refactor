# CLI Notification Skill

Send pipeline results and alerts to Telegram, Discord, or Slack from PowerShell build scripts.

## Purpose
Enable real-time notifications for ERP/Thesis pipeline results (build, verify, audit, test) without requiring manual checking.

## Configuration

### Environment Variables
Set in `$env:` or persist in `$PROFILE`:

```powershell
# Telegram (create bot via @BotFather, get chat_id via @userinfobot)
$env:NOTIFY_TELEGRAM_BOT_TOKEN = "123456:ABC-DEF..."
$env:NOTIFY_TELEGRAM_CHAT_ID = "987654321"

# Discord (create webhook in channel settings)
$env:NOTIFY_DISCORD_WEBHOOK = "https://discord.com/api/webhooks/..."

# Slack (create incoming webhook in app settings)
$env:NOTIFY_SLACK_WEBHOOK = "https://hooks.slack.com/services/..."
```

### Priority Order
If multiple are configured, notifications send to all. Set `$env:NOTIFY_PROVIDER = "telegram"` to use only one.

## Usage

### In PowerShell Scripts
```powershell
# Import the notification function
. "$PSScriptRoot\..\skills\cli-notification\notify.ps1"

# Send notification
Send-Notify -Title "ERP Build" -Message "35 modules compiled, 811.3 KB" -Status "success"
Send-Notify -Title "Thesis Build" -Message "DOCX 123 KB, PDF 1,075 KB" -Status "success"
Send-Notify -Title "Verify Failed" -Message "3 checks failed" -Status "error"
Send-Notify -Title "Audit Warning" -Message "2 warnings found" -Status "warning"
```

### Status Types
| Status | Color | Emoji | Use Case |
|--------|-------|-------|----------|
| `success` | Green | ✅ | Pipeline passed |
| `error` | Red | ❌ | Pipeline failed |
| `warning` | Yellow | ⚠️ | Warnings found |
| `info` | Blue | ℹ️ | Informational |

## Pipeline Integration

### build.ps1
```powershell
# At end of build script
. "$PSScriptRoot\..\skills\cli-notification\notify.ps1"
if ($allPassed) {
    Send-Notify -Title "ERP Build" -Message "$modules modules, $size KB" -Status "success"
} else {
    Send-Notify -Title "ERP Build" -Message "Compilation failed" -Status "error"
}
```

### verify.ps1
```powershell
Send-Notify -Title "Verify" -Message "$passed/$total PASS, $failed FAILED" -Status $(if ($failed -eq 0) { "success" } else { "error" })
```

### build-thesis.ps1
```powershell
Send-Notify -Title "Thesis Build" -Message "DOCX $docx KB, PDF $pdf KB, $passed/$total PASS" -Status $(if ($failed -eq 0) { "success" } else { "error" })
```

## notify.ps1 Implementation

```powershell
function Send-Notify {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("success","error","warning","info")]
        [string]$Status = "info"
    )

    $colors = @{ success = "00ff00"; error = "ff0000"; warning = "ffff00"; info = "0088ff" }
    $emojis = @{ success = "✅"; error = "❌"; warning = "⚠️"; info = "ℹ️" }
    $emoji = $emojis[$Status]
    $color = $colors[$Status]
    $text = "$emoji **$Title**`n$Message`n_$(Get-Date -Format 'yyyy-MM-dd HH:mm')_"

    # Telegram
    if ($env:NOTIFY_TELEGRAM_BOT_TOKEN -and $env:NOTIFY_TELEGRAM_CHAT_ID) {
        $uri = "https://api.telegram.org/bot$($env:NOTIFY_TELEGRAM_BOT_TOKEN)/sendMessage"
        $body = @{ chat_id = $env:NOTIFY_TELEGRAM_CHAT_ID; text = $text; parse_mode = "Markdown" }
        try { Invoke-RestMethod -Uri $uri -Method Post -Body $body -ErrorAction Stop | Out-Null } catch { Write-Warning "Telegram notify failed: $_" }
    }

    # Discord
    if ($env:NOTIFY_DISCORD_WEBHOOK) {
        $payload = @{ content = $text; embeds = @(@{ color = [Convert]::ToInt32($color, 16); title = $Title; description = $Message }) } | ConvertTo-Json
        try { Invoke-RestMethod -Uri $env:NOTIFY_DISCORD_WEBHOOK -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop | Out-Null } catch { Write-Warning "Discord notify failed: $_" }
    }

    # Slack
    if ($env:NOTIFY_SLACK_WEBHOOK) {
        $payload = @{ text = $text } | ConvertTo-Json
        try { Invoke-RestMethod -Uri $env:NOTIFY_SLACK_WEBHOOK -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop | Out-Null } catch { Write-Warning "Slack notify failed: $_" }
    }

    if (-not ($env:NOTIFY_TELEGRAM_BOT_TOKEN -or $env:NOTIFY_DISCORD_WEBHOOK -or $env:NOTIFY_SLACK_WEBHOOK)) {
        Write-Host "[$Status] $Title: $Message" -ForegroundColor $(switch ($Status) { success { "Green" }; error { "Red" }; warning { "Yellow" }; default { "Blue" } })
    }
}
```

## Quick Test
```powershell
. "$PSScriptRoot\notify.ps1"
Send-Notify -Title "Test" -Message "Notification system working" -Status "success"
```

## Security Notes
- Never commit webhook URLs or bot tokens to git
- Add to `.gitignore`: `*.env`, `notify-config.json`
- Use Windows Credential Manager for production: `cmdkey /add:NotifyToken /user:token /pass:xxx`
- Tokens are read from environment only, never hardcoded

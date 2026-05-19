# CLI Notification Function for Academix v13.2 Pipelines
# Usage: . "$PSScriptRoot\notify.ps1" then Send-Notify -Title "X" -Message "Y" -Status "success"

function Send-Notify {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,

        [Parameter(Mandatory=$true)]
        [string]$Message,

        [ValidateSet("success","error","warning","info")]
        [string]$Status = "info"
    )

    $colors = @{ success = "0x00ff00"; error = "0xff0000"; warning = "0xffff00"; info = "0x0088ff" }
    $emojis = @{ success = "✅"; error = "❌"; warning = "⚠️"; info = "ℹ️" }
    $fgColors = @{ success = "Green"; error = "Red"; warning = "Yellow"; info = "Blue" }

    $emoji = $emojis[$Status]
    $color = $colors[$Status]
    $fgColor = $fgColors[$Status]
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $text = "$emoji **$Title**`n$Message`n_$timestamp_"

    $sent = $false

    # Telegram
    if ($env:NOTIFY_TELEGRAM_BOT_TOKEN -and $env:NOTIFY_TELEGRAM_CHAT_ID) {
        $uri = "https://api.telegram.org/bot$($env:NOTIFY_TELEGRAM_BOT_TOKEN)/sendMessage"
        $body = @{
            chat_id = $env:NOTIFY_TELEGRAM_CHAT_ID
            text = $text
            parse_mode = "Markdown"
        }
        try {
            Invoke-RestMethod -Uri $uri -Method Post -Body $body -ErrorAction Stop | Out-Null
            $sent = $true
        } catch {
            Write-Warning "Telegram notification failed: $_"
        }
    }

    # Discord
    if ($env:NOTIFY_DISCORD_WEBHOOK) {
        $embedColor = [Convert]::ToInt64($color.Replace("0x",""), 16)
        $payload = @{
            content = "$emoji **$Title**"
            embeds = @(
                @{
                    color = $embedColor
                    description = "$Message`n`n_$timestamp_"
                }
            )
        } | ConvertTo-Json -Depth 3
        try {
            Invoke-RestMethod -Uri $env:NOTIFY_DISCORD_WEBHOOK -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop | Out-Null
            $sent = $true
        } catch {
            Write-Warning "Discord notification failed: $_"
        }
    }

    # Slack
    if ($env:NOTIFY_SLACK_WEBHOOK) {
        $payload = @{
            text = $text
        } | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri $env:NOTIFY_SLACK_WEBHOOK -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop | Out-Null
            $sent = $true
        } catch {
            Write-Warning "Slack notification failed: $_"
        }
    }

    # Fallback: console output if no provider configured
    if (-not $sent) {
        Write-Host "[$($Status.ToUpper())] $Title : $Message" -ForegroundColor $fgColor
    }
}

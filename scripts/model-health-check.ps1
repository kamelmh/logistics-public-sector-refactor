param(
    [ValidateSet("env","connectivity","sonnet","all")]
    [string]$Mode = "all"
)

function Test-EnvVars {
    $requiredKeys = @("GEMINI_API_KEY", "OPENAI_API_KEY", "ANTHROPIC_API_KEY")
    $allSet = $true
    foreach ($key in $requiredKeys) {
        $val = [Environment]::GetEnvironmentVariable($key, "User")
        if ([string]::IsNullOrEmpty($val)) {
            $val = [Environment]::GetEnvironmentVariable($key, "Process")
        }
        if ([string]::IsNullOrEmpty($val)) {
            Write-Host "FAIL: $key is not set" -ForegroundColor Red
            $allSet = $false
        } else {
            Write-Host "PASS: $key is set" -ForegroundColor Green
        }
    }
    return $allSet
}

function Test-Connectivity {
    $providers = @(
        @{ Name = "Google AI"; Url = "https://generativelanguage.googleapis.com/v1/models"; KeyVar = "GEMINI_API_KEY" },
        @{ Name = "OpenAI";    Url = "https://api.openai.com/v1/models";               KeyVar = "OPENAI_API_KEY" },
        @{ Name = "Anthropic"; Url = "https://api.anthropic.com/v1/messages";           KeyVar = "ANTHROPIC_API_KEY" }
    )
    $allOk = $true
    foreach ($p in $providers) {
        $key = [Environment]::GetEnvironmentVariable($p.KeyVar, "User")
        if ([string]::IsNullOrEmpty($key)) {
            $key = [Environment]::GetEnvironmentVariable($p.KeyVar, "Process")
        }
        if ([string]::IsNullOrEmpty($key)) { Write-Host "SKIP: $($p.Name) (no key set)" -ForegroundColor Yellow; continue }
        try {
            $response = Invoke-RestMethod -Uri $p.Url -Headers @{ "Authorization" = "Bearer $key" } -TimeoutSec 5
            Write-Host "PASS: $($p.Name) reachable" -ForegroundColor Green
        } catch {
            Write-Host "FAIL: $($p.Name) not reachable ($($_.Exception.Message))" -ForegroundColor Red
            $allOk = $false
        }
    }
    return $allOk
}

function Test-ClaudeCodeBackend {
    # 0. Binary existence checks
    if ($null -eq (Get-Command "opencode.exe" -ErrorAction SilentlyContinue)) {
        Write-Host "FAIL: opencode.exe not found on PATH" -ForegroundColor Red
        return $false
    }
    if ($null -eq (Get-Command "omc.exe" -ErrorAction SilentlyContinue)) {
        Write-Host "FAIL: omc.exe not found on PATH" -ForegroundColor Red
        return $false
    }

    # 1. Plugin presence
    $pluginOut = & "opencode.exe" plugins list 2>&1
    if ($pluginOut -match "everything-claude-code") {
        Write-Host "PASS: Plugin loaded" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Plugin not found" -ForegroundColor Red
        return $false
    }

    # 2. Model availability
    $modelOut = & "omc.exe" model list 2>&1
    if ($modelOut -match "claude-code-sonnet") {
        Write-Host "PASS: Sonnet model available" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Sonnet model not in list" -ForegroundColor Red
        return $false
    }

    # 3. E2E test query
    try {
        $answer = & "omc.exe" ask claude-code-sonnet "reply with the word READY" 2>&1
        if ($answer -match "READY") {
            Write-Host "PASS: Claude Code backend responds correctly" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL: test query returned unexpected: $answer" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "FAIL: test query threw: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

$exitCode = 0

if ($Mode -in @("all","env")) {
    if (-not (Test-EnvVars)) { $exitCode = 1 }
}
if ($Mode -in @("all","connectivity")) {
    if (-not (Test-Connectivity)) { $exitCode = 1 }
}
if ($Mode -in @("all","sonnet")) {
    if (-not (Test-ClaudeCodeBackend)) { $exitCode = 1 }
}

exit $exitCode

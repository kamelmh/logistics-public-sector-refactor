# Model Router — Route tasks to best free model
# Usage: .\scripts\model-router.ps1 "task description"

param(
    [Parameter(Mandatory=$true)]
    [string]$Task
)

# Task-to-model mapping based on capability
$TaskModels = @{
    # Code generation — need good coding model
    "code"      = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "vba"       = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "python"    = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "build"     = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    
    # Analysis — need reasoning capability
    "analyze"   = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "review"    = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "audit"     = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    "debug"     = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
    
    # Simple tasks — fast model is enough
    "search"    = "fcc/groq/llama-3.1-8b-instant"
    "read"      = "fcc/groq/llama-3.1-8b-instant"
    "list"      = "fcc/groq/llama-3.1-8b-instant"
    "status"    = "fcc/groq/llama-3.1-8b-instant"
    
    # Writing — need good language model
    "write"     = "fcc/open_router/openrouter/free"
    "document"  = "fcc/open_router/openrouter/free"
    "explain"   = "fcc/open_router/openrouter/free"
    
    # Local — no limits, offline
    "local"     = "ollama/phi4-mini:latest"
    "offline"   = "ollama/phi4-mini:latest"
}

# Detect task type from description
$TaskLower = $Task.ToLower()
$SelectedModel = $null

foreach ($key in $TaskModels.Keys) {
    if ($TaskLower -match $key) {
        $SelectedModel = $TaskModels[$key]
        break
    }
}

# Default to NVIDIA NIM if no match
if (-not $SelectedModel) {
    $SelectedModel = "fcc/nvidia_nim/nvidia/nemotron-3-super-120b-a12b"
}

Write-Host "Task: $Task" -ForegroundColor Cyan
Write-Host "Model: $SelectedModel" -ForegroundColor Green

# Launch OpenCode with selected model
opencode -m $SelectedModel

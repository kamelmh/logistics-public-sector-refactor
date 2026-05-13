# FreeLLM Gateway Setup — Provider Key Registration

FreeLLM is running on `localhost:3000` with **27 models across 6 active providers**:

| Provider | API Key | Status | Models Unlocked |
|----------|---------|--------|-----------------|
| **Groq** | ✅ Active | ~30 req/min | Llama 3.3 70B, Qwen3 32B, Llama 4 Scout, Llama 3.1 8B |
| **Gemini** | ✅ Active | ~15 req/min | Gemini 2.5 Flash, Gemini 2.5 Pro |
| **Cerebras** | ✅ Active | ~30 req/min | GPT-OSS 120B, Qwen3 235B, Llama 3.1 8B |
| **Cloudflare** | ✅ Active | ~20 req/min | Llama 3.3 70B, DeepSeek R1, Qwen2.5 Coder 32B, Mistral Small |
| **GitHub Models** | ✅ Active | ~15 req/min | GPT-4o-mini, Phi-4, Llama 3.3 70B, Command-R+, Mistral Large |
| **Ollama** | ✅ Active | Unlimited | phi4-mini, qwen3 (local CPU) |

### Skipped / Unavailable
| Provider | Reason |
|----------|--------|
| **NVIDIA NIM** | ❌ SMS verification blocked |
| **Mistral** | ❌ No API key found |

**Completions.me** is configured as a **direct provider** in `opencode.json` (not via FreeLLM):
- `completions/claude-opus-4.6`, `completions/gpt-5.2`, `completions/gemini-2.5-pro` etc.
- Base URL: `https://completions.me/api/v1`
- Unlimited requests, data logged

## Usage

| Command | Model | Purpose |
|---------|-------|---------|
| `OpenCode` (default) | `groq/llama-3.3-70b-versatile` | Primary daily driver |
| `OpenCode groq` | `groq/qwen/qwen3-32b` | Fast explore/debug |
| `OpenCode gemini` | `google/gemini-2.5-flash` | 1M context |
| Via FreeLLM: `free-fast` | Auto (Groq→Cerebras→Gemini→Cloudflare) | Lowest latency |
| Via FreeLLM: `free-smart` | Auto (Gemini→Cloudflare→Groq→Cerebras) | Best reasoning |
| Via FreeLLM: `free` | Auto (all 6 providers) | Max uptime |
| Via FreeLLM: `cerebras/qwen-3-235b-a22b-instruct-2507` | Cerebras Qwen3 235B | Heavy code gen |
| Via Completions: `claude-opus-4.6` | Claude Opus 4.6 | Free unlimited Claude |

## Troubleshooting

```powershell
# Check gateway status
.\scripts\freellm-launcher.ps1 status

# Restart after .env changes
.\scripts\freellm-launcher.ps1 restart

# View logs
Get-Content "$env:USERPROFILE\.opencode\plugins\freellm\freellm.log" -Tail 10
```

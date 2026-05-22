# Model Stack Configuration — All Providers

## FreeLLM Gateway (6 providers, 27 models, auto-failover)
Runs on `localhost:3000`:

| Provider | Status | Rate | Models Unlocked |
|----------|--------|------|-----------------|
| **Groq** | ✅ | ~30 req/min | Llama 3.3 70B, Qwen3 32B, Llama 4 Scout, Llama 3.1 8B |
| **Gemini** | ✅ | ~15 req/min | Gemini 2.5 Flash, Gemini 2.5 Pro |
| **Cerebras** | ✅ | ~30 req/min | GPT-OSS 120B, Qwen3 235B, Llama 3.1 8B |
| **Cloudflare** | ✅ | ~20 req/min | Llama 3.3 70B, DeepSeek R1, Qwen2.5 Coder 32B, Mistral Small |
| **GitHub Models** | ✅ | ~15 req/min | GPT-4o-mini, Phi-4, Llama 3.3 70B, Command-R+, Mistral Large |
| **Ollama** | ✅ | Unlimited | phi4-mini, qwen3 (local CPU) |

Skipped: NVIDIA NIM (SMS blocked), Mistral (no API key found)

## Direct Providers (configured in opencode.json)

### Completions.me (26 models, free, unlimited, data logged)
Base URL: `https://completions.me/api/v1`
```
claude-opus-4.6, claude-sonnet-4.6, claude-sonnet-4.5, claude-haiku-4.5
claude-sonnet-4, claude-opus-4.5, claude-opus-4.6-fast
gpt-5.4, gpt-5.2, gpt-5.3-codex, gpt-4.1
gemini-3.1-pro-preview, gemini-3-flash-preview, gemini-2.5-pro
grok-code-fast-1
```

### DeepSeek API (MIT license, 1M context, direct key)
Base URL: `https://api.deepseek.com` (native)
| Model | Context | Price (promo) | Price (list) | SWE-Bench |
|-------|---------|--------------|-------------|-----------|
| `deepseek-v4-pro` | 1M | $0.435/$0.87 | $1.74/$3.48 | 80.6% |
| `deepseek-v4-flash` | 1M | $0.14/$0.28 | — | 79.0% |

Promo pricing until 2026-05-31 15:59 UTC (75% off)

### OpenRouter (300+ models via single key)
| Model | Context | Price | Notes |
|-------|---------|-------|-------|
| `moonshotai/kimi-k2.6` | 262K | $0.74/$3.50/M | Best SWE-Bench Pro (58.6%) |
| `openrouter/quasar-alpha` | 1M | FREE | Data logged, no SLA, rate-limited |

### Native Providers (Groq, Google, Anthropic, OpenAI)
All configured with API keys in `opencode.json`

### Ollama (local, zero cost, offline)
`phi4-mini:3.8b`, `qwen3:1.7b`, `gemma4:e2b`

## Model Fallback Chains (plugin: @smart-coders-hq/opencode-model-fallback)
Config: `.opencode/model-fallback.json`

| Agent | Primary | Chain |
|-------|---------|-------|
| `*` (default) | Completions Opus 4.6 | → DeepSeek V4-Pro → Kimi K2.6 → Quasar Alpha → FreeLLM Gemini |
| `explore` | DeepSeek V4-Flash | → FreeLLM fast → Groq Llama 3.3 → Ollama phi4 |
| `build` | Completions Opus 4.6 | → Kimi K2.6 → DeepSeek V4-Pro → Quasar Alpha |
| `thesis` | DeepSeek V4-Pro | → Quasar Alpha → Completions Gemini 3.1 Pro → FreeLLM Gemini |
| `debug` | DeepSeek V4-Flash | → Completions Haiku → FreeLLM → Ollama phi4 |

## Quick-Start Commands

| Command | Model | Use Case |
|---------|-------|----------|
| `OpenCode` | big-pickle (default) | Daily driver |
| `OpenCode groq` | Qwen3 32B | Fast explore/debug |
| `OpenCode deepseek` | DeepSeek V4-Pro | 1M ctx, MIT, $0.87/M |
| `OpenCode deepseek-flash` | DeepSeek V4-Flash | 1M ctx, $0.28/M, fast |
| `OpenCode kimi` | Kimi K2.6 | Agentic coding, 262K ctx |
| `OpenCode quasar` | Quasar Alpha | Free 1M ctx experimentation |
| `OpenCode completions` | Claude Opus 4.6 | Free unlimited |
| `OpenCode gemini` | Gemini 2.5 Flash | 1M ctx via Google |
| `OpenCode llama` | Llama 3.3 70B | VBA + prose |
| `OpenCode phi4` | phi4-mini | Offline CPU coding |

## Key Discovery
Completions.me `/v1/models` endpoint returned 26 models (probed 2026-05-13):
- Anthropic: claude-opus-4.6, claude-opus-4.6-fast, claude-opus-4.5, claude-sonnet-4.6, claude-sonnet-4.5, claude-sonnet-4, claude-haiku-4.5
- OpenAI: gpt-5.4, gpt-5.3-codex, gpt-5.2-codex, gpt-5.1-codex, gpt-5.1-codex-max, gpt-5.1-codex-mini, gpt-5.2, gpt-5.1, gpt-5-mini, gpt-4o, gpt-4.1, gpt-4o-mini
- Google: gemini-3.1-pro-preview, gemini-3-pro-preview, gemini-3-flash-preview, gemini-2.5-pro
- xAI: grok-code-fast-1
- Microsoft: oswe-vscode-prime, oswe-vscode-secondary

## Fallback Plugin
Package: `@smart-coders-hq/opencode-model-fallback` v1.3.4
Config: `.opencode/model-fallback.json` (project-level) or `~/.config/opencode/model-fallback.json` (global)
Features: per-agent chains, preemptive redirect, health tracking, cooldown, `/fallback-status` command

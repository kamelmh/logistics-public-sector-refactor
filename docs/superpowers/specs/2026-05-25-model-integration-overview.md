# Model‑Integration and Maintenance Overview – Academix v13.2
**Date:** 2026‑05‑25

## 1. Model‑Strength Rating (0–100)

| Model | Typical use case | Strength | Why |
|-------|-----------------|----------|-----|
| GPT‑OSS 120B (Cerebras) | Heavy reasoning, audits, large‑context analysis | **92** | 120 B params, 32 K ctx, strong chain‑of‑thought, stable on free‑router. |
| Gemini 2.5 Flash (Google) | Quick prose, short reasoning, UI‑text generation | **88** | 1 M ctx, low latency, good coding, less raw depth than 120 B. |
| DeepSeek V4 Flash (CrossFlow) | Ask‑style retrieval, Triage | **81** | Cheap/free through CrossFlow, limited context (~32 K). |
| Gemma 4 26B (Google) | Lightweight scripting, quick edits | **73** | Fast, decent for simple code, limited reasoning depth. |
| Phi‑4 mini 3.8B (Ollama) | Offline fallback, CPU‑only tasks | **65** | Works offline, limited reasoning and context. |

> **Interpretation:** ≥ 85 = core work; 70–84 = quick assistance; < 70 = fallback only.

## 2. Model‑Maintenance Workflow

1. **Health‑check pipeline** – `OpenCode autochec` verifies API key validity, response latency, token‑quota health.  
2. **Version upgrade procedure** – Update the `SET "MODEL=…"` variable in `OpenCode.bat`, then run `OpenCode autochec` to confirm connectivity.  
3. **Artifact cleanup** – `OpenCode autoclean` removes logs and verification artifacts older than 30 days.  
4. **CI/CD integration** – A scheduled GitHub Actions job can run `autochec` and fail if health degrades.  
5. **Rollback** – Because model‑selection variables live in `OpenCode.bat`, revert the commit that changed them.

## 3. OpenCode Launchers & Shortcuts

| Launcher | Model / Provider | Purpose | Quick‑start command |
|----------|-----------------|---------|---------------------|
| `OpenCode` (default) | GPT‑OSS 120B (free‑router) | General development, big‑pickle context | `OpenCode` |
| `OpenCode gemini` | Gemini 2.5 Flash | Fast prose, 1 M ctx | `OpenCode gemini` |
| `OpenCode og` | Qwen 3 32B (Groq) | Fast explore/debug | `OpenCode og` |
| `OpenCode on` | Nemotron 120B (OpenRouter) | 1 M ctx, free | `OpenCode on` |
| `OpenCode picker` | Interactive model picker (TUI) | Switch models on‑the‑fly | `OpenCode picker` |
| `OpenCode <mode> <name>` | Any mode + session name | Multi‑session isolation | `OpenCode gemini thesis` |

**Key environment variables (from `OpenCode.bat`):**  
- `NEMOTRON_MODEL`, `GEMINI_MODEL`, `DEEPSEEK_FLASH_MODEL`, `OLLAMA_MODEL` – used to select the underlying provider.  
- `MEMORY_DIR` – path to session logs and checkpoints.  
- `CROSSFLOW_DIR` – location of the handoff file for multi‑window sync.

**Recommended quick‑start:**  
```powershell
OpenCode <preferred‑model> <session‑name>   # e.g., OpenCode gemini thesis
# Skills and context are loaded automatically via the using‑superpowers rule.
```

## 4. Verifying the Claude‑Code Backend

1. **Plugin presence** – `OpenCode plugins list | findstr /i "claude"` should return `everything-claude-code`.  
2. **Sonnet model availability** – `omc model list | findstr /i "sonnet"` returns `claude-code-sonnet`.  
3. **End‑to‑end test** – `/ask claude-code-sonnet "Return the word 'ready' in uppercase."` responds `READY`.  
4. **Health checklist each session** – verify key rotation, API key `$env:ANTHROPIC_API_KEY` (or other env var) is set and non‑empty.  
5. **Troubleshooting** – check firewall, plugin directory `.opencode/plugins/everything-claude-code/config.json`, and the provider model in `opencode.json`.

**Claude‑code backend vs. Claude models:**  
The Claude‑Code backend is a *virtual meta‑handler* that uses the **Sonnet** (or another) model under the hood. "Claude‑Code" is not a model itself; it is a tool‑augmented agent layer that can route to Sonnet, Opus, Haiku, or any provider you configure. OpenCode loads this layer as a plugin, so you get function‑calling, skill injection, and tool execution regardless of the underlying model. The AI backend is fully loaded when you see the Sonnet provider in `omc model list` **and** a test query produces a successful answer.

## Summary

| Topic | Key take‑away |
|-------|---------------|
| **Model strength** | GPT‑OSS 120B (92) and Gemini 2.5 Flash (88) are the top‑tier drivers for project work. |
| **Maintenance** | Health‑check via `autochec`, version upgrades via `OpenCode.bat` edits, rollback by reverting commits. |
| **Launchers & shortcuts** | One‑letter aliases, TUI model picker, session‑named isolation – all managed through `OpenCode.bat`. |
| **Claude‑Code backend** | Verify plugin is loaded (`everything-claude-code`), Sonnet model appears in `omc model list`, and a test query passes. |

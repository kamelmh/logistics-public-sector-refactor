# AGENT BOOTSTRAP — Auto-load Protocol

## On Every Session Start
1. Read `.opencode/bootstrap/SKILL_INDEX.md` (70 skills reference)
2. Read `Software_Surgical_Edit/erp-project-context.xml` (project context)
3. Read `Software_Surgical_Edit/erp-agent-handoff.xml` (session state)
4. Call `skill` tool to load agent-specific skills (table below)
5. Begin work

## Agent Skill Mappings

| Agent | Model | Skills to Load | Context Files |
|-------|-------|---------------|---------------|
| `build` | Groq Llama 3.3 | vba-build, vba-debug, vba-excel-sync, naming-cheatsheet | project-context.xml, agent-handoff.xml |
| `plan` | Groq Llama 3.3 | plan, planning-and-task-breakdown, idea-refine | project-context.xml |
| `explore` | Groq Qwen 32B | (read-only — no skills needed) | project-context.xml |
| `debug` | Groq Qwen 32B | vba-debug, vba-build | handoffN.txt, project-context.xml |
| `audit` | Groq Qwen 32B | verify | project-context.xml |
| `test` | Groq Qwen 32B | project, verify | agent-handoff.xml |
| `or-free` | FreeLLM auto-route | vba-build, naming-cheatsheet, humanizer | project-context.xml, AGENTS.md |
| `or-coder` | FreeLLM Cerebras Qwen3 235B | vba-build, naming-cheatsheet | project-context.xml |
| `or-nemotron` | FreeLLM NVIDIA NIM | SKIPPED (SMS) | — |
| `completions` | Completions.me Claude Opus 4.6 | vba-build, naming-cheatsheet, humanizer | project-context.xml (free unlimited) |
| `gemini-flash` | Gemini 2.5 Flash | vba-build, external-context, humanizer | project-context.xml (large context) |
| `gemma-4` | Gemma 4 26B | vba-build, naming-cheatsheet | project-context.xml |

## Model Routing — Free Tier Alternatives

| Reference Model | Our Free Alternative | Provider | Status |
|----------------|---------------------|----------|--------|
| Opus-level | Cerebras Qwen3 235B | FreeLLM (Cerebras) | ✅ Active, ~1s |
| Opus-level | Completions Claude Opus 4.6 | Completions.me | ✅ Unlimited, free |
| Sonnet-level | Llama 3.3 70B | Groq | ✅ Fast (~2s) |
| Sonnet-level | GPT-OSS 120B | FreeLLM (Cerebras) | ✅ Active |
| Haiku-level | Qwen3 32B | Groq | ✅ Fast (~1s) |
| — | Cloudflare Llama 3.3 70B | FreeLLM (Cloudflare) | ✅ Active |
| — | Gemini 2.5 Flash | Google (free) | ✅ 1M ctx |
| — | GPT-4o-mini | FreeLLM (GitHub Models) | ✅ Active |

## Self-Hosted Mode (Ollama-Only)
For offline use, `opencode.json` has `ollama-local` provider:
- `ollama/qwen2.5-coder:1.5b` — ~95s response, 0.58 t/s on CPU
- `ollama/qwen2.5-coder:7b` — >300s response (unusable on CPU)

Switch to local: `opencode --model ollama/qwen2.5-coder:1.5b`

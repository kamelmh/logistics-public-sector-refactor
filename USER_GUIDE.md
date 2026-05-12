# Academix v13.2 — Simplified User Guide

> For Mahi Kamel Abdelghani | Direction de l'Education, El Bayadh

---

## 1. Starting Your Work (Every Day)

You have **one launcher**. Double-click this desktop shortcut:

```
📌 Desktop → OpenCode.lnk
```

This opens the CLI. The default model is `opencode/big-pickle`.

**To choose a different model**, use Windows Terminal (or CMD):

| What you want | Type this in terminal |
|---|---|
| AI-powered coding | `OpenCode groq` |
| Large documents (1M context) | `OpenCode gemini` |
| Work offline (no internet) | `OpenCode ollama` |
| Open the pretty GUI app | `OpenCode gui` |
| Restore last session | `OpenCode restore` |
| Two sessions at once | `OpenCode groq thesis` + `OpenCode ollama debug` |

---

## 2. What Happens When You Start

Every time you start a session, the system **automatically loads**:

1. `instructions.md` — your project blueprint (auto-loaded, always)
2. `MASTER_BOOTSTRAP.xml` — everything the AI needs to know
3. `notepad.md` — remembers what you did last time

**You don't need to do anything.** Just start typing.

---

## 3. Daily Workflow

### To write VBA code:
```
Just ask me. For example:
"Add a new button to the stock form that prints a label"
```

### To rebuild the workbook after code changes:
```
Run: .\vbe-auto\build.ps1 -ConfigPath .\vbe-auto\config.json
```

### To check the workbook is correct:
```
Run: .\vbe-auto\verify.ps1 -ConfigPath .\vbe-auto\config.json
```

### To run the full test suite:
```
Run: .\Software_Surgical_Edit\test-macros.ps1
```

### To build the thesis PDF:
```
Run: .\Thesis_Surgical_Edit\build-thesis.ps1
```

### To save your progress when stopping:
```
Tell me: /memory save "Done: fixed bug X | Next: add feature Y"
```

---

## 4. Where Everything Lives

| Item | Location |
|---|---|
| Your workbook (active) | `C:\Users\Administrator\Dropbox\ERP_v13.2.xlsm` |
| VBA source code | `Project\Software_Surgical_Edit\VBA_Modules\` |
| Thesis source | `Project\Thesis_Surgical_Edit\` |
| Build scripts | `Project\Software_Surgical_Edit\` |
| This guide | `Project\USER_GUIDE.md` |

*(Project = `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`)*

---

## 5. Known Issues (What Might Go Wrong)

### 🟢 Low impact (easy fix)

| Issue | What happens | What to do |
|---|---|---|
| Em dashes (—) in VBA code | Compile error | I fix this automatically. Just tell me |
| Comments between `_` line breaks | Syntax error | I fix this. Rare now |
| Stale p-code cache | False compile errors | Run `build.ps1` (not just save .xlsm) |

### 🟡 Medium impact

| Issue | What happens | What to do |
|---|---|---|
| Session disconnects | I forget what we were doing | Type `OpenCode restore` to relaunch. I read `notepad.md` and resume |
| Venue models 429 (Qwen3 Coder, Gemma 4 on OpenRouter) | Model fails to respond | Switch to Groq or Nemotron. Try `OpenCode groq` |
| Ollama not started | `OpenCode ollama` hangs | Wait 10-15s — launcher v3.0 auto-starts it |

### 🔴 High impact (rare)

| Issue | What happens | What to do |
|---|---|---|
| API key expired | "Authentication failed" | Regenerate key at the provider's website, update `opencode.json` |
| Excel crash during build | Corrupted workbook | Run `build.ps1` again (clean-slate rebuild) |
| Git conflict | Can't push changes | Run `git pull --rebase` then push again |

---

## 6. Anticipated Issues (Prepare Now)

### 🔮 If internet goes down
- Use offline mode: `OpenCode ollama`
- Ollama uses Qwen 1.5B (~95 seconds per response)
- Good for: simple VBA edits, code review
- Bad for: large tasks, thesis writing, complex reasoning

### 🔮 If Groq goes down
- Switch to: `OpenCode gemini` (Gemini 2.5 Flash, 1M context)
- Or: `OpenCode fcc` (Nemotron 120B via proxy)

### 🔮 If your hard drive fills up
- Old workbooks in `Software_Surgical_Edit/*.xlsm` (~5 files, ~50 MB total)
- Thesis PDFs in `Thesis_Surgical_Edit/output/`
- Git history (run `git gc` to clean)

### 🔮 If you want paid Claude access
1. Go to https://console.anthropic.com
2. Generate a new API key
3. Ask me to update `opencode.json` with the new key

---

## 7. Quick Reference Cards

### 🃏 Build & Verify
```powershell
.\Software_Surgical_Edit\build.ps1          # Rebuild workbook
.\Software_Surgical_Edit\verify.ps1         # 97 checks
.\milestone_13_2\tests\dss-audit.ps1       # Full audit
.\Software_Surgical_Edit\test-macros.ps1    # Macro tests
```

### 🃏 Git
```powershell
git status                                   # See what changed
git add -A                                   # Stage everything
git commit -m "message"                      # Save changes
git push                                     # Upload to GitHub
```

### 🃏 Thesis
```powershell
.\Thesis_Surgical_Edit\build-thesis.ps1      # Generate PDF
# Output: Thesis_Surgical_Edit/output/Memoire_Academix_v13_2_Final.pdf
```

### 🃏 Project Dashboard (menu-based)
```powershell
.\scripts\academix-launcher.ps1               # Interactive menu
# Or: OpenCode academix
```

---

## 8. Folder Structure (Simplified)

```
📂 C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\
 ├── 📁 Software_Surgical_Edit\          ← Main project folder
 │    ├── 📁 VBA_Modules\                ← VBA source code (.bas files)
 │    ├── build.ps1                      ← Rebuild workbook
 │    ├── verify.ps1                     ← Check workbook
 │    ├── test-macros.ps1                ← Run tests
 │    ├── *.xml                          ← Context files for AI
 │    └── *.xlsm                         ← Compiled workbooks (don't touch)
 ├── 📁 Thesis_Surgical_Edit\            ← Thesis files
 │    ├── Memoire_DSS_Logistique_ElBayadh.md    ← Thesis source
 │    ├── build-thesis.ps1               ← Build thesis PDF
 │    └── 📁 output\                     ← Generated PDFs
 ├── 📁 vbe-auto\                        ← Build toolkit
 ├── 📁 milestone_13_2\                  ← Tests & configs
 ├── 📁 .opencode\                       ← AI memory & skills
 └── USER_GUIDE.md                       ← This guide
```

---

## 9. Getting Help

- **To ask me anything**: Just type your question
- **To check system status**: Ask me "run the health check"
- **To save progress**: `/memory save "Done: X | Next: Y"`
- **To restart clean**: `/session reset`

# Claude Desktop GUI — Launch Checklist
> Academix v13.4 | Session 45 | 2026-06-14

## Pre-Launch Checklist

### ✅ Files Ready
- [x] `CLAUDE.md` — Updated with Session 45 status
- [x] `THESIS_CONTEXT.md` — Detailed thesis information
- [x] `CROSSFLOW_CLAUDE_DESKTOP.md` — Session history and git context
- [x] `.crossflow/HANDOFF.md` — Current project status
- [x] `ClaudeDesktop_DEEP_VERIFICATION.md` — Full verification strategy
- [x] `Thesis_Surgical_Edit/Memoire_DSS_Logistique_ElBayadh.md` — Source markdown
- [x] `Thesis_Surgical_Edit/output/Memoire_DSS_Logistique_ElBayadh.docx` — Output DOCX (99% complete)

### ✅ Git Status
- [x] All changes committed (fd9c342)
- [x] Pushed to remote repository
- [x] Working tree clean

### ✅ MCP Configuration
- [x] Filesystem MCP server configured in `claude_desktop_config.json`
- [x] Access to project root: `C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
- [x] Access to Google Drive: `C:\Users\Administrator\My Drive`

### ✅ Verification Status
- [x] ERP Workbook: 114/114 PASS
- [x] Thesis DOCX: 32/32 PASS
- [x] Manual verification: 99% complete
- [x] User verified and fixed in Word

---

## Launch Steps

### Step 1: Open Claude Desktop GUI
1. Click on Claude Desktop icon on Desktop or Start Menu
2. Wait for the application to fully load
3. Confirm you see the chat interface

### Step 2: Verify MCP Access
Type this in the chat:
```
Can you read the file CLAUDE.md in the project root and confirm you have access?
```
Expected: Claude reads and summarizes the CLAUDE.md file

### Step 3: Load Full Context
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 2)

### Step 4: Deep DOCX Analysis
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 3)

### Step 5: Formatting Verification
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 4)

### Step 6: Academic Standards Review
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 5)

### Step 7: Git History Review
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 6)

### Step 8: Final Assessment
Copy and paste the prompt from `ClaudeDesktop_DEEP_VERIFICATION.md` (Step 7)

---

## Expected Outcomes

### Claude Desktop Should:
1. ✅ Read all context files via MCP
2. ✅ Analyze the thesis DOCX content
3. ✅ Compare against source markdown
4. ✅ Verify formatting meets CNEPD BTS requirements
5. ✅ Review academic standards
6. ✅ Provide final assessment (99%+ confidence)

### If Issues Found:
1. Claude Desktop will identify specific issues
2. Document the issues in the chat
3. We can fix them in OpenCode
4. Re-verify in Claude Desktop

---

## Troubleshooting

### If MCP Access Fails:
1. Check `claude_desktop_config.json` exists
2. Verify filesystem MCP server path is correct
3. Restart Claude Desktop GUI
4. Check Node.js is installed (`node --version`)

### If Claude Can't Read Files:
1. Ensure project root path is correct in MCP config
2. Check file permissions
3. Try reading a simpler file first (like CLAUDE.md)

### If Analysis Seems Incomplete:
1. Ask Claude to read additional context files
2. Provide the ground truth parameters explicitly
3. Ask Claude to compare specific sections

---

## Key Information for Claude Desktop

### Project Identity
- **System**: VBA/Excel DSS for inventory management
- **Institution**: Direction de l'Education El Bayadh
- **Thesis**: BTS CNEPD — 4 chapters, 17 مباحث, 52 مطالب
- **Author**: Mahi Kamel Abdelghani

### Ground Truth (DO NOT MODIFY)
| Param | Value | Description |
|-------|-------|-------------|
| D | 789 | Annual Demand |
| Q* | 37 | EOQ via Wilson |
| ROP | 206 | Reorder Point |
| SS | 200 | Safety Stock |
| LT | 2 days | Lead Time |
| S | 801.45 DZD | Order Cost |
| PU | 4500 DZD | Unit Price |
| I | 20% | Holding Rate |

### Current Status
- **Thesis DOCX**: 143.3 KB, 32/32 PASS, 99% complete
- **Content**: 709 paragraphs, 26 tables, 46 footnotes
- **Formatting**: Single section, continuous page numbering, full RTL
- **Manual Verification**: User verified and fixed in Word

### Files to Reference
| File | Path | Purpose |
|------|------|---------|
| Deep Verification | ClaudeDesktop_DEEP_VERIFICATION.md | Full strategy |
| Project Context | CLAUDE.md | Main overview |
| Thesis Context | THESIS_CONTEXT.md | Detailed info |
| CrossFlow Sync | CROSSFLOW_CLAUDE_DESKTOP.md | Session history |
| HANDOFF | .crossflow/HANDOFF.md | Current status |

---

## After Verification

### If Everything Passes:
1. Thank Claude Desktop for the thorough review
2. Note any final recommendations
3. Proceed with academic submission
4. Update notepad.md with completion status

### If Issues Found:
1. Document the issues
2. Return to OpenCode to fix
3. Re-verify in Claude Desktop
4. Repeat until 100% complete

---

## Notes
- Claude Desktop GUI is the desktop application (not CLI)
- MCP filesystem gives full access to project root
- All context files are updated and current
- Git repository is synced with remote
- Ready for deep verification and final review
- The thesis is at 99% completion

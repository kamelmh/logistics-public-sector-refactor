# Agentic Protocols — ERP Académie v13.2
# How Groq + Claude + OMC collaborate on this project
# Generated: 2026-05-06

## Groq Deployment Protocol

### Trigger Activation
When Groq sees: `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`

**Immediate Actions:**
1. Read `.opencode/context.md` — full system context
2. Read `erp-project-context.xml` — module map, config, data flow
3. Read `erp-admin-paths.xml` — all file paths
4. Read `erp-agent-handoff.xml` — session state, routing
5. Activate skills based on task type
6. Ready for high-level feature development

### Behavior Rules
1. **Never** modify `mod_Config` constants or `CANON_*` values
2. **Always** use admin paths from `erp-admin-paths.xml`
3. **Always** check dependencies before code changes
4. **Always** update context files after changes
5. **Never** commit without explicit user approval
6. **Always** work in `$env:TEMP` → deploy to Dropbox → commit

### Context Management
1. Read XML files FIRST — don't guess project state
2. Use trigger words to activate full context instantly
3. Keep responses concise — tokens are valuable
4. Use `/memory save` before session end
5. Load skills only when needed — not all at once

## Cross-AI Collaboration

### Groq ↔ Claude Code
- Shared context via XML files in `Software_Surgical_Edit/`
- Shared state via `erp-agent-handoff.xml`
- Git commits preserve decision context for both AIs
- Claude handles: deep analysis, architecture, planning
- Groq handles: VBA code edits, quick fixes, context injection

### OMC Multi-Agent
- Use `/team N:agent "task"` for complex tasks
- Team pipeline: plan → prd → exec → verify → fix
- Agents: explore, analyst, planner, architect, debugger, executor, verifier, etc.
- Models: haiku (quick), sonnet (standard), opus (deep)

### Workspace Hygiene
```
C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\
├── .opencode\
│   └── context.md              ← Master context file
├── AI_Workspace\
│   ├── Context_Injections\     ← Context injection files
│   ├── Skills_Config\          ← Skills configuration
│   └── Agentic_Protocols\      ← Agentic collaboration rules
├── Software_Surgical_Edit\
│   ├── erp-project-context.xml ← Module intelligence map
│   ├── erp-admin-paths.xml     ← All file paths
│   ├── erp-agent-handoff.xml   ← Session state & routing
│   └── VBA_Modules\            ← All .bas source files
└── Thesis_Surgical_Edit\       ← Thesis chapters (Arabic)
```

## High-Level Feature Development Protocol

### Phase 1: Context Activation
1. User types: `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`
2. Groq reads all XML files and context.md
3. Skills activated based on task type
4. Admin paths verified and accessible

### Phase 2: Feature Planning
1. Use `analyst` or `planner` agent for requirements
2. Use `architect` agent for system design
3. Use `/ccg` for multi-model synthesis if needed
4. Document decisions in commit trailers

### Phase 3: Implementation
1. Work on copy in `$env:TEMP`
2. Deploy to Dropbox
3. Test via VBA COM or manual verification
4. Commit with proper trailers

### Phase 4: Verification
1. Use `verifier` or `test-engineer` agent
2. Run smoke tests via `mod_TestHarness`
3. Update `erp-project-context.xml`
4. Sync all config files

## Next Session Checklist

- [ ] Open terminal → `cd C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor`
- [ ] Launch `opencode`
- [ ] Type: `ACADEMIX_CONTEXT v13.2 DEPLOYED_IN_OPENCODE`
- [ ] Verify Groq reads context correctly
- [ ] Check admin paths are resolved
- [ ] Confirm skills are available
- [ ] Proceed with feature development

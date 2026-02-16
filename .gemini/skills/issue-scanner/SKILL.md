---
name: issue-scanner
description: Thoroughly scan the codebase for bugs, technical debt, and architectural issues, and update agents/BACKLOG.md. Use this skill periodically or after significant changes to ensure the project maintains high quality standards and that all identified issues are documented and tracked.
---

# Issue Scanner

This skill guides you through a thorough audit of the project to identify and document technical debt, bugs, and architectural flaws.

## Workflow

### 1. Execute Sub-Agent Audits
Run all specialized quality sub-agents in parallel to gather multi-dimensional project data:

```
# Code quality and style review
gdscript-reviewer(objective="Review the entire game/ directory for code quality, static typing, and style guide compliance.")

# Scene architecture audit
scene-auditor(objective="Audit the game/ scenes and entities for proper node hierarchy, composition, and signal patterns.")

# Integration check
integration-checker(objective="Verify cross-system wiring, autoload references, and signal connections.")

# Pre-playtest validation
playtest-checker(objective="Run a full scan for broken references, missing resources, and script errors.")
```

### 2. Manual Grep Scans
Supplement sub-agent results with targeted grep searches for common anti-patterns:

- **Missing return types**: `grep -r "func [a-z0-9_]*(" game | grep -v "\->" | grep -v "_ready" | grep -v "_process" | grep -v "_physics_process" | grep -v "_init"`
- **Generic Resource exports**: `grep -r "@export var .* : Resource" game`
- **Dynamic get_node**: `grep -r "get_node(" game | grep -v "@onready"`
- **TODO/FIXME/HACK**: `grep -rE "TODO|FIXME|HACK" game`

### 3. Consolidation and Update
1. **Read** the current `agents/BACKLOG.md` and `agents/SPRINT.md`.
2. **Mark done** any tickets whose issues have been resolved (move to Done This Sprint in SPRINT.md, append to agents/COMPLETED.md).
3. **Add** new issues as tickets in `agents/BACKLOG.md` using the standard format:
   ```
   ### T-XXXX
   - Title: [description]
   - Status: todo
   - Assigned: unassigned
   - Priority: critical | high | medium | low
   - Milestone: M0
   - Depends: none
   - Refs: [file paths]
   - Notes: [details]
   ```
   Priority mapping: CRITICAL → critical, HIGH → high, MEDIUM → medium, WARNING/STYLE → low.
4. **Sort** tickets within each milestone by priority.

### 4. Verification
After updating the tracker, double-check that all paths and line numbers (if provided) are accurate.

## Grounded Suggestions
When identifying an issue, always:
1. **Explain WHY** it is an issue (refer to `docs/best-practices/` if applicable).
2. **Propose a FIX** that aligns with the project's architecture.
3. **Reference Docs**: Use `godot-docs` to ensure the suggested fix uses the correct Godot 4.5 APIs.

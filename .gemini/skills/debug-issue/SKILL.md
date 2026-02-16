---
name: debug-issue
description: Diagnose and fix a bug or runtime issue in the game. Analyzes error messages, traces code paths, checks Godot docs, and applies fixes. Use when something doesn't work as expected.
argument-hint: <error-message or behavior-description>
---

# Debug Issue

Invoke the `debugger` agent to diagnose and fix this issue.

**Issue:** $ARGUMENTS

Follow the instructions in `.gemini/agents/debugger.md` to:
- Understand the problem
- Gather context
- Diagnose root cause
- Look up Godot docs (MANDATORY)
- Apply minimal fix
- Verify and report

After the agent returns its report, summarize for the user:
- Root cause identified
- Fix applied (files and lines modified)
- Any related risks or prevention notes

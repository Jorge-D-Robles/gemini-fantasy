---
name: debug-issue
description: Diagnose and fix a bug or runtime issue in the game. Analyzes error messages, traces code paths, checks Godot docs, and applies fixes. Use when something doesn't work as expected.
argument-hint: <error-message or behavior-description>
---

# Debug Issue

Invoke the `debugger` agent to diagnose and fix this issue.

**Issue:** $ARGUMENTS

Run this command:

```
Task(subagent_type="debugger", prompt="Debug this issue: $ARGUMENTS. Follow the full 7-step debug process: understand the problem, gather context, diagnose root cause, look up Godot docs (MANDATORY), apply minimal fix, verify, and report.")
```

After the agent returns its report, summarize for the user:
- Root cause identified
- Fix applied (files and lines modified)
- Any related risks or prevention notes

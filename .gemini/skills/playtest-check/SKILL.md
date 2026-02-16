---
name: playtest-check
description: Pre-playtest validation that checks for common issues before running the game. Scans for broken references, missing resources, script errors, and integration problems.
---

# Pre-Playtest Validation Check

Invoke the `playtest-checker` subagent to scan the project for issues before playtesting.

Call the `playtest-checker` tool:

```
playtest-checker(objective="Run a full pre-playtest validation check on the game/ directory. Check file structure, script compilation, scene references, autoloads, signals, JRPG-specific issues, and performance anti-patterns.")
```

After the agent returns its report, summarize the key findings for the user:
- Pass/warning/error counts
- Any critical issues that would prevent the game from running
- Performance warnings worth addressing

---
name: integration-check
description: Verify that game systems are properly wired together. Checks signal connections, autoload references, resource paths, and cross-system dependencies. Use after building multiple systems to ensure they integrate correctly.
argument-hint: [system-name or "all"]
---

# Integration Check

Invoke the `integration-checker` agent to verify system integration.

**Target:** $ARGUMENTS

Run this command:

```
Task(subagent_type="integration-checker", prompt="Check integration for: $ARGUMENTS. If no target given, check ALL systems. Verify autoloads, signal wiring, cross-system dependencies, resource paths, scene-system integration, and data layer consistency.")
```

After the agent returns its report, summarize the key findings for the user:
- Integration score
- Any critical wiring issues
- Dependency graph (especially circular dependencies)

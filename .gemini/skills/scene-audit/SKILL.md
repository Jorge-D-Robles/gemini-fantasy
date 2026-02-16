---
name: scene-audit
description: Audit the project's scene and script architecture for Godot best practices. Checks scene organization, dependency graph, signal patterns, and composition. Use periodically to catch architectural issues early.
argument-hint: [directory-or-file]
---

# Scene Architecture Audit

Invoke the `scene-auditor` subagent to perform a comprehensive architecture audit.

**Target:** $ARGUMENTS

Call the `scene-auditor` tool:

```
scene-auditor(objective="Audit scene architecture at: $ARGUMENTS. If no target given, audit the entire game/ directory.")
```

After the agent returns its report, summarize the key findings for the user:
- Overall health rating
- Any HIGH priority recommendations
- Dependency graph issues (especially circular dependencies)

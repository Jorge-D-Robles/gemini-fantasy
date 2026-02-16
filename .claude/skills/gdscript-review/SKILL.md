---
name: gdscript-review
description: Review GDScript code for quality, Godot best practices, and style guide compliance. Use after writing code or before committing changes.
argument-hint: [file-path or directory]
---

# GDScript Code Review

Invoke the `gdscript-reviewer` agent to perform a comprehensive code review.

**Target:** $ARGUMENTS

Run this command:

```
Task(subagent_type="gdscript-reviewer", prompt="Review GDScript code at: $ARGUMENTS. If no target given, review all .gd files via Glob('game/**/*.gd').")
```

After the agent returns its report, summarize the key findings for the user:
- Total files reviewed and overall score
- Any CRITICAL issues that need immediate attention
- Top recurring patterns to fix

---
name: gdscript-review
description: Review GDScript code for quality, Godot best practices, and style guide compliance. Use after writing code or before committing changes.
argument-hint: [file-path or directory]
---

# GDScript Code Review

Invoke the `gdscript-reviewer` subagent to perform a comprehensive code review.

**Target:** $ARGUMENTS

If no specific target was given, review all `.gd` files by running `Glob("game/**/*.gd")`.

Call the `gdscript-reviewer` tool:

```
gdscript-reviewer(objective="Review GDScript code at: $ARGUMENTS. If no target given, review all .gd files via glob('game/**/*.gd'). Ground every critique in official Godot 4.5 documentation or the project's docs/best-practices/ files.")
```

After the agent returns its report, summarize the key findings for the user:
- Total files reviewed and overall score
- Critical issues count
- Warning count
- Style issues count
- Top 3 most common issues across all files
- Overall code quality assessment

## Post-Review Action
**MANDATORY:** After completing the review, you MUST update `agents/BACKLOG.md`. Add any new [CRITICAL] or [WARNING] issues as tickets using the standard ticket format (T-XXXX, Status, Priority, Milestone, etc.).

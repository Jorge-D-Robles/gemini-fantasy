---
name: godot-doc-lookup
description: Look up Godot documentation for a class, method, or topic. Use when you need API details, tutorial guidance, or code examples from the Godot docs.
argument-hint: <class-name, method, or topic>
---

# Godot Documentation Lookup

Invoke the `godot-docs` subagent for documentation lookup.

**Query:** $ARGUMENTS

Call the `godot-docs` tool:

```
godot-docs(objective="Look up $ARGUMENTS. Return class inheritance, key properties, methods, signals, code examples, and best practice notes.")
```

After the agent returns its summary, present the structured results to the user.

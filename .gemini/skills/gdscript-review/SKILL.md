---
name: gdscript-review
description: Review GDScript code for quality, Godot best practices, and style guide compliance. Use after writing code or before committing changes.
argument-hint: [file-path or directory]
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob
---

# GDScript Code Review

Review GDScript code for quality and best practices. Target: **$ARGUMENTS**

## Mandatory Research
Before performing a review, you MUST:
1. **Activate the `godot-docs` skill** for all relevant classes in the target code.
2. **Ground every critique** in official Godot 4.5 documentation or the project's `docs/best-practices/` files. Do not rely on general knowledge.

If no specific target was given, review all `.gd` files by running `Glob("game/**/*.gd")`.

## Review Checklist

For each `.gd` file, check against all of the following:

### 1. Static Typing

- [ ] All variables have explicit types: `var health: int = 0`
- [ ] All function parameters have types: `func heal(amount: int) -> void:`
- [ ] All function return types are declared: `-> void`, `-> int`, `-> Array[String]`
- [ ] `:=` used only when type is obvious from right-hand side
- [ ] `@onready` vars have explicit types: `@onready var bar: ProgressBar = $Bar`

### 2. Naming Conventions

- [ ] File names use `snake_case`: `yaml_parser.gd`
- [ ] Class names use `PascalCase`: `class_name YAMLParser`
- [ ] Functions use `snake_case`: `func load_level():`
- [ ] Variables use `snake_case`: `var particle_effect`
- [ ] Signals use `snake_case` past tense: `signal door_opened`
- [ ] Constants use `CONSTANT_CASE`: `const MAX_SPEED = 200`
- [ ] Enum names use `PascalCase` (singular): `enum Element`
- [ ] Enum members use `CONSTANT_CASE`: `EARTH, WATER, AIR, FIRE`
- [ ] Private members prefixed with `_`: `var _counter`, `func _recalculate():`

### 3. Code Order

- [ ] Correct declaration order: `@tool` → `class_name` → `extends` → `## doc comment`
- [ ] Properties order: signals → enums → constants → static vars → `@export` → vars → `@onready`
- [ ] Methods order: `_init()` → `_ready()` → `_process()` → `_physics_process()` → other virtuals → public → private
- [ ] Inner classes at the end

### 4. Formatting

- [ ] **Tabs** for indentation (not spaces)
- [ ] **Two blank lines** between functions
- [ ] Lines under **100 characters** (prefer 80)
- [ ] **Trailing commas** in multiline arrays, dicts, enums
- [ ] **Double quotes** for strings (single only to avoid escapes)
- [ ] `and`/`or`/`not` instead of `&&`/`||`/`!`
- [ ] No unnecessary parentheses in conditions
- [ ] Spaces around operators and after commas
- [ ] No vertical alignment of expressions

### 5. Godot Best Practices

- [ ] Prefer signals over direct method calls for decoupled communication
- [ ] One script per scene node (composition over inheritance)
- [ ] Use `@export` for inspector-exposed variables
- [ ] Use `@onready` to cache node references (not repeated `get_node()` calls)
- [ ] Use groups for broadcasting to multiple nodes
- [ ] No `get_node()` with long paths — prefer dependency injection or signals
- [ ] `_ready()` used for initialization, not `_init()` for node setup
- [ ] Use `is_instance_valid()` before accessing potentially freed nodes
- [ ] Use `queue_free()` not `free()` for safe deletion

### 6. Documentation

- [ ] Classes have `##` doc comments explaining their purpose
- [ ] Public methods have `##` doc comments
- [ ] Complex logic has inline `#` comments explaining why (not what)
- [ ] Signals have doc comments explaining when they're emitted

### 7. Performance Patterns

- [ ] No expensive operations in `_process()` or `_physics_process()` that could be event-driven
- [ ] Node references cached in `@onready` rather than fetched every frame
- [ ] String concatenation avoided in hot paths (use `StringName` or `%` formatting)
- [ ] `is_on_floor()` called after `move_and_slide()`, not before

### 8. Safety

- [ ] No magic numbers — use named constants
- [ ] No hardcoded file paths — use `@export` or constants
- [ ] No unchecked arraydictionary access in critical paths
- [ ] Nullvalidity checks before accessing nodes that might not exist

## Output Format

For each file reviewed, provide:

```
### <file_path>

**Score: X/10**

**Issues:**
1. [CRITICAL] <issue description> — line N
2. [WARNING] <issue description> — line N
3. [STYLE] <issue description> — line N

**Suggested fixes:**
- <specific fix with code snippet>

**Strengths:**
- <what the code does well>
```

At the end, provide an overall summary with:
- Total files reviewed
- Critical issues count
- Warning count
- Style issues count
- Top 3 most common issues across all files
- Overall code quality assessment

## Post-Review Action
**MANDATORY:** After completing the review, you MUST update `ISSUES_TRACKER.md`. Add any new [CRITICAL] or [WARNING] issues found during the review to the appropriate section, or create a new section if necessary.

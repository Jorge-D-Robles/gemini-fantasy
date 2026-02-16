---
name: sprint-planner
description: Plan a development sprint by reading the implementation guide and design docs, then creating an ordered list of concrete tasks with skill assignments. Use to plan what to build next.
argument-hint: <sprint-goal or phase> [details...]
disable-model-invocation: true
---

# Sprint Planner

Plan a development sprint for: **$ARGUMENTS**


## Step 1 — Understand Current State

1. **Read `docs/IMPLEMENTATION_GUIDE.md`** for the development roadmap and phases
2. **Scan existing code** — `Glob game/**/*.gd` and `game/**/*.tscn` to know what's built
3. **Read recent git log** — understand what was recently completed
4. **Check for incomplete work** — look for TODO comments, stub methods, empty scenes

## Step 2 — Identify Sprint Scope

Based on the implementation guide phases:

| Phase | Months | Focus |
|-------|--------|-------|
| 1 — Prototype | 1-3 | Combat system prototype |
| 2 — Vertical Slice | 4-6 | First 2-3 hours fully polished |
| 3 — Core Content | 7-14 | All 5 regions, main story |
| 4 — Content Complete | 15-18 | All side quests, endings |
| 5 — Polish | 19-22 | Balance, UX, accessibility |
| 6 — Launch | 23-24 | Testing, performance, release |

Determine which phase the project is in and what the sprint goal maps to.

## Step 3 — Create Sprint Task List

Break the sprint goal into concrete, ordered tasks. Each task should:
- Map to exactly one skill
- Be completable in one session
- Have clear acceptance criteria
- List dependencies on other tasks

### Sprint Template

```markdown
# Sprint: <Sprint Name>
**Goal:** <One sentence describing the sprint outcome>
**Phase:** <Implementation phase>
**Estimated tasks:** <N>

## Prerequisites
- [ ] <Thing that must exist before sprint starts>

## Task List

### 1. <Task Name>
- **Skill:** `skill-name <args>`
- **Depends on:** None / Task N
- **Acceptance:** <What "done" looks like>
- **Files:** <Expected files to createmodify>

### 2. <Task Name>
- **Skill:** `skill-name <args>`
- **Depends on:** Task 1
- **Acceptance:** <What "done" looks like>
- **Files:** <Expected files to createmodify>

## Integration Tasks
- [ ] Wire signals between systems
- [ ] Register autoloads
- [ ] Update project.godot

## Verification
- [ ] `gdscript-review` all new code
- [ ] `integration-check` all modified systems
- [ ] `playtest-check` full project
- [ ] `scene-audit` affected directories

## Editor Tasks (manual, after code is done)
- [ ] Paint tilemaps
- [ ] Assign sprites
- [ ] Configure collision shapes
- [ ] Test in Godot editor
```

## Step 4 — Present to User

Show the sprint plan and ask for approval before execution. The user may:
- Approve and proceed
- Reorder tasks
- Remove tasks
- Add tasks
- Adjust scope

## Step 5 — Execute Sprint (after approval)

1. Use `progress tracking` to track all sprint tasks
2. Execute each task using the assigned skill
3. After each task, mark it complete and verify
4. Run verification skills after all implementation tasks
5. Provide final sprint report

## Step 6 — Sprint Report

```markdown
# Sprint Complete: <Sprint Name>

## Completed
- [x] Task 1 — <files created>
- [x] Task 2 — <files created>

## Code Quality
- GDScript Review: <score>/100
- Integration Check: <score>/100
- Playtest Check: <passfail>

## Files Created
- `game/systems/...`
- `gamescenes/...`

## What's Next
- <Recommended next sprint>
- <Open issues to address>

## Editor Tasks Remaining
- <Things the user must do in Godot>
```

## Sprint Planning Principles

1. **Build vertically** — Complete a thin slice end-to-end before widening
2. **Core systems first** — State machine, then combat, then everything else
3. **Data before scenes** — Create Resources, then scenes that use them
4. **Systems before UI** — Build logic, then put UI on top
5. **Test early** — Don't build 10 systems then integrate; wire up after each

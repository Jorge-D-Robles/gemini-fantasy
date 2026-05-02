# Gemini Fantasy

2D JRPG built with Godot 4.5, GDScript, mobile renderer. Licensed GPLv3.

## HARD BANS (never do these — no exceptions)

- **Never use A5 autotile sheets** — any file matching `*A5*`, `*tileA5*`, or `*_A5_*` in its name
  is an RPGMaker autotile sheet where columns within a row produce seam artifacts when mixed.
  Use TF_TERRAIN (`TimeFantasy_TILES/TILESETS/terrain.png`) for outdoor ground,
  TF_DUNGEON for dungeon/ruins ground, and B-sheets (`tf_*_tileB_*.png`) for objects.
- **Never use `set_cells_terrain_connect()`** without pre-configured Terrain Sets (we don't have them).
- **Never carpet-bomb decorations** — no percentage-based coverage, no noise-driven object scatter
  that fires on every cell. Every decoration must be intentional and sparse.

## Git Workflow

**Single-branch, direct-to-main workflow.** No feature branches, no PRs, no worktrees. One Codex instance runs at a time, committing directly to `main`.

**BEFORE starting any task**, sync to the latest `origin/main`:

```bash
git fetch origin main
git pull origin main
```

After completing any task, **automatically stage, commit, and push** without asking:

1. Stage the changed files (`git add <specific files>`)
2. Commit with a clear message
3. Push to `origin main`

That's it. No branches, no PRs, no worktrees.

**MANDATORY:** "The issue tracker" refers to `agents/BACKLOG.md` (all tickets) and `agents/SPRINT.md` (current sprint). **DO NOT** use GitHub Issues or the `gh issue` command unless explicitly asked. Always check `agents/SPRINT.md` before starting work. New bugs go in `agents/BACKLOG.md`. Current work is tracked in `agents/SPRINT.md`.

Do not ask for confirmation at any step. This applies to all tasks — bug fixes, features, refactors, doc updates, etc.

### Agent Configuration (Single Source of Truth)

**MANDATORY:** `AGENTS.md` is the single source of truth for all project rules, workflows, and agent instructions. `gemini.md` is a symbolic link to this file. Any change to project norms MUST be made in `agents/AGENT_RULES.md` (the real file behind both symlinks). This ensures both Codex and Gemini agents remain perfectly synchronized.


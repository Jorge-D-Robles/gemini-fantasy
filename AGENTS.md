# Gemini Fantasy Tutorial

This repository is now the tutorial/website home for the Gemini Fantasy Godot JRPG tutorial series. It is no longer the active full Godot game implementation.

## Source of Truth

`agents/AGENT_RULES.md` is the single source of truth for project rules and agent workflow. `CLAUDE.md` and `gemini.md` are symbolic links to that file.

## Current Purpose

- `tutorial/*.md` contains the learner-facing tutorial modules.
- `website/` builds the static GitHub Pages site from the tutorial Markdown.
- `.github/workflows/deploy-tutorial.yml` deploys the site from `website/dist/`.

The old full Godot game code was archived at branch `deprecated/game-code` and tag `deprecated-game-code-2026-05-02`.

# Gemini Fantasy Tutorial

This repository hosts the static website and Markdown source for a 27-module Godot JRPG tutorial series. The tutorial teaches programmers how to build a small turn-based JRPG vertical slice in Godot, from project setup through scenes, data, dialogue, combat, quests, save/load, audio, and final polish.

The live site is deployed with GitHub Pages from the `website/` build pipeline. The learner-facing source lives in `tutorial/*.md`; the static site generator lives in `website/`.

## Repository Layout

```text
tutorial/   Markdown source for the tutorial modules and maintainer notes
website/    Static site generator, templates, styles, and package metadata
.github/    GitHub Pages deployment workflow
agents/     Shared instructions for Codex/Gemini/Claude agents
```

The old full Godot game implementation was archived before this repo pivot. To inspect it, use branch `deprecated/game-code` or tag `deprecated-game-code-2026-05-02`.

## Local Development

```bash
cd website
npm ci
npm run build
```

Build output is written to `website/dist/`, which is ignored on `main` and deployed by GitHub Actions.

To run the tutorial consistency checks:

```bash
python3 tutorial/tools/check_tutorial.py
```

## Deployment

GitHub Pages deploys on pushes to `main` that change `tutorial/**` or `website/**`. The workflow builds the site with Node 20 and uploads `website/dist/` as the Pages artifact.

## License

GPLv3. See `LICENSE`.

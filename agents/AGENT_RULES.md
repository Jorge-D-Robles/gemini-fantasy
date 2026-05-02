# Gemini Fantasy Tutorial

This repo is the static tutorial/website repo for the Gemini Fantasy Godot JRPG tutorial series. It is not the active full Godot game implementation.

## Repository Purpose

- `tutorial/*.md` is the learner-facing tutorial source.
- `website/` contains the Node/Tailwind static site generator.
- `.github/workflows/deploy-tutorial.yml` builds and deploys the site to GitHub Pages.
- `website/dist/` and `website/node_modules/` are generated local artifacts and must stay untracked.

The old full Godot game implementation was archived before the repo pivot:

- Branch: `deprecated/game-code`
- Tag: `deprecated-game-code-2026-05-02`

Use those refs only for archaeology. Do not restore active game development files to `main` unless explicitly asked.

## Hard Boundaries

- Do not treat this as an active Godot game repo.
- Do not recreate `game/`, `demo/`, `docs/`, `guide/`, backlog/sprint files, bundled agent skill folders, or old worktree folders on `main`.
- Do not use GitHub Issues unless the user explicitly asks. There is no active issue tracker in this cleaned tutorial repo.
- Keep tutorial edits in `tutorial/` and website edits in `website/`.

## Git Workflow

Use a single-branch, direct-to-main workflow.

Before starting any task:

```bash
git fetch origin main
git pull origin main
```

After completing any task, automatically stage, commit, and push without asking:

```bash
git add <specific files>
git commit -m "<clear message>"
git push origin main
```

Do not create feature branches or pull requests for normal work. The archival branch `deprecated/game-code` was a one-time preservation branch.

## Tutorial Editing Rules

- Preserve the 27-module curriculum shape unless the user asks for a structural change.
- Keep module filenames in `NN_descriptive_name.md` format.
- Use approachable, technical prose for programmers new to Godot.
- Motivate each major concept before implementation.
- Use current Godot 4 terminology and APIs.
- Keep cross-module contracts consistent; when changing a concept, search the whole `tutorial/` directory for later references.
- Run `python3 tutorial/tools/check_tutorial.py` after non-trivial tutorial edits.

## Website Editing Rules

- The site is static HTML generated from Markdown by `website/build.js`.
- The stack is Node.js, `marked`, `highlight.js`, Tailwind CSS, and vanilla JavaScript.
- Do not add a frontend framework unless the user explicitly asks.
- Build locally with:

```bash
cd website
npm ci
npm run build
```

- Keep `website/dist/` ignored on `main`; GitHub Actions uploads it as the deployment artifact.

## Deployment

GitHub Pages deploys when pushes to `main` change `tutorial/**` or `website/**`. The deployment workflow uses Node 20, runs `npm ci`, runs `npm run build`, and publishes `website/dist/`.

## Agent Configuration

`agents/AGENT_RULES.md` is the single source of truth for Codex, Claude, and Gemini instructions. `CLAUDE.md` and `gemini.md` must remain symlinks to this file.

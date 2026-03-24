# Website Plan: JRPG Tutorial Static Site

## Goal

A GitHub Pages static site that renders the 21 tutorial markdown files as a clean, navigable, visually polished course — similar in spirit to GDQuest's tutorial format. No backend, no CMS, no SPA framework. Just static HTML generated from markdown at build time.

## Why No Framework

React, Vue, Angular — none are needed. This is a content site with zero interactivity beyond navigation. A lightweight build script that converts markdown to HTML with a shared template is the right tool. Adding a framework would introduce hundreds of KB of JS for no benefit.

We'll use:
- **Node.js build script** — reads markdown, outputs static HTML
- **marked** — fast, well-maintained markdown-to-HTML converter
- **highlight.js** — syntax highlighting for GDScript code blocks
- **Tailwind CSS (CLI build)** — utility-first styling compiled at build time, producing a static CSS file with only used classes. No runtime JS, no FOUC.
- **Vanilla JS** — a single `scripts.js` for mobile nav toggle and code block copy buttons

## Architecture

```
website/
├── PLAN.md                # This file
├── package.json           # Node deps (marked, highlight.js, tailwindcss)
├── tailwind.config.js     # Tailwind content paths
├── build.js               # Build script: MD → HTML
├── .gitignore             # node_modules/, dist/
├── src/
│   ├── template.html      # Base HTML template (head, nav, sidebar, content slot, footer)
│   ├── index.html         # Landing page (course overview, module list)
│   ├── styles.css         # Tailwind directives + custom styles (code blocks, blockquotes, etc.)
│   ├── scripts.js         # Mobile nav toggle, copy button, active sidebar highlighting
│   └── gdscript.js        # Custom highlight.js language grammar for GDScript
├── public/                # Static assets copied as-is to dist/
│   └── favicon.ico
└── dist/                  # Build output (gitignored on main, deployed via GitHub Actions)
    ├── index.html
    ├── styles.css
    ├── scripts.js
    ├── 01-the-journey-begins.html
    ├── 02-gdscript-for-programmers.html
    ├── ...
    └── 21-finish-line.html
```

## Build Process

`npm run build` does two steps:

### Step 1: Tailwind CSS compilation
```bash
npx tailwindcss -i ./src/styles.css -o ./dist/styles.css --minify
```
This scans `src/template.html` and `build.js` for Tailwind class usage and produces a static CSS file containing only the classes actually used. No runtime JS, no CDN dependency.

### Step 2: HTML generation (`node build.js`)

1. Read all `../tutorial/*.md` files
2. Filter to files matching `^\d{2}_` prefix (skips PLAN.md)
3. Sort by numeric prefix (01, 02, ..., 21)
4. For each file:
   a. **Slug derivation:** `filename.replace(/_/g, '-').replace('.md', '')` → e.g., `01_the_journey_begins.md` → `01-the-journey-begins`
   b. **Title extraction:** Parse first `# ` heading. For sidebar labels, use the portion after `Module N: ` and before ` — ` (if present). Full title used in `<title>` tag and content heading.
   c. Convert markdown to HTML via `marked` with custom renderer overrides:
      - **Blockquotes:** Check inner text for `**See:**` prefix → add `class="doc-reference"`. Check for `**Note:**` → add `class="note"`.
      - **Code blocks:** Use highlight.js with custom GDScript grammar (not Python alias)
      - **Tables:** Add Tailwind classes for styling
   d. Inject the HTML into `template.html` at the `{{CONTENT}}` slot
   e. Set `<title>` to `Module N: Short Title | JRPG in Godot 4`
   f. Generate prev/next navigation links
   g. Mark current module as active in sidebar
   h. Write to `dist/XX-slug.html`
5. Generate `dist/index.html` from `src/index.html` with the module list injected
6. Copy `src/scripts.js` and `public/` assets to `dist/`

## Page Layout

### Desktop (≥1024px)

```
┌──────────────────────────────────────────────────────┐
│  Header: "JRPG in Godot 4" logo/title    [GitHub]   │
├────────────┬─────────────────────────────────────────┤
│  Sidebar   │  Content                                │
│            │                                         │
│  Part I    │  # Module Title                         │
│   ● Mod 1  │                                         │
│   ○ Mod 2  │  ## Section                             │
│   ○ Mod 3  │  Text, code blocks, blockquotes...     │
│            │                                         │
│  Part II   │  ```gdscript                           │
│   ○ Mod 4  │  func _ready():                        │
│   ○ Mod 5  │      pass                              │
│   ...      │  ```                                    │
│            │                                         │
│            │  ← Previous  |  Next →                  │
└────────────┴─────────────────────────────────────────┘
```

- Sidebar: fixed position, scrollable, 280px wide
- Active module highlighted with accent color and left border
- Part groupings with collapsible sections (CSS-only `details/summary`)
- Content area: max-width ~780px, centered within remaining space

### Mobile (<1024px)

- Hamburger menu toggles sidebar as a slide-out overlay (vanilla JS in `scripts.js`)
- Content fills full width with padding
- Navigation arrows at bottom of content

## Styling

### Theme
- **Dark background** for the overall page (`#0f172a` / Tailwind `slate-900`)
- **Slightly lighter panel** for content area (`#1e293b` / `slate-800`)
- **Sidebar** darker than content (`#0f172a` with subtle border)
- **Accent color**: Crystal blue (`#38bdf8` / `sky-400`)
- **Text**: Light gray (`#e2e8f0` / `slate-200`) for body, white for headings
- **Code blocks**: Darker background (`#020617` / `slate-950`) with syntax highlighting
- **Links**: Accent blue, underline on hover
- **Blockquotes** (`doc-reference`): Left-bordered with accent color, slightly different background
- **Blockquotes** (`note`): Left-bordered with yellow/amber

### Typography
- Headings: Inter (loaded via Google Fonts) or system sans-serif fallback
- Body: Same sans-serif, 16px base, 1.7 line height
- Code: JetBrains Mono (loaded) or system monospace fallback
- Inline code: Slightly highlighted background

### Code Blocks
- Syntax highlighted with highlight.js using a **custom GDScript grammar** (~50 lines) covering: `@export`, `@onready`, `signal`, `func`, `extends`, `class_name`, `match`, `var`, `const`, `enum`, built-in types (`String`, `int`, `float`, `bool`, `Vector2`, `Array`, `Dictionary`)
- Language label in top-right corner ("GDScript")
- Copy button (vanilla JS in `scripts.js`)
- Dark theme matching overall aesthetic

### Special Elements
- **`> **See:** ...` blockquotes**: Styled as reference cards — blue left border, book icon, distinct background
- **`> **Note:** ...` blockquotes**: Yellow left border, info icon
- **Tables**: Zebra-striped rows, bordered, responsive (horizontal scroll on mobile)
- **Module navigation cards**: Previous/Next as styled cards with module number + title
- **ASCII diagrams** (unfenced or no-lang code blocks): `white-space: pre`, `overflow-x: auto` to prevent mobile wrapping

## Module Metadata

| Field | Source | Transform |
|-------|--------|-----------|
| Module number | Filename prefix (`01`, `02`, ...) | `parseInt(filename.slice(0, 2))` |
| Full title | First `# ` heading | Regex: `/^# (.+)$/m` |
| Short title | Full title, trimmed | After `Module N: `, before ` — ` if present |
| Slug | Filename | `filename.replace(/_/g, '-').replace('.md', '')` |
| Part grouping | Hardcoded map in build.js | See below |

Part groupings:
- **Part I: Welcome to Godot** — Modules 1-3
- **Part II: Building the World** — Modules 4-6
- **Part III: Data and Dialogue** — Modules 7-10
- **Part IV: Combat** — Modules 11-15
- **Part V: Systems** — Modules 16-18
- **Part VI: Polish** — Modules 19-21

Fallback: If no `# ` heading is found, use the slug as the title and emit a warning to stderr.

## Markdown Processing

### Blockquote Classification (via `marked` renderer override)
The default `marked` renderer produces plain `<blockquote>` tags. We override the `blockquote` renderer to inspect the inner HTML:
- Contains `<strong>See:</strong>` → add `class="doc-reference"`
- Contains `<strong>Note:</strong>` → add `class="note"`
- Otherwise → default `<blockquote>`

### Code Block Highlighting
- Fenced blocks with `gdscript` lang → highlighted with custom GDScript grammar, labeled "GDScript"
- Fenced blocks with other languages → highlighted normally
- Fenced blocks with no lang → `class="language-plaintext"`, no highlighting, `overflow-x: auto`

### Link Handling
- Godot doc URLs (`https://docs.godotengine.org/...`) → kept as-is, opened in new tab (`target="_blank"`)
- Internal module references → no transformation needed (none exist in current content)

### Tables
Markdown tables → HTML `<table>` with wrapper `<div class="table-wrapper">` for horizontal scroll on mobile.

## Navigation

### Sidebar (desktop)
- All 21 modules grouped by Part
- Current module highlighted with accent left border
- Part headings as `<details open>` / `<summary>` — collapsible, default open

### Prev/Next (all screen sizes)
- Bottom of each module page
- Module 1 has no "Previous", Module 21 has no "Next"
- Shows module number and short title

### Landing Page
- Course title and description
- "Start the Tutorial" CTA button
- Full module list with part groupings (clickable)
- Brief description of Crystal Saga and what readers will build

## GitHub Pages Deployment

**GitHub Actions** is the deployment mechanism (not manual `gh-pages` branch pushes).

`.github/workflows/deploy.yml`:
1. Triggered on push to `main` when `tutorial/**` or `website/**` files change
2. Installs Node.js and npm dependencies
3. Runs `npm run build` in `website/`
4. Deploys `website/dist/` to GitHub Pages using `actions/upload-pages-artifact` + `actions/deploy-pages`

All links in generated HTML are relative — no `base_path` configuration needed since relative paths work regardless of the Pages subpath.

The `dist/` directory is gitignored on `main`. It is never committed — GitHub Actions builds and deploys it directly.

## npm Scripts

```json
{
  "scripts": {
    "build": "npx tailwindcss -i ./src/styles.css -o ./dist/styles.css --minify && node build.js",
    "preview": "npx serve dist",
    "clean": "rm -rf dist"
  }
}
```

## File Inventory

| File | Purpose |
|------|---------|
| `package.json` | Dependencies and scripts |
| `tailwind.config.js` | Tailwind content paths |
| `.gitignore` | Ignore node_modules/, dist/ |
| `build.js` | Markdown → HTML build script |
| `src/template.html` | Page shell (header, sidebar, content, footer) |
| `src/index.html` | Landing page partial |
| `src/styles.css` | Tailwind directives + custom CSS |
| `src/scripts.js` | Mobile nav, copy button |
| `src/gdscript.js` | Custom highlight.js GDScript grammar |
| `.github/workflows/deploy.yml` | GitHub Pages deployment |

**Total source files: 9** (plus PLAN.md).

## What This Does NOT Include

- Search functionality (could add later with lunr.js)
- Progress tracking / checkboxes
- Comments or community features
- User accounts
- Dark/light theme toggle (dark only — matches the game aesthetic)
- Analytics (can add later if needed)

## Reviewer Feedback Applied

| Feedback | Source | Resolution |
|----------|--------|------------|
| Tailwind CDN → CLI build | Both reviewers | Using `npx tailwindcss` CLI, produces static CSS, no runtime JS |
| GDScript → Python alias is wrong | Both reviewers | Custom ~50-line GDScript grammar in `src/gdscript.js` |
| Slug derivation unspecified | Adversarial | Explicit rule: `filename.replace(/_/g, '-').replace('.md', '')` |
| Blockquote classification unspecified | Adversarial | `marked` renderer override checking inner HTML for See:/Note: |
| Missing scripts.js in file list | Adversarial | Added to architecture, handles mobile nav + copy button |
| GitHub Pages deployment uncommitted | Both reviewers | Committed to GitHub Actions, added workflow file |
| Long sidebar titles (em-dash) | Adversarial | Short title extraction: after `Module N: `, before ` — ` |
| Missing .gitignore | Adversarial | Added, covers node_modules/ and dist/ |
| Missing `<title>` strategy | Adversarial | Per-page: `Module N: Short Title \| JRPG in Godot 4` |
| ASCII diagrams wrapping on mobile | Neutral | `white-space: pre` + `overflow-x: auto` on unfenced code |
| `<html lang>` and `<meta charset>` | Adversarial | Added to template.html spec |
| dist/ gitignore contradiction | Adversarial | Clarified: gitignored on main, Actions deploys directly |

## Implementation Order

1. `package.json` + `.gitignore` — initialize project
2. `tailwind.config.js` — configure content paths
3. `src/template.html` — base template with Tailwind classes
4. `src/styles.css` — Tailwind directives + custom styles
5. `src/scripts.js` — mobile nav + copy button
6. `src/gdscript.js` — custom highlight.js grammar
7. `build.js` — markdown processing and HTML generation
8. `src/index.html` — landing page
9. Build, test, verify all 21 modules render correctly
10. `.github/workflows/deploy.yml` — deployment workflow

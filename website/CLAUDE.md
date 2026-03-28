# Website: Tutorial Static Site

A static site that renders the 27 tutorial markdown files as a navigable, syntax-highlighted course. Deployed to GitHub Pages. No framework, no SPA, no runtime dependencies.

## Tech Stack

- **Node.js build script** (`build.js`) converts markdown to static HTML
- **marked** for markdown-to-HTML conversion with custom renderers
- **highlight.js** with a custom GDScript grammar (`src/gdscript.js`)
- **Tailwind CSS** compiled at build time (only used classes ship)
- **Vanilla JS** (`src/scripts.js`) for sidebar toggle, code copy, search, scroll-to-top

## Build

```bash
cd website
npm install        # First time only
npm run build      # Tailwind CSS compile + markdown-to-HTML
```

Output goes to `website/dist/` (gitignored on main, deployed via GitHub Actions).

## File Structure

```
website/
├── CLAUDE.md          # This file
├── PLAN.md            # Original design plan
├── package.json       # Dependencies: marked, highlight.js, tailwindcss
├── tailwind.config.js # Content paths for tree-shaking
├── build.js           # Build script: reads tutorial/*.md, outputs dist/*.html
├── src/
│   ├── template.html  # Base HTML template (head, sidebar, content slot, footer)
│   ├── index.html     # Landing page content (injected into template)
│   ├── styles.css     # Tailwind directives + custom prose/code/blockquote styles
│   ├── scripts.js     # Client-side: sidebar, copy buttons, search modal, TOC highlighting
│   └── gdscript.js    # Custom highlight.js grammar for GDScript syntax
├── public/            # Static assets copied to dist/ (favicon, etc.)
└── dist/              # Build output (gitignored)
```

## How the Build Works

`build.js` does the following:

1. Discovers all `tutorial/*.md` files matching `^\d{2}_*.md`
2. Registers a custom GDScript grammar with highlight.js
3. Configures marked with custom renderers for:
   - **Code blocks:** syntax highlighting + language label + copy button wrapper
   - **Blockquotes:** classified as `doc-reference` (blue) for `**See:**` links, `note` (amber) for `**Note:**`
   - **Headings:** auto-generates IDs, anchor links, and collects h2s for the TOC
   - **Tables:** wrapped in a responsive scroll container
   - **Links:** external links get `target="_blank"`
4. For each module, generates: content HTML, reading time, TOC, sidebar, prev/next nav
5. Builds a section-level full-text search index (`search-data.js`)
6. Generates the landing page, 404 page, and copies static assets

## Custom Markdown Features

The build script recognizes these patterns in tutorial markdown:

| Pattern | Rendered As |
|---------|-------------|
| `> **See:** [link]` | Blue-accented blockquote with doc icon |
| `> **Note:** text` | Amber-accented blockquote with lightbulb |
| `> **Spiral:** text` | Standard blockquote (callback to earlier module) |
| ` ```gdscript ` | Syntax-highlighted code block with "GDScript" label |
| Unfenced code blocks | Rendered as `.diagram` class (monospace, no highlighting) |
| `## Heading` | Gets an `id`, an anchor link (`#`), and appears in the TOC |

## Styling

All styles are in `src/styles.css` using Tailwind utilities. Key sections:

- `.prose` base styles for article content
- `.prose h2/.prose h3` heading styles with `.heading-anchor` positioned absolutely to the left
- `.code-block-wrapper` and `.copy-btn` for code block interaction
- Blockquote variants (`.doc-reference`, `.note`)
- `.table-wrapper` for responsive tables
- Sidebar, search modal, prev/next navigation, landing page cards

## Content Source

The website reads markdown from `tutorial/*.md`. See `tutorial/CLAUDE.md` for the tutorial's design principles, writing rules, and module structure. Any changes to tutorial markdown are reflected on the next build.

## Deployment

The site deploys to GitHub Pages via GitHub Actions. The `dist/` directory is the deployment artifact. Run `npm run build` locally to preview changes before pushing.

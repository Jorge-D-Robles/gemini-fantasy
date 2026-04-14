# godot-docs-md

Converted Godot 4.5 engine docs for ingestion into NotebookLM (or any other tool
that reads plain markdown). The source of truth is the `docs/godot-docs/` git
submodule; this folder holds generated output plus the `convert.py` script that
produces it.

## What's here

- `convert.py` — the converter (tracked in git)
- `*.md` — 75 grouped markdown files (generated; gitignored)
- `manifest.json` — maps each group file to its source `.rst` paths (generated; gitignored)

## How it works

1. Walks the sibling `../godot-docs/` submodule.
2. Groups the ~1580 RST files into ~75 topic bundles: intro/about, getting
   started (4 files), tutorials by section (28 files), engine details (6),
   and class reference chunked alphabetically in ≤50-class pieces (27).
3. Pre-processes each RST to strip Sphinx-only markup (`:ref:`, `:doc:`,
   `.. table::`, etc.) so pandoc produces cleaner markdown.
4. Pipes through `pandoc -f rst -t gfm --wrap=none --shift-heading-level-by=2`.
5. Concatenates each bundle into one `.md` with `## path/to/file.rst` dividers.

## Usage

```bash
# one-time setup
brew install pandoc

# full conversion (~80 s)
python3 convert.py --clean

# list groups without running
python3 convert.py --list

# regenerate one group
python3 convert.py --only 20-tutorials-physics
```

Flags:
- `--clean` — delete existing `*.md` + `manifest.json` before running
- `--only NAME` — convert only the named group (repeatable)
- `--source DIR` — path to the godot-docs checkout (defaults to `../godot-docs`)
- `--out DIR` — output directory (defaults to this folder)

## NotebookLM import

Free NotebookLM allows 50 sources; paid plans allow 300. All 75 files fit
comfortably in a paid notebook. For a free notebook, import a topic-specific
subset (e.g. just `20-tutorials-*` or `40-classes-*`). Each file is a coherent
topic, so you can start narrow and add files as needed.

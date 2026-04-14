#!/usr/bin/env python3
"""Convert the Godot docs RST tree into a small set of markdown files for NotebookLM.

Groups related .rst files into topic bundles, preprocesses Sphinx-only markup,
then runs pandoc to produce GitHub-flavored markdown. Output lands alongside
this script; one .md per group plus a manifest.json for traceability.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_SOURCE = (SCRIPT_DIR / ".." / "godot-docs").resolve()
DEFAULT_OUT = SCRIPT_DIR

CLASS_CHUNK_SIZE = 50


@dataclass
class Group:
	name: str
	title: str
	patterns: list[str] = field(default_factory=list)
	explicit_files: list[Path] = field(default_factory=list)


STATIC_GROUPS: list[Group] = [
	Group("00-intro", "Godot Docs — Intro & About", [
		"index.rst",
		"404.rst",
		"about/**/*.rst",
		"classes/index.rst",
		"tutorials/index.rst",
		"tutorials/troubleshooting.rst",
	]),
	Group("00-community", "Godot Docs — Community", [
		"community/**/*.rst",
	]),

	Group("10-getting-started-introduction", "Getting Started — Introduction", [
		"getting_started/introduction/**/*.rst",
	]),
	Group("10-getting-started-step-by-step", "Getting Started — Step by Step", [
		"getting_started/step_by_step/**/*.rst",
	]),
	Group("10-getting-started-first-2d-game", "Getting Started — Your First 2D Game", [
		"getting_started/first_2d_game/**/*.rst",
	]),
	Group("10-getting-started-first-3d-game", "Getting Started — Your First 3D Game", [
		"getting_started/first_3d_game/**/*.rst",
	]),

	Group("20-tutorials-2d", "Tutorials — 2D", ["tutorials/2d/**/*.rst"]),
	Group("20-tutorials-3d", "Tutorials — 3D", ["tutorials/3d/**/*.rst"]),
	Group("20-tutorials-animation", "Tutorials — Animation", ["tutorials/animation/**/*.rst"]),
	Group("20-tutorials-assets-pipeline", "Tutorials — Assets Pipeline", ["tutorials/assets_pipeline/**/*.rst"]),
	Group("20-tutorials-audio", "Tutorials — Audio", ["tutorials/audio/**/*.rst"]),
	Group("20-tutorials-best-practices", "Tutorials — Best Practices", ["tutorials/best_practices/**/*.rst"]),
	Group("20-tutorials-editor", "Tutorials — Editor", ["tutorials/editor/**/*.rst"]),
	Group("20-tutorials-export", "Tutorials — Export", ["tutorials/export/**/*.rst"]),
	Group("20-tutorials-i18n", "Tutorials — Internationalization", ["tutorials/i18n/**/*.rst"]),
	Group("20-tutorials-inputs", "Tutorials — Inputs", ["tutorials/inputs/**/*.rst"]),
	Group("20-tutorials-io", "Tutorials — I/O", ["tutorials/io/**/*.rst"]),
	Group("20-tutorials-math", "Tutorials — Math", ["tutorials/math/**/*.rst"]),
	Group("20-tutorials-migrating", "Tutorials — Migrating", ["tutorials/migrating/**/*.rst"]),
	Group("20-tutorials-navigation", "Tutorials — Navigation", ["tutorials/navigation/**/*.rst"]),
	Group("20-tutorials-networking", "Tutorials — Networking", ["tutorials/networking/**/*.rst"]),
	Group("20-tutorials-performance", "Tutorials — Performance", ["tutorials/performance/**/*.rst"]),
	Group("20-tutorials-physics", "Tutorials — Physics", ["tutorials/physics/**/*.rst"]),
	Group("20-tutorials-platform", "Tutorials — Platform", ["tutorials/platform/**/*.rst"]),
	Group("20-tutorials-plugins", "Tutorials — Plugins", ["tutorials/plugins/**/*.rst"]),
	Group("20-tutorials-rendering", "Tutorials — Rendering", ["tutorials/rendering/**/*.rst"]),
	Group("20-tutorials-shaders", "Tutorials — Shaders", ["tutorials/shaders/**/*.rst"]),
	Group("20-tutorials-ui", "Tutorials — UI", ["tutorials/ui/**/*.rst"]),
	Group("20-tutorials-xr", "Tutorials — XR", ["tutorials/xr/**/*.rst"]),

	Group("20-tutorials-scripting-core", "Tutorials — Scripting (Core)", [
		"tutorials/scripting/*.rst",
	]),
	Group("20-tutorials-scripting-gdscript", "Tutorials — Scripting (GDScript)", [
		"tutorials/scripting/gdscript/**/*.rst",
	]),
	Group("20-tutorials-scripting-csharp", "Tutorials — Scripting (C#)", [
		"tutorials/scripting/c_sharp/**/*.rst",
	]),
	Group("20-tutorials-scripting-cpp-gdext", "Tutorials — Scripting (C++ & GDExtension)", [
		"tutorials/scripting/cpp/**/*.rst",
		"tutorials/scripting/gdextension/**/*.rst",
	]),
	Group("20-tutorials-scripting-debug", "Tutorials — Scripting (Debug)", [
		"tutorials/scripting/debug/**/*.rst",
	]),

	Group("30-engine-architecture", "Engine Details — Architecture", ["engine_details/architecture/**/*.rst"]),
	Group("30-engine-class-reference", "Engine Details — Class Reference Meta", ["engine_details/class_reference/**/*.rst"]),
	Group("30-engine-development", "Engine Details — Development", ["engine_details/development/**/*.rst"]),
	Group("30-engine-editor", "Engine Details — Editor", ["engine_details/editor/**/*.rst"]),
	Group("30-engine-api", "Engine Details — Engine API", ["engine_details/engine_api/**/*.rst"]),
	Group("30-engine-file-formats", "Engine Details — File Formats", ["engine_details/file_formats/**/*.rst"]),
]


REF_WITH_LABEL_RE = re.compile(r":(?:ref|doc):`([^`<]+?)\s*<[^`>]+?>`")
REF_BARE_RE = re.compile(r":(?:ref|doc):`([^`]+?)`")
LABEL_ANCHOR_RE = re.compile(r"^\.\.\s+_[\w\-.]+:\s*$", re.MULTILINE)
RST_CLASS_RE = re.compile(r"^\.\.\s+rst-class::[^\n]*\n", re.MULTILINE)
ONLY_BLOCK_RE = re.compile(
	r"^\.\.\s+only::[^\n]*\n((?:[ \t]+[^\n]*\n|\s*\n)*)",
	re.MULTILINE,
)
IMAGE_RE = re.compile(r"^\.\.\s+image::\s+(\S+).*?(?=^\S|\Z)", re.MULTILINE | re.DOTALL)
FIGURE_RE = re.compile(r"^\.\.\s+figure::\s+(\S+).*?(?=^\S|\Z)", re.MULTILINE | re.DOTALL)
VIDEO_RE = re.compile(r"^\.\.\s+video::\s+(\S+).*?(?=^\S|\Z)", re.MULTILINE | re.DOTALL)
KBD_RE = re.compile(r":kbd:`([^`]+)`")
MENUSELECTION_RE = re.compile(r":menuselection:`([^`]+)`")
GUI_LABEL_RE = re.compile(r":guilabel:`([^`]+)`")
ABBR_RE = re.compile(r":abbr:`([^`<]+?)\s*\([^)]*\)`")
GITHUB_URL_RE = re.compile(r"^:github_url:[^\n]*\n", re.MULTILINE)
TABLE_DIRECTIVE_RE = re.compile(
	r"^(?P<indent>[ \t]*)\.\. (?:table|list-table|csv-table)::[^\n]*\n"
	r"(?:(?P=indent)[ \t]+[^\n]*\n|[ \t]*\n)*",
	re.MULTILINE,
)
SUBST_IMAGE_DEF_RE = re.compile(
	r"^\.\. \|([^|]+)\| image::\s*(\S+)[^\n]*\n(?:[ \t]+:[^\n]*\n)*",
	re.MULTILINE,
)
SUBST_REPLACE_DEF_RE = re.compile(
	r"^\.\. \|([^|]+)\| replace::\s*([^\n]*)\n",
	re.MULTILINE,
)
TABS_DIRECTIVE_RE = re.compile(r"^(?P<indent>[ \t]*)\.\. tabs::\s*$", re.MULTILINE)
CODE_TAB_RE = re.compile(r"^(?P<indent>[ \t]*)\.\. code-tab::\s+(?P<lang>\S+)(?:\s+.*)?\s*$")


_LANG_NORMALIZE = {
	"c++": "cpp",
	"c#": "csharp",
}


def _normalize_lang(lang: str) -> str:
	key = lang.strip().lower()
	return _LANG_NORMALIZE.get(key, key)


def transform_sphinx_tabs(text: str) -> str:
	"""Convert .. tabs:: / .. code-tab:: blocks into stacked .. code:: blocks."""
	lines = text.split("\n")
	out: list[str] = []
	i = 0
	while i < len(lines):
		line = lines[i]
		m = TABS_DIRECTIVE_RE.match(line)
		if not m:
			out.append(line)
			i += 1
			continue

		tabs_indent = len(m.group("indent"))
		i += 1

		# Collect the entire tabs block: lines indented deeper than the directive
		# (or blank). Stops at the first line that dedents back to/above tabs level.
		block: list[str] = []
		while i < len(lines):
			ln = lines[i]
			if not ln.strip():
				block.append(ln)
				i += 1
				continue
			ln_indent = len(ln) - len(ln.lstrip())
			if ln_indent <= tabs_indent:
				break
			block.append(ln)
			i += 1

		while block and not block[0].strip():
			block.pop(0)
		while block and not block[-1].strip():
			block.pop()

		sections: list[tuple[str, list[str]]] = []
		j = 0
		while j < len(block):
			ct = CODE_TAB_RE.match(block[j])
			if not ct:
				j += 1
				continue
			ct_indent = len(ct.group("indent"))
			lang = _normalize_lang(ct.group("lang"))
			j += 1
			while j < len(block) and not block[j].strip():
				j += 1
			code: list[str] = []
			while j < len(block):
				cln = block[j]
				if not cln.strip():
					code.append("")
					j += 1
					continue
				cln_indent = len(cln) - len(cln.lstrip())
				if cln_indent <= ct_indent:
					break
				code.append(cln)
				j += 1
			non_blank = [c for c in code if c.strip()]
			if non_blank:
				min_indent = min(len(c) - len(c.lstrip()) for c in non_blank)
				code = [c[min_indent:] if c.strip() else c for c in code]
			while code and not code[-1].strip():
				code.pop()
			sections.append((lang, code))

		pad = " " * tabs_indent
		for lang, code in sections:
			out.append(f"{pad}.. code:: {lang}")
			out.append("")
			for cl in code:
				out.append(f"{pad}    {cl}" if cl else "")
			out.append("")

	return "\n".join(out)


def extract_and_apply_substitutions(text: str) -> str:
	"""Inline `.. |name| image::` and `.. |name| replace::` defs then strip the defs."""
	image_defs: dict[str, str] = {}
	for m in SUBST_IMAGE_DEF_RE.finditer(text):
		image_defs[m.group(1).strip()] = m.group(2).strip()
	text = SUBST_IMAGE_DEF_RE.sub("", text)

	replace_defs: dict[str, str] = {}
	for m in SUBST_REPLACE_DEF_RE.finditer(text):
		replace_defs[m.group(1).strip()] = m.group(2).strip()
	text = SUBST_REPLACE_DEF_RE.sub("", text)

	def sub_ref(m: re.Match) -> str:
		name = m.group(1).strip()
		if name in image_defs:
			return f"[image: {image_defs[name]}]"
		if name in replace_defs:
			return replace_defs[name]
		return m.group(0)

	text = re.sub(r"\|([^|\s][^|]*?)\|", sub_ref, text)
	return text


def preprocess_rst(text: str) -> str:
	"""Strip Sphinx-only markup so pandoc produces cleaner markdown."""

	text = GITHUB_URL_RE.sub("", text)
	text = TABLE_DIRECTIVE_RE.sub("", text)
	text = extract_and_apply_substitutions(text)
	text = transform_sphinx_tabs(text)
	text = REF_WITH_LABEL_RE.sub(lambda m: m.group(1), text)
	text = REF_BARE_RE.sub(lambda m: _clean_ref_target(m.group(1)), text)
	text = LABEL_ANCHOR_RE.sub("", text)
	text = RST_CLASS_RE.sub("", text)
	text = ONLY_BLOCK_RE.sub("", text)
	text = IMAGE_RE.sub(lambda m: f"[image: {m.group(1)}]\n\n", text)
	text = FIGURE_RE.sub(lambda m: f"[figure: {m.group(1)}]\n\n", text)
	text = VIDEO_RE.sub(lambda m: f"[video: {m.group(1)}]\n\n", text)
	text = KBD_RE.sub(lambda m: m.group(1), text)
	text = MENUSELECTION_RE.sub(lambda m: m.group(1), text)
	text = GUI_LABEL_RE.sub(lambda m: m.group(1), text)
	text = ABBR_RE.sub(lambda m: m.group(1), text)
	return text


def _clean_ref_target(target: str) -> str:
	t = target.strip()
	for prefix in ("class_", "doc_", "enum_"):
		if t.startswith(prefix):
			t = t[len(prefix):]
			break
	return t.replace("_", " ")


def collect_group_files(group: Group, source: Path) -> list[Path]:
	seen: set[Path] = set()
	out: list[Path] = []
	for pattern in group.patterns:
		for p in sorted(source.glob(pattern)):
			if p.is_file() and p.suffix == ".rst" and p not in seen:
				seen.add(p)
				out.append(p)
	for p in group.explicit_files:
		if p not in seen and p.is_file():
			seen.add(p)
			out.append(p)
	return out


def build_class_groups(source: Path) -> list[Group]:
	class_dir = source / "classes"
	files = sorted(p for p in class_dir.glob("class_*.rst") if p.is_file())
	if not files:
		return []

	# Pull out @-prefixed globals (@GDScript, @GlobalScope) into their own group so
	# they don't get merged into an alphabetically-named chunk.
	globals_files = [f for f in files if f.stem.removeprefix("class_").startswith("@")]
	files = [f for f in files if f not in globals_files]

	# Bucket by first letter of the class name (after the "class_" prefix).
	letter_buckets: dict[str, list[Path]] = {}
	for f in files:
		name = f.stem.removeprefix("class_")
		letter = name[0].lower()
		letter_buckets.setdefault(letter, []).append(f)

	groups: list[Group] = []
	if globals_files:
		groups.append(Group(
			name="40-classes-globals",
			title="Class Reference — @GDScript & @GlobalScope",
			explicit_files=globals_files,
		))
	# Merge tiny trailing letters into a preceding bucket so we don't get
	# one-file groups. We also split oversized letters into part1/part2/…
	pending_merge: list[tuple[str, list[Path]]] = []
	ordered_letters = sorted(letter_buckets.keys())

	merged: list[tuple[str, list[Path]]] = []
	i = 0
	while i < len(ordered_letters):
		letter = ordered_letters[i]
		bucket = letter_buckets[letter]
		# Merge forward with neighbors while the combined size stays <= CLASS_CHUNK_SIZE
		# AND the next letter is "small" (< 20 files).
		combined_letters = letter
		combined_files = list(bucket)
		j = i + 1
		while j < len(ordered_letters):
			next_letter = ordered_letters[j]
			next_files = letter_buckets[next_letter]
			if len(combined_files) + len(next_files) <= CLASS_CHUNK_SIZE and len(next_files) < 20:
				combined_letters += next_letter
				combined_files.extend(next_files)
				j += 1
			else:
				break
		merged.append((combined_letters, combined_files))
		i = j if j > i else i + 1

	for letters, bucket in merged:
		if len(bucket) <= CLASS_CHUNK_SIZE:
			groups.append(Group(
				name=f"40-classes-{letters}",
				title=f"Class Reference — {letters.upper()}",
				explicit_files=bucket,
			))
			continue
		# Split oversized bucket into parts of ~CLASS_CHUNK_SIZE.
		parts = (len(bucket) + CLASS_CHUNK_SIZE - 1) // CLASS_CHUNK_SIZE
		per = (len(bucket) + parts - 1) // parts
		for idx in range(parts):
			chunk = bucket[idx * per : (idx + 1) * per]
			if not chunk:
				continue
			groups.append(Group(
				name=f"40-classes-{letters}-part{idx + 1}",
				title=f"Class Reference — {letters.upper()} (part {idx + 1} of {parts})",
				explicit_files=chunk,
			))
	return groups


def run_pandoc(rst_text: str) -> str:
	result = subprocess.run(
		[
			"pandoc",
			"-f", "rst",
			"-t", "gfm",
			"--wrap=none",
			"--shift-heading-level-by=2",
		],
		input=rst_text,
		text=True,
		capture_output=True,
		check=False,
	)
	if result.returncode != 0:
		raise RuntimeError(f"pandoc failed: {result.stderr.strip()}")
	return result.stdout


def pandoc_version() -> str:
	try:
		out = subprocess.check_output(["pandoc", "--version"], text=True)
		return out.splitlines()[0].strip()
	except Exception:
		return "unknown"


def ensure_pandoc() -> None:
	if shutil.which("pandoc") is None:
		print(
			"error: pandoc is not installed or not on PATH.\n"
			"       install it with: brew install pandoc",
			file=sys.stderr,
		)
		sys.exit(1)


def convert_group(group: Group, source: Path, out_dir: Path) -> tuple[int, list[str]]:
	files = group.explicit_files or collect_group_files(group, source)
	if not files:
		return 0, []

	chunks: list[str] = [f"# {group.title}\n"]
	source_paths: list[str] = []
	for f in files:
		rel = f.relative_to(source).as_posix()
		source_paths.append(rel)
		try:
			raw = f.read_text(encoding="utf-8")
		except UnicodeDecodeError:
			raw = f.read_text(encoding="utf-8", errors="replace")
		cleaned = preprocess_rst(raw)
		try:
			md = run_pandoc(cleaned)
		except RuntimeError as exc:
			print(f"  ! pandoc error on {rel}: {exc}", file=sys.stderr)
			md = f"_pandoc failed to convert this file._\n\n```\n{cleaned[:2000]}\n```\n"
		chunks.append(f"\n\n## `{rel}`\n\n{md.strip()}\n")

	out_path = out_dir / f"{group.name}.md"
	out_path.write_text("".join(chunks), encoding="utf-8")
	return len(files), source_paths


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help="path to godot-docs checkout")
	parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help="output directory")
	parser.add_argument("--only", action="append", default=[], help="only convert these group names (repeatable)")
	parser.add_argument("--clean", action="store_true", help="delete existing *.md in out dir first")
	parser.add_argument("--list", action="store_true", help="list group names and exit")
	args = parser.parse_args()

	ensure_pandoc()

	source: Path = args.source.resolve()
	out_dir: Path = args.out.resolve()
	if not source.is_dir():
		print(f"error: source dir not found: {source}", file=sys.stderr)
		return 1
	out_dir.mkdir(parents=True, exist_ok=True)

	groups = list(STATIC_GROUPS) + build_class_groups(source)

	if args.list:
		for g in groups:
			files = g.explicit_files or collect_group_files(g, source)
			print(f"{g.name:48s}  {len(files):4d} files")
		return 0

	selected = groups
	if args.only:
		wanted = set(args.only)
		selected = [g for g in groups if g.name in wanted]
		missing = wanted - {g.name for g in selected}
		if missing:
			print(f"warning: unknown group(s): {', '.join(sorted(missing))}", file=sys.stderr)
		if not selected:
			return 1

	if args.clean:
		for md in out_dir.glob("*.md"):
			md.unlink()
		manifest = out_dir / "manifest.json"
		if manifest.exists():
			manifest.unlink()

	start = time.monotonic()
	total_files = 0
	written_groups = 0
	manifest_groups: list[dict] = []

	for group in selected:
		count, sources = convert_group(group, source, out_dir)
		if count == 0:
			print(f"  . {group.name}: no files matched (skipped)")
			continue
		total_files += count
		written_groups += 1
		print(f"  + {group.name}: {count} files")
		manifest_groups.append({
			"name": group.name,
			"file": f"{group.name}.md",
			"title": group.title,
			"sources": sources,
		})

	manifest = {
		"generated_at": datetime.now(timezone.utc).isoformat(),
		"source_dir": str(source),
		"pandoc": pandoc_version(),
		"groups": manifest_groups,
	}
	(out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

	elapsed = time.monotonic() - start
	print()
	print(f"converted {total_files} rst files → {written_groups} markdown files in {elapsed:.1f}s")
	print(f"output: {out_dir}")
	return 0


if __name__ == "__main__":
	sys.exit(main())

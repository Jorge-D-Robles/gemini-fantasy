#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { marked } = require("marked");
const hljs = require("highlight.js");
const gdscriptGrammar = require("./src/gdscript");

// ─── Config ────────────────────────────────────────────

const TUTORIAL_DIR = path.join(__dirname, "..", "tutorial");
const SRC_DIR = path.join(__dirname, "src");
const DIST_DIR = path.join(__dirname, "dist");
const PUBLIC_DIR = path.join(__dirname, "public");

const PART_GROUPINGS = [
  { name: "Part I: Welcome to Godot", range: [1, 3] },
  { name: "Part II: Building the World", range: [4, 6] },
  { name: "Part III: Data and Dialogue", range: [7, 10] },
  { name: "Part IV: Combat", range: [11, 15] },
  { name: "Part V: Systems", range: [16, 18] },
  { name: "Part VI: Polish", range: [19, 21] },
];

// ─── Register GDScript grammar ─────────────────────────

hljs.registerLanguage("gdscript", gdscriptGrammar);
hljs.registerLanguage("gd", gdscriptGrammar);

// ─── Markdown setup ────────────────────────────────────

const renderer = new marked.Renderer();

// Blockquote classification — detect See:/Note: prefixes
renderer.blockquote = function ({ tokens }) {
  var body = this.parser.parse(tokens);
  if (body.includes("<strong>See:</strong>")) {
    return '<blockquote class="doc-reference">' + body + "</blockquote>\n";
  }
  if (body.includes("<strong>Note:</strong>")) {
    return '<blockquote class="note">' + body + "</blockquote>\n";
  }
  return "<blockquote>" + body + "</blockquote>\n";
};

// Table wrapper for responsive horizontal scroll
renderer.table = function (token) {
  var header = this.tablerow(token.header);
  var body = token.rows.map((row) => this.tablerow(row)).join("");
  return (
    '<div class="table-wrapper"><table>' +
    "<thead>" +
    header +
    "</thead>" +
    "<tbody>" +
    body +
    "</tbody>" +
    "</table></div>\n"
  );
};

renderer.tablerow = function (cells) {
  var content = cells.map((cell) => this.tablecell(cell)).join("");
  return "<tr>" + content + "</tr>\n";
};

renderer.tablecell = function (token) {
  var tag = token.header ? "th" : "td";
  var body = this.parser.parseInline(token.tokens);
  return "<" + tag + ">" + body + "</" + tag + ">";
};

// Code blocks — syntax highlighting + data-lang attribute
renderer.code = function ({ text, lang }) {
  var language = lang || "";
  var langLabel = language;
  var highlighted;

  if (language === "gdscript" || language === "gd") {
    langLabel = "GDScript";
    try {
      highlighted = hljs.highlight(text, { language: "gdscript" }).value;
    } catch (_e) {
      highlighted = escapeHtml(text);
    }
  } else if (language === "json") {
    langLabel = "JSON";
    try {
      highlighted = hljs.highlight(text, { language: "json" }).value;
    } catch (_e) {
      highlighted = escapeHtml(text);
    }
  } else if (language && hljs.getLanguage(language)) {
    langLabel = language;
    try {
      highlighted = hljs.highlight(text, { language: language }).value;
    } catch (_e) {
      highlighted = escapeHtml(text);
    }
  } else {
    // No language or unknown — treat as diagram/plain text
    highlighted = escapeHtml(text);
    var cls = language ? "" : ' class="diagram"';
    return (
      "<pre" + cls + "><code>" + highlighted + "</code></pre>\n"
    );
  }

  return (
    '<pre data-lang="' +
    escapeHtml(langLabel) +
    '"><code class="hljs language-' +
    escapeHtml(language) +
    '">' +
    highlighted +
    "</code></pre>\n"
  );
};

// External links open in new tab
var originalLink = renderer.link.bind(renderer);
renderer.link = function (token) {
  if (token.href && token.href.startsWith("http")) {
    var text = this.parser.parseInline(token.tokens);
    return (
      '<a href="' +
      escapeHtml(token.href) +
      '" target="_blank" rel="noopener">' +
      text +
      "</a>"
    );
  }
  return originalLink(token);
};

marked.setOptions({
  renderer: renderer,
  gfm: true,
  breaks: false,
});

// ─── Helpers ───────────────────────────────────────────

function escapeHtml(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function slugFromFilename(filename) {
  return path.basename(filename, ".md").replace(/_/g, "-");
}

function extractTitle(markdown) {
  var match = markdown.match(/^# (.+)$/m);
  return match ? match[1] : null;
}

function shortTitle(fullTitle) {
  if (!fullTitle) return "";
  // Remove "Module N: " prefix
  var withoutPrefix = fullTitle.replace(/^Module \d+:\s*/, "");
  // Remove " — subtitle" suffix
  var beforeDash = withoutPrefix.split(" — ")[0];
  return beforeDash.trim();
}

function moduleNumber(filename) {
  var match = path.basename(filename).match(/^(\d+)/);
  return match ? parseInt(match[1], 10) : 0;
}

function getPartForModule(num) {
  for (var part of PART_GROUPINGS) {
    if (num >= part.range[0] && num <= part.range[1]) {
      return part;
    }
  }
  return null;
}

// ─── Discover tutorial files ───────────────────────────

function getTutorialFiles() {
  var files = fs.readdirSync(TUTORIAL_DIR).filter(function (f) {
    return f.match(/^\d{2}_/) && f.endsWith(".md");
  });
  files.sort();
  return files.map(function (f) {
    var filepath = path.join(TUTORIAL_DIR, f);
    var content = fs.readFileSync(filepath, "utf-8");
    var num = moduleNumber(f);
    var full = extractTitle(content);
    return {
      filename: f,
      filepath: filepath,
      slug: slugFromFilename(f),
      moduleNum: num,
      fullTitle: full || slugFromFilename(f),
      shortTitle: shortTitle(full),
      markdown: content,
    };
  });
}

// ─── Generate sidebar HTML ─────────────────────────────

function generateSidebar(modules, activeSlug) {
  var html = "";

  // Find which part the active module belongs to
  var activeModule = modules.find(function (m) { return m.slug === activeSlug; });
  var activePart = activeModule ? getPartForModule(activeModule.moduleNum) : null;

  for (var part of PART_GROUPINGS) {
    var partModules = modules.filter(function (m) {
      return m.moduleNum >= part.range[0] && m.moduleNum <= part.range[1];
    });

    var isActivePart = activePart && part.name === activePart.name;
    // On landing page (no activeSlug), open all parts
    var openAttr = (!activeSlug || isActivePart) ? " open" : "";

    html += '<details class="sidebar-part"' + openAttr + '>\n';
    html += "  <summary>" + escapeHtml(part.name) + "</summary>\n";
    html += '  <div class="pl-1 pb-2">\n';

    for (var mod of partModules) {
      var isActive = mod.slug === activeSlug;
      var cls = "sidebar-link" + (isActive ? " active" : "");
      html +=
        '    <a href="' +
        mod.slug +
        '.html" class="' +
        cls +
        '">' +
        '<span class="text-slate-600 font-mono text-xs mr-2">' +
        String(mod.moduleNum).padStart(2, "0") +
        "</span>" +
        escapeHtml(mod.shortTitle) +
        "</a>\n";
    }

    html += "  </div>\n";
    html += "</details>\n";
  }

  return html;
}

// ─── Generate prev/next navigation ─────────────────────

function generatePrevNext(modules, currentIndex) {
  var prev = currentIndex > 0 ? modules[currentIndex - 1] : null;
  var next = currentIndex < modules.length - 1 ? modules[currentIndex + 1] : null;

  var html = '<nav class="prev-next" aria-label="Module navigation">\n';

  if (prev) {
    html +=
      '  <a href="' +
      prev.slug +
      '.html">\n' +
      '    <div class="label">← Previous</div>\n' +
      '    <div class="title">Module ' +
      prev.moduleNum +
      ": " +
      escapeHtml(prev.shortTitle) +
      "</div>\n" +
      "  </a>\n";
  } else {
    html += '  <div class="flex-1"></div>\n';
  }

  if (next) {
    html +=
      '  <a href="' +
      next.slug +
      '.html" class="sm:text-right">\n' +
      '    <div class="label">Next →</div>\n' +
      '    <div class="title">Module ' +
      next.moduleNum +
      ": " +
      escapeHtml(next.shortTitle) +
      "</div>\n" +
      "  </a>\n";
  } else {
    html += '  <div class="flex-1"></div>\n';
  }

  html += "</nav>\n";
  return html;
}

// ─── Generate module list for landing page ─────────────

function generateModuleList(modules) {
  var html = "";

  for (var part of PART_GROUPINGS) {
    var partModules = modules.filter(function (m) {
      return m.moduleNum >= part.range[0] && m.moduleNum <= part.range[1];
    });

    html +=
      '<h3 class="text-sm font-semibold uppercase tracking-wider text-slate-500 mt-8 mb-3">' +
      escapeHtml(part.name) +
      "</h3>\n";
    html += '<div class="space-y-2">\n';

    for (var mod of partModules) {
      html +=
        '  <a href="' +
        mod.slug +
        '.html" class="module-card">\n' +
        '    <span class="module-num">Module ' +
        mod.moduleNum +
        "</span>\n" +
        '    <span class="module-title ml-2">' +
        escapeHtml(mod.shortTitle) +
        "</span>\n" +
        "  </a>\n";
    }

    html += "</div>\n";
  }

  return html;
}

// ─── Build ─────────────────────────────────────────────

function build() {
  console.log("Building tutorial site...\n");

  // Ensure dist exists
  fs.mkdirSync(DIST_DIR, { recursive: true });

  // Read template
  var template = fs.readFileSync(
    path.join(SRC_DIR, "template.html"),
    "utf-8"
  );

  // Discover modules
  var modules = getTutorialFiles();
  console.log("Found " + modules.length + " tutorial modules.\n");

  // Build each module page
  for (var i = 0; i < modules.length; i++) {
    var mod = modules[i];
    var contentHtml = marked.parse(mod.markdown);
    var sidebar = generateSidebar(modules, mod.slug);
    var prevNext = generatePrevNext(modules, i);

    var pageTitle =
      "Module " + mod.moduleNum + ": " + mod.shortTitle + " | JRPG in Godot 4";
    var pageDesc =
      "Learn to build JRPG systems in Godot 4 — Module " +
      mod.moduleNum +
      ": " +
      mod.shortTitle;

    var page = template
      .replace("{{PAGE_TITLE}}", escapeHtml(pageTitle))
      .replace("{{PAGE_DESCRIPTION}}", escapeHtml(pageDesc))
      .replace("{{SIDEBAR}}", sidebar)
      .replace("{{CONTENT}}", contentHtml)
      .replace("{{PREV_NEXT}}", prevNext);

    var outPath = path.join(DIST_DIR, mod.slug + ".html");
    fs.writeFileSync(outPath, page);
    console.log(
      "  ✓ " + mod.slug + ".html — Module " + mod.moduleNum + ": " + mod.shortTitle
    );
  }

  // Build landing page
  var indexSrc = fs.readFileSync(path.join(SRC_DIR, "index.html"), "utf-8");
  var moduleList = generateModuleList(modules);
  var indexContent = indexSrc.replace("{{MODULE_LIST}}", moduleList);
  var indexSidebar = generateSidebar(modules, "");

  var indexPage = template
    .replace("{{PAGE_TITLE}}", "JRPG in Godot 4 — Complete Tutorial Series")
    .replace(
      "{{PAGE_DESCRIPTION}}",
      "A complete, from-scratch tutorial on building a turn-based JRPG in Godot 4. 21 modules covering every major system."
    )
    .replace("{{SIDEBAR}}", indexSidebar)
    .replace("{{CONTENT}}", indexContent)
    .replace("{{PREV_NEXT}}", "");

  fs.writeFileSync(path.join(DIST_DIR, "index.html"), indexPage);
  console.log("  ✓ index.html — Landing page\n");

  // Copy scripts.js
  fs.copyFileSync(
    path.join(SRC_DIR, "scripts.js"),
    path.join(DIST_DIR, "scripts.js")
  );
  console.log("  ✓ scripts.js copied");

  // Copy public assets
  if (fs.existsSync(PUBLIC_DIR)) {
    var publicFiles = fs.readdirSync(PUBLIC_DIR);
    for (var f of publicFiles) {
      fs.copyFileSync(
        path.join(PUBLIC_DIR, f),
        path.join(DIST_DIR, f)
      );
      console.log("  ✓ " + f + " copied");
    }
  }

  // Build 404 page
  var notFoundContent =
    '<div class="text-center py-16">\n' +
    '  <h1 class="text-6xl font-bold text-slate-600 mb-4">404</h1>\n' +
    '  <p class="text-xl text-slate-400 mb-6">This page doesn\'t exist.</p>\n' +
    '  <a href="index.html" class="inline-flex items-center gap-2 px-5 py-2.5 bg-sky-500 hover:bg-sky-400 text-white font-semibold rounded-lg transition-colors no-underline">\n' +
    '    Back to Tutorial\n' +
    '  </a>\n' +
    '</div>\n';

  var notFoundSidebar = generateSidebar(modules, "");
  var notFoundPage = template
    .replace("{{PAGE_TITLE}}", "Page Not Found | JRPG in Godot 4")
    .replace("{{PAGE_DESCRIPTION}}", "The page you're looking for doesn't exist.")
    .replace("{{SIDEBAR}}", notFoundSidebar)
    .replace("{{CONTENT}}", notFoundContent)
    .replace("{{PREV_NEXT}}", "");

  fs.writeFileSync(path.join(DIST_DIR, "404.html"), notFoundPage);
  console.log("  ✓ 404.html — Not found page\n");

  console.log(
    "\nBuild complete! " + (modules.length + 2) + " pages generated in dist/\n"
  );
}

build();

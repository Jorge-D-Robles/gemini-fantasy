// Restore sidebar scroll position across page navigations
(function () {
  var sidebar = document.getElementById("sidebar");
  if (!sidebar) return;

  var saved = sessionStorage.getItem("sidebar-scroll");
  if (saved) sidebar.scrollTop = parseInt(saved, 10);

  window.addEventListener("beforeunload", function () {
    sessionStorage.setItem("sidebar-scroll", sidebar.scrollTop);
  });
})();

// Mobile navigation toggle
(function () {
  var toggle = document.getElementById("menu-toggle");
  var sidebar = document.getElementById("sidebar");
  var overlay = document.getElementById("sidebar-overlay");

  if (!toggle || !sidebar || !overlay) return;

  function openMenu() {
    sidebar.classList.remove("-translate-x-full");
    overlay.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  function closeMenu() {
    sidebar.classList.add("-translate-x-full");
    overlay.classList.add("hidden");
    document.body.style.overflow = "";
  }

  toggle.addEventListener("click", function () {
    var isOpen = !sidebar.classList.contains("-translate-x-full");
    if (isOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  });

  overlay.addEventListener("click", closeMenu);
})();

// Scroll to top button
(function () {
  var btn = document.getElementById("scroll-top");
  if (!btn) return;

  window.addEventListener("scroll", function () {
    if (window.scrollY > 400) {
      btn.classList.add("visible");
    } else {
      btn.classList.remove("visible");
    }
  });

  btn.addEventListener("click", function () {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });
})();

// TOC scroll spy — highlight active section in "On This Page" nav
(function () {
  var tocLinks = document.querySelectorAll(".toc-link");
  if (tocLinks.length === 0) return;

  var headings = [];
  tocLinks.forEach(function (link) {
    var id = link.getAttribute("href").slice(1);
    var el = document.getElementById(id);
    if (el) headings.push({ el: el, link: link });
  });

  var current = null;

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          if (current) current.classList.remove("active");
          var match = headings.find(function (h) { return h.el === entry.target; });
          if (match) {
            match.link.classList.add("active");
            current = match.link;
          }
        }
      });
    },
    { rootMargin: "0px 0px -70% 0px", threshold: 0 }
  );

  headings.forEach(function (h) { observer.observe(h.el); });
})();

// Code block copy buttons
(function () {
  var blocks = document.querySelectorAll("pre");

  blocks.forEach(function (pre) {
    var wrapper = document.createElement("div");
    wrapper.className = "code-block-wrapper";
    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(pre);

    var btn = document.createElement("button");
    btn.className = "copy-btn";
    btn.textContent = "Copy";
    btn.setAttribute("aria-label", "Copy code to clipboard");
    wrapper.appendChild(btn);

    btn.addEventListener("click", function () {
      var code = pre.querySelector("code");
      var text = code ? code.textContent : pre.textContent;

      navigator.clipboard.writeText(text).then(function () {
        btn.textContent = "Copied!";
        btn.classList.add("copied");
        setTimeout(function () {
          btn.textContent = "Copy";
          btn.classList.remove("copied");
        }, 2000);
      });
    });
  });
})();

// Search modal — full-text search across all tutorial sections
(function () {
  var modal = document.getElementById("search-modal");
  var input = document.getElementById("search-input");
  var results = document.getElementById("search-results");
  var trigger = document.getElementById("search-trigger");
  var data = window.__SEARCH_DATA__ || [];

  if (!modal || !input || !results) return;

  // Build unique module list for empty-query display
  var modules = [];
  var seen = {};
  data.forEach(function (entry) {
    if (!seen[entry.m]) {
      seen[entry.m] = true;
      modules.push({ num: entry.m, title: entry.t, slug: entry.s });
    }
  });

  var activeIndex = -1;
  var resultEls = [];
  var resultData = [];

  function esc(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }

  function open() {
    modal.classList.remove("hidden");
    input.value = "";
    activeIndex = -1;
    renderModules();
    setTimeout(function () { input.focus(); }, 50);
    document.body.style.overflow = "hidden";
  }

  function close() {
    modal.classList.add("hidden");
    document.body.style.overflow = "";
  }

  function navigate(url) {
    window.location.href = url;
  }

  // Render module list when query is empty
  function renderModules() {
    resultEls = [];
    resultData = [];
    results.innerHTML = "";
    modules.forEach(function (m, i) {
      var url = m.slug + ".html";
      var a = document.createElement("a");
      a.href = url;
      a.className = "search-result" + (i === activeIndex ? " active" : "");
      a.innerHTML =
        '<span class="search-result-num">' + String(m.num).padStart(2, "0") + "</span>" +
        '<span class="search-result-title">' + esc(m.title) + "</span>";
      a.addEventListener("mouseenter", function () { activeIndex = i; updateActive(); });
      a.addEventListener("click", function (e) { e.preventDefault(); navigate(url); });
      resultEls.push(a);
      resultData.push({ url: url });
      results.appendChild(a);
    });
  }

  // Extract a context snippet around the match
  function snippet(text, query, matchIndex) {
    var pad = 40;
    var start = Math.max(0, matchIndex - pad);
    var end = Math.min(text.length, matchIndex + query.length + pad);
    var s = "";
    if (start > 0) s += "\u2026";
    s += text.slice(start, end);
    if (end < text.length) s += "\u2026";
    return highlight(s, query);
  }

  // Highlight first occurrence of query in text
  function highlight(text, query) {
    var lower = text.toLowerCase();
    var idx = lower.indexOf(query);
    if (idx < 0) return esc(text);
    return esc(text.slice(0, idx)) +
      "<mark>" + esc(text.slice(idx, idx + query.length)) + "</mark>" +
      esc(text.slice(idx + query.length));
  }

  // Full-text search
  function search(query) {
    if (!query) { renderModules(); return; }
    var q = query.toLowerCase();
    var matches = [];

    data.forEach(function (entry) {
      var hIdx = entry.h.toLowerCase().indexOf(q);
      var xIdx = entry.x.toLowerCase().indexOf(q);
      if (hIdx < 0 && xIdx < 0) return;

      var score = 0;
      var snip = "";
      if (hIdx >= 0) {
        score = 10;
        snip = highlight(entry.h, q);
      }
      if (xIdx >= 0) {
        if (hIdx < 0) score = 1;
        snip = snippet(entry.x, q, xIdx);
      }

      matches.push({
        m: entry.m, t: entry.t, s: entry.s,
        h: entry.h, a: entry.a,
        url: entry.s + ".html" + (entry.a ? "#" + entry.a : ""),
        snip: snip, score: score,
      });
    });

    matches.sort(function (a, b) {
      if (b.score !== a.score) return b.score - a.score;
      return a.m - b.m;
    });
    matches = matches.slice(0, 50);
    renderSections(matches, q);
  }

  function renderSections(matches, query) {
    resultEls = [];
    resultData = [];
    results.innerHTML = "";

    if (matches.length === 0) {
      var empty = document.createElement("div");
      empty.className = "search-empty";
      empty.textContent = "No results for \u201c" + query + "\u201d";
      results.appendChild(empty);
      return;
    }

    var lastMod = -1;
    matches.forEach(function (match, i) {
      if (match.m !== lastMod) {
        var header = document.createElement("div");
        header.className = "search-module-header";
        header.textContent = "Module " + String(match.m).padStart(2, "0") + ": " + match.t;
        results.appendChild(header);
        lastMod = match.m;
      }

      var a = document.createElement("a");
      a.href = match.url;
      a.className = "search-section-result" + (i === activeIndex ? " active" : "");
      a.innerHTML =
        '<span class="search-section-heading">' + esc(match.h) + "</span>" +
        '<span class="search-section-snippet">' + match.snip + "</span>";
      a.addEventListener("mouseenter", function () { activeIndex = i; updateActive(); });
      a.addEventListener("click", function (e) { e.preventDefault(); navigate(match.url); });
      resultEls.push(a);
      resultData.push({ url: match.url });
      results.appendChild(a);
    });

    activeIndex = 0;
    updateActive();
  }

  function updateActive() {
    resultEls.forEach(function (el, i) {
      if (i === activeIndex) {
        el.classList.add("active");
        el.scrollIntoView({ block: "nearest" });
      } else {
        el.classList.remove("active");
      }
    });
  }

  input.addEventListener("input", function () {
    search(input.value.trim());
  });

  input.addEventListener("keydown", function (e) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      activeIndex = Math.min(activeIndex + 1, resultEls.length - 1);
      updateActive();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      activeIndex = Math.max(activeIndex - 1, 0);
      updateActive();
    } else if (e.key === "Enter" && activeIndex >= 0 && resultData[activeIndex]) {
      e.preventDefault();
      navigate(resultData[activeIndex].url);
    } else if (e.key === "Escape") {
      close();
    }
  });

  modal.querySelector(".search-backdrop").addEventListener("click", close);

  if (trigger) {
    trigger.addEventListener("click", open);
  }

  document.addEventListener("keydown", function (e) {
    if ((e.metaKey || e.ctrlKey) && e.key === "k") {
      e.preventDefault();
      if (modal.classList.contains("hidden")) { open(); } else { close(); }
    }
  });
})();

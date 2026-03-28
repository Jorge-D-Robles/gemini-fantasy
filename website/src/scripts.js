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

// Search modal — Cmd+K / Ctrl+K to open, filter modules by title
(function () {
  var modal = document.getElementById("search-modal");
  var input = document.getElementById("search-input");
  var results = document.getElementById("search-results");
  var trigger = document.getElementById("search-trigger");
  var data = window.__SEARCH_DATA__ || [];

  if (!modal || !input || !results) return;

  var activeIndex = -1;

  function open() {
    modal.classList.remove("hidden");
    input.value = "";
    activeIndex = -1;
    render(data);
    // Delay focus slightly so the modal is visible
    setTimeout(function () { input.focus(); }, 50);
    document.body.style.overflow = "hidden";
  }

  function close() {
    modal.classList.add("hidden");
    document.body.style.overflow = "";
  }

  function navigate(slug) {
    window.location.href = slug + ".html";
  }

  function render(items) {
    results.innerHTML = "";
    items.forEach(function (item, i) {
      var a = document.createElement("a");
      a.href = item.slug + ".html";
      a.className = "search-result" + (i === activeIndex ? " active" : "");
      a.innerHTML =
        '<span class="search-result-num">' + String(item.num).padStart(2, "0") + "</span>" +
        '<span class="search-result-title">' + item.title + "</span>";
      a.addEventListener("mouseenter", function () {
        activeIndex = i;
        updateActive(items);
      });
      a.addEventListener("click", function (e) {
        e.preventDefault();
        navigate(item.slug);
      });
      results.appendChild(a);
    });
  }

  function updateActive(items) {
    var links = results.querySelectorAll(".search-result");
    links.forEach(function (link, i) {
      if (i === activeIndex) {
        link.classList.add("active");
        link.scrollIntoView({ block: "nearest" });
      } else {
        link.classList.remove("active");
      }
    });
  }

  function filter(query) {
    if (!query) return data;
    var q = query.toLowerCase();
    return data.filter(function (item) {
      return item.title.toLowerCase().includes(q) ||
        item.full.toLowerCase().includes(q) ||
        String(item.num) === q;
    });
  }

  input.addEventListener("input", function () {
    var filtered = filter(input.value);
    activeIndex = filtered.length > 0 ? 0 : -1;
    render(filtered);
  });

  input.addEventListener("keydown", function (e) {
    var filtered = filter(input.value);
    if (e.key === "ArrowDown") {
      e.preventDefault();
      activeIndex = Math.min(activeIndex + 1, filtered.length - 1);
      updateActive(filtered);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      activeIndex = Math.max(activeIndex - 1, 0);
      updateActive(filtered);
    } else if (e.key === "Enter" && activeIndex >= 0 && filtered[activeIndex]) {
      e.preventDefault();
      navigate(filtered[activeIndex].slug);
    } else if (e.key === "Escape") {
      close();
    }
  });

  // Backdrop click closes
  modal.querySelector(".search-backdrop").addEventListener("click", close);

  // Trigger button
  if (trigger) {
    trigger.addEventListener("click", open);
  }

  // Cmd+K / Ctrl+K
  document.addEventListener("keydown", function (e) {
    if ((e.metaKey || e.ctrlKey) && e.key === "k") {
      e.preventDefault();
      if (modal.classList.contains("hidden")) {
        open();
      } else {
        close();
      }
    }
  });
})();

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

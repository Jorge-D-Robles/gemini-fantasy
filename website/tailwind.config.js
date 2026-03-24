/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/template.html",
    "./src/index.html",
    "./build.js",
  ],
  theme: {
    extend: {
      colors: {
        crystal: {
          400: "#38bdf8",
          500: "#0ea5e9",
          600: "#0284c7",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "Fira Code", "monospace"],
      },
    },
  },
  plugins: [],
};

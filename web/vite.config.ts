import { defineConfig } from "vite";

// The built site goes to /docs, which is what GitHub Pages serves. Relative paths, so it works
// there (in a subfolder) and when a node serves it.
export default defineConfig({
  base: "./",
  build: { target: "es2022", outDir: "../docs", emptyOutDir: true },
});

import { defineConfig } from "vite";

// Relative paths, so the built site works when the node serves it and when it's hosted in a subfolder.
export default defineConfig({ base: "./", build: { target: "es2022" } });

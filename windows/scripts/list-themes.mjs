import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const themesDir = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, "themes");

try {
  const entries = await fs.readdir(themesDir, { withFileTypes: true });
  console.log(JSON.stringify({ themesDir, themes: entries.filter((entry) => entry.isDirectory()).map((entry) => entry.name).sort() }, null, 2));
} catch (error) {
  console.error(JSON.stringify({ themesDir, error: error.message }, null, 2));
  process.exitCode = 1;
}

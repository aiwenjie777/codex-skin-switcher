import fs from "node:fs/promises";
import path from "node:path";

const [command, skinDirArg, ...args] = process.argv.slice(2);
const DISALLOWED_EXTENSIONS = new Set([".app", ".asar", ".bat", ".cmd", ".cjs", ".command", ".dll", ".dylib", ".exe", ".js", ".mjs", ".node", ".ps1", ".sh", ".so"]);
const imageExtensions = new Set([".png", ".jpg", ".jpeg", ".webp"]);

function valueFor(name) {
  const index = args.indexOf(`--${name}`);
  const value = index < 0 ? "" : args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`Missing value for --${name}`);
  return value;
}
function text(value, label, max = 120) {
  if (typeof value !== "string" || !value.trim()) throw new Error(`${label} is required`);
  return value.trim().slice(0, max);
}
function relativeFile(root, value, label) {
  const input = text(value, label, 240);
  if (path.isAbsolute(input) || input.includes("\0")) throw new Error(`${label} must be a relative file path`);
  const resolved = path.resolve(root, input);
  const relative = path.relative(root, resolved);
  if (!relative || relative.startsWith("..") || path.isAbsolute(relative)) throw new Error(`${label} must stay inside the skin package`);
  return resolved;
}
async function json(file, label) {
  try { return JSON.parse(await fs.readFile(file, "utf8")); }
  catch (error) { throw new Error(`Could not read ${label}: ${error.message}`); }
}
async function assertImage(file, label) {
  const link = await fs.lstat(file);
  if (link.isSymbolicLink()) throw new Error(`${label} must not be a symbolic link`);
  if (!imageExtensions.has(path.extname(file).toLowerCase())) throw new Error(`${label} must be PNG, JPEG, or WebP`);
  const stat = await fs.stat(file);
  if (!stat.isFile() || stat.size < 1 || stat.size > 16 * 1024 * 1024) throw new Error(`${label} must be a non-empty file no larger than 16 MB`);
}
async function validate(rootArg) {
  const root = path.resolve(rootArg);
  const manifest = await json(path.join(root, "skin.json"), "skin.json");
  if (manifest.schemaVersion !== 1) throw new Error("skin.json schemaVersion must be 1");
  const id = text(manifest.id, "skin id", 80);
  if (!/^[a-z0-9][a-z0-9._-]{1,78}[a-z0-9]$/i.test(id)) throw new Error("skin id must use letters, numbers, dot, dash, or underscore");
  const name = text(manifest.name, "skin name", 80);
  const version = text(manifest.version, "skin version", 40);
  if (!/^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/.test(version)) throw new Error("skin version must look like semver");
  if (!Array.isArray(manifest.platforms) || !manifest.platforms.includes("macos")) throw new Error("skin platforms must include macos");
  if (!manifest.files || typeof manifest.files !== "object") throw new Error("skin files map is required");
  const themePath = relativeFile(root, manifest.files.theme, "files.theme");
  const backgroundPath = relativeFile(root, manifest.files.background, "files.background");
  const cssPath = manifest.files.css ? relativeFile(root, manifest.files.css, "files.css") : null;
  const theme = await json(themePath, "theme file");
  if (theme.schemaVersion !== 1) throw new Error("theme schemaVersion must be 1");
  await assertImage(backgroundPath, "files.background");
  if (cssPath) { const stat = await fs.stat(cssPath); if (!stat.isFile() || stat.size < 1 || stat.size > 256 * 1024) throw new Error("files.css must be a non-empty file no larger than 256 KB"); }
  const entries = await fs.readdir(root, { recursive: true, withFileTypes: true });
  if (entries.length > 128) throw new Error("Skin package contains too many files");
  for (const entry of entries) {
    if (entry.isSymbolicLink()) throw new Error("Skin packages may not include symbolic links");
    if (DISALLOWED_EXTENSIONS.has(path.extname(entry.name).toLowerCase())) throw new Error("Skin packages may not include executable code");
  }
  return { root, manifest, theme, themePath, backgroundPath, cssPath, id, name, version };
}
async function install(validated, outputDirArg) {
  const output = path.resolve(valueFor("output-dir") || outputDirArg);
  const temporary = `${output}.${process.pid}.installing`;
  if (path.dirname(output) === output) throw new Error("Refusing to install into a filesystem root");
  await fs.rm(temporary, { recursive: true, force: true });
  await fs.mkdir(temporary, { recursive: true, mode: 0o700 });
  const image = path.basename(validated.backgroundPath);
  await fs.writeFile(path.join(temporary, "theme.json"), `${JSON.stringify({ ...validated.theme, id: validated.theme.id || validated.id, name: validated.theme.name || validated.name, image }, null, 2)}\n`, { mode: 0o600 });
  await fs.copyFile(validated.backgroundPath, path.join(temporary, image));
  if (validated.cssPath) await fs.copyFile(validated.cssPath, path.join(temporary, "dream-skin.css"));
  await fs.writeFile(path.join(temporary, "installed-skin.json"), `${JSON.stringify({ schemaVersion: 1, installedAt: new Date().toISOString(), source: { id: validated.id, name: validated.name, version: validated.version } }, null, 2)}\n`, { mode: 0o600 });
  await fs.rm(output, { recursive: true, force: true });
  await fs.rename(temporary, output);
}
try {
  if (!skinDirArg || !["validate", "install"].includes(command)) throw new Error("Usage: skin-package.mjs <validate|install> <skin-dir> [--output-dir <theme-dir>]");
  const validated = await validate(skinDirArg);
  if (command === "install") await install(validated);
  console.log(JSON.stringify({ pass: true, id: validated.id, name: validated.name, version: validated.version }, null, 2));
} catch (error) { console.error(`[skin-package] ${error.message}`); process.exitCode = 1; }

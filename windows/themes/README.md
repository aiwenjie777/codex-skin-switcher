# Windows themes

## Recommended: use the Skill

After installing this repository's `codex-skin-skill` plugin, ask Codex directly:

- “Install Codex Skin”
- Attach an image and say “Create and apply a Windows skin from this image”
- “List installed Windows skins”
- “Switch Windows Codex to the <theme name> skin”
- “Verify the current Windows skin”
- “Restore the official Codex appearance”

The plugin's theme-creator skill turns the attached image into a concrete theme folder, then the switcher applies and verifies it. It asks before restarting an existing Codex process. You do not need to open PowerShell or click a shortcut.

Each theme is a folder under `windows/themes/<name>/`. A theme may contain:

- `dream-skin.css` — optional CSS; falls back to `windows/assets/dream-skin.css`
- `dream-reference.png` or `background.png|jpg|jpeg|webp` — optional background; falls back to the bundled demo asset

## Manual troubleshooting fallback

Apply a named theme with:

```powershell
.\scripts\start-dream-skin.ps1 -RestartExisting -Theme <name>
```

List installed themes with:

```powershell
node .\scripts\list-themes.mjs
```

Theme names accept letters, numbers, dots, underscores, and dashes only. The injector only attaches to the requested loopback CDP port.

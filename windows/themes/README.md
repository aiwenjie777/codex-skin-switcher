# Windows themes

## Recommended: use the Skill

After installing this repository's `codex-skin-switcher` plugin, ask Codex directly:

- “List installed Windows skins”
- “Switch Windows Codex to the <theme name> skin”
- “Verify the current Windows skin”
- “Restore the official Codex appearance”

The skill resolves the theme name and uses the repository scripts for the full flow. It asks before restarting an existing Codex process. The commands below remain available as a manual and troubleshooting fallback.

Each theme is a folder under `windows/themes/<name>/`. A theme may contain:

- `dream-skin.css` — optional CSS; falls back to `windows/assets/dream-skin.css`
- `dream-reference.png` or `background.png|jpg|jpeg|webp` — optional background; falls back to the bundled demo asset

Apply a named theme with:

```powershell
.\scripts\start-dream-skin.ps1 -RestartExisting -Theme <name>
```

List installed themes with:

```powershell
node .\scripts\list-themes.mjs
```

Theme names accept letters, numbers, dots, underscores, and dashes only. The injector only attaches to the requested loopback CDP port.

---
name: codex-skin-switcher
description: Manage Codex desktop themes in this repository. Use when a user asks to install, apply, switch, list, verify, restore, or create a Codex desktop theme or skin. Do not use for generic website, document, slide, or Figma themes.
---

# Codex Skin Switcher

## Rules

- Use the repository runtime: `macos/` on macOS and `windows/` on Windows.
- Never read, write, patch, or back up Codex `config.toml`.
- Prefer hot reapply when CDP is already available; request confirmation before a restart.
- After installing, applying, switching, or restoring, verify the active session when Codex is running.

## Actions

1. Install: run the platform installer directly. Do not ask the user to open a terminal or PowerShell unless they explicitly request manual steps.
2. Create a theme: use the sibling `codex-theme-creator` workflow, then offer to apply it.
3. Apply or switch: macOS uses `macos/scripts/switch-theme-macos.sh`; Windows uses `windows/scripts/start-dream-skin.ps1 -RestartExisting -Theme <name>`.
4. List available themes: use `windows/scripts/list-themes.mjs` on Windows or list the macOS theme library.
5. Verify: run the platform verification script and report the result.
6. Restore: run the platform restore script; do not remove user data unless explicitly asked.

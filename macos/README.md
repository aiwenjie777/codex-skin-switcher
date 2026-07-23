# Codex Dream Skin Studio

Unofficial macOS theme studio for the **official Codex Desktop** app.

Turn an image you like into a Codex theme: a dedicated home banner, a low-noise task background, and frosted content layers — while **keeping native sidebar, suggestion cards, project picker, task content, menus, and composer** fully interactive.

This project injects through **local loopback CDP**. It does **not** modify the official `.app`, `app.asar`, or code signature.

> Not affiliated with OpenAI. Codex is a trademark of its respective owners.

## Requirements

- macOS
- Official Codex Desktop installed
- No global Node.js install required (uses Codex’s signed bundled Node after validation)
- The skin workflow does not read or modify `~/.codex/config.toml`

## Recommended: operate entirely through the Skill

With the global `codex-skin` skill installed, normal use happens entirely in the Codex conversation. No terminal command or Desktop double-click is required:

- “Install Codex Skin”
- Attach an image and say “Use this image as my Codex Skin”
- “List installed skins”
- “Switch to the <theme name> skin”
- “Verify the current skin with screenshots”
- “Restore the official Codex appearance”

The skill saves image-based themes to the theme library, prefers a hot re-apply when loopback CDP is already available, and asks before any required restart. A confirmed restart or restore is handed to a one-shot, non-persistent LaunchAgent so the operation can finish even when the current Codex window closes.

## Quick start (from this repo)

```bash
# 1) Optional static checks (needs Codex.app present for bundled Node path)
./tests/run-tests.sh

# 2) Manual fallback: install to the stable path and create Desktop launchers
./scripts/install-dream-skin-macos.sh --no-launch

# 3) Double-click the Desktop “Codex Skin.command” and use its menu.
#    It can choose an image, switch saved themes, verify, or restore.

# 4) Optional: menu bar (SwiftBar) — apply / pause / change image
./Install\ Menu\ Bar.command
# Look for 🎨 Skin in the top-right menu bar
```

Install location after step 2:

| Item | Path |
| --- | --- |
| Engine | `~/.codex/codex-dream-skin-studio` |
| State / logs / user images | `~/Library/Application Support/CodexDreamSkinStudio` |
| Theme backup | under Application Support (`theme-backup.json`) |

## Customer ZIP (optional packaging)

To build the “double-click install” folder layout for non-git users:

```bash
./scripts/build-client-release.sh "$HOME/Desktop/Codex 主题编辑器.zip"
```

That ZIP contains a visible installer plus a hidden `.codex-dream-skin-studio` engine. Do not ship only CSS/images.

## How it works (security boundary)

1. Discover `com.openai.codex` and validate signature / Team ID / arch / bundled Node.
2. Start the validated, signed Codex executable with CDP bound to `127.0.0.1` only. If the request comes from inside Codex, use a one-shot, non-persistent LaunchAgent to finish the confirmed restart after the current window closes.
3. Accept the debug port only when it belongs to Codex (or a legitimate child).
4. Inject only into expected `app://` renderer targets.
5. Keep a small injector alive across reloads and route changes.
6. Restore stops the injector only when PID, path, and start time match the recorded job.

CDP is powerful and unauthenticated on loopback. Prefer Restore when you are done theming.

## Image guidelines

- PNG / JPEG / HEIC / TIFF / WebP (macOS readable)
- Source ≤ 50 MB; prepared file ≤ 16 MB
- Wide images work best (width ≥ 2000 px recommended)
- Keep the left side relatively calm for native home titles
- Image is banner + background only — never a full-window fake UI overlay

CLI example:

```bash
~/.codex/codex-dream-skin-studio/scripts/customize-theme-macos.sh \
  --image "/path/to/image.png" \
  --name "My theme" \
  --accent "#7cff46" \
  --secondary "#36d7e8" \
  --highlight "#642a8c"
```

Reset to the bundled abstract demo:

```bash
~/.codex/codex-dream-skin-studio/scripts/customize-theme-macos.sh --reset-demo
```

Install a data-only skin package (ZIP or folder):

```bash
macos/scripts/apply-skin-package-macos.sh --package "/path/to/skin-package.zip"
```

Try the bundled Caishen Readable package:

```bash
macos/scripts/apply-skin-package-macos.sh --package macos/skin-packages/caishen-readable
```

The package format and safety limits are documented in [`SKIN_PACKAGES.md`](./SKIN_PACKAGES.md).

For a task-page regression check, open an existing Codex task and run:

```bash
macos/scripts/verify-dream-skin-macos.sh --require-task --screenshot "$HOME/Desktop/Codex Dream Skin Task Verification.png"
```

This checks that the themed task page keeps its native sidebar and composer visible, contains a visible task-content region, and does not introduce horizontal overflow.

## License

MIT — see `LICENSE`. Additional notices in `NOTICE.md` (trademarks, demo asset, runtime Node).

## Sponsors

Thanks to **[passion8.cc](https://passion8.cc/register?aff=TuPe)** for sponsoring this project.

<p align="center">
  <a href="https://passion8.cc/register?aff=TuPe">
    <img src="../docs/images/sponsor-passion8.png" alt="Passion8" height="96">
  </a>
</p>

<p align="center">
  <a href="https://passion8.cc/register?aff=TuPe"><strong>Passion8｜感谢 passion8.cc 赞助本项目</strong></a><br>
  AI API 中转站，支持 Codex / Claude Code / Grok 等工具接入。主题与 API 配置互相独立。
</p>

## What this is not

- Not an OpenAI product and not a fork of Codex source
- Not a way to patch or rebrand the official binary
- Not a Windows build (see `../windows/`)
- Not an API proxy: theming does not change model providers or API keys

If you use a third-party API relay, configure it separately — keep theme install and API config as two explicit steps.

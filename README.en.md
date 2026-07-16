# Codex Skin

<p align="center">
  <a href="./README.md">中文</a> · <strong>English</strong>
</p>

<p align="center">
  <strong>Give Codex Desktop a skin that is unmistakably yours.</strong><br>
  Turn one image into a home banner and task background while keeping the native sidebar, project picker, and composer.
</p>

<p align="center">
  Unofficial community project · local loopback CDP only · never modifies <code>.app</code>, <code>app.asar</code>, or code signatures.
</p>

## Get started in 30 seconds

### macOS (full experience)

1. Open [`macos/`](./macos/) and double-click `Install Codex Dream Skin.command`.
2. Double-click `Customize Codex Dream Skin.command`, choose an image in Finder, and name the theme.
3. Double-click `Start Codex Dream Skin.command` to apply it. It prefers hot re-apply when Codex is already running.
4. Double-click `Verify Codex Dream Skin.command` whenever you want a screenshot check; the screenshot is saved to your Desktop.

To return to the stock interface, double-click `Restore Codex Dream Skin.command`.

### Windows

See [`windows/`](./windows/). Run `scripts/install-dream-skin.ps1`, then `scripts/start-dream-skin.ps1`.

> Launch the official Codex Desktop once before using the macOS installer. After installation, the engine is in `~/.codex/codex-dream-skin-studio`; images, theme state, and logs are in `~/Library/Application Support/CodexDreamSkinStudio`.

## What you get

- **Native interaction** — The sidebar, suggestion cards, project picker, task content, and composer remain real Codex controls, never a full-window screenshot.
- **One image, one theme** — Choose an image to create a banner and low-noise task background; switch again whenever you like.
- **Verifiable and reversible** — Use the screenshot verifier, then restore the stock appearance in one step.
- **Clear safety boundary** — CDP binds to `127.0.0.1` only. No official binary, signature, API key, Base URL, or model provider is changed.

## Gallery

<p align="center">
  <img src="assets/e160a0ccf5ab668284bde06b3c18de85.png" alt="Codex Skin theme preview" width="900">
</p>

<p align="center">
  <img src="docs/images/gallery/skin-01.jpg" alt="Pink custom theme" width="440">
  <img src="docs/images/gallery/skin-06.jpg" alt="Purple night theme" width="440">
</p>

<p align="center">
  <img src="docs/images/gallery/skin-03.jpg" alt="Red-white sci-fi theme" width="440">
  <img src="docs/images/gallery/skin-08.jpg" alt="Stage black-gold theme" width="440">
</p>

For more previews, image guidance, and macOS command-line options, see [`macos/README.md`](./macos/README.md).

## Use the `codex-skin` skill

After installing the global skill, tell Codex what you want to do:

- “Install Codex Skin”
- “Customize Codex Skin with this image”
- “Apply the active theme and verify it with a screenshot”
- “Restore the official Codex appearance”

The skill uses the same safe operations for installation, customization, hot re-apply, verification, and restore. It asks before a restart.

## Safety

- The theme injects through local-loopback CDP only. Avoid untrusted local processes while it is active.
- It never modifies the official Codex install directory, binary, `app.asar`, or code signature.
- Theme installation and API relay configuration are separate. This project never silently rewrites API keys, Base URLs, or model providers.
- People and IP artwork in previews is illustrative. Confirm the relevant rights before commercial or public redistribution.

## Docs and contributions

- macOS guide and CLI options: [`macos/README.md`](./macos/README.md)
- Platform paths: [`docs/platforms.md`](./docs/platforms.md)
- Bugs and feature requests: [issue templates](./.github/ISSUE_TEMPLATE/)
- Changes: [PR template](./.github/pull_request_template.md)
- License and notices: [`macos/LICENSE`](./macos/LICENSE) · [`macos/NOTICE.md`](./macos/NOTICE.md)

---

This repository is derived from [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) and follows its [MIT License](./macos/LICENSE). Codex and related rights belong to their respective owners; this project is not affiliated with OpenAI.

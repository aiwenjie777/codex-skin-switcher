# Skin packages

Skin packages are data-only directories or ZIP archives for macOS. They are installed into the local theme library and can be hot-applied when Codex is already running with loopback CDP.

Required layout:

```text
my-skin/
├── skin.json
├── theme.json
├── background.png
└── dream-skin.css       # optional
```

`skin.json` must contain schema version `1`, an ID, display name, semantic version, `platforms: ["macos"]`, and a `files` map for `theme`, `background`, and optional `css` / `preview`. Images may be PNG, JPEG, or WebP. Packages must not include executable code.

Install one with:

```bash
macos/scripts/apply-skin-package-macos.sh --package "/absolute/path/to/my-skin.zip"
```

ZIP archives are checked before extraction: at most 128 entries, no dangerous paths, and at most 64 MB uncompressed. The installer then rejects path traversal, symbolic links, executable extensions, invalid manifest data, and oversized referenced assets. It never modifies the official Codex app or `~/.codex/config.toml`.

# 皮肤包格式

皮肤包是仅含数据的目录或 ZIP。安装后保存在 `~/Library/Application Support/CodexDreamSkinStudio/themes/<id>/`；可列举并随时切换，不会覆盖其他已安装主题。

```text
my-skin/
├── skin.json
├── theme.json
├── background.png
└── dream-skin.css       # 可选
```

`skin.json` 必须使用 schema version `1`，并提供 `id`、`name`、语义化 `version`、`platforms: ["macos"]` 及 `files.theme`、`files.background`。图片限 PNG/JPEG/WebP；可选 CSS 不超过 256 KB。

ZIP 会在解压前验证条目数不超过 128、展开后不超过 64 MB 且无危险路径；解压后还会拒绝符号链接、脚本/二进制和越界路径。安装与切换只经本机回环 CDP，不会修改官方应用或 `config.toml`。

```bash
macos/scripts/apply-skin-package-macos.sh --package "/path/to/my-skin.zip"
macos/scripts/apply-skin-package-macos.sh --list
macos/scripts/switch-theme-macos.sh --id my-skin
```

内置示例包：

```bash
macos/scripts/apply-skin-package-macos.sh --package macos/skin-packages/caishen-readable
```

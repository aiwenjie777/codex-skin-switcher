# Codex Skin

<p align="center">
  <strong>中文</strong> · <a href="./README.en.md">English</a>
</p>

<p align="center">
  <strong>给 Codex Desktop 换上一张真正属于你的皮肤。</strong><br>
  用一张图片生成主页横幅与任务背景，同时保留原生侧栏、项目选择和输入框。
</p>

<p align="center">
  非官方社区项目 · 仅通过本机回环 CDP 工作 · 不修改 <code>.app</code>、<code>app.asar</code> 或代码签名。
</p>

## 30 秒开始

### macOS（完整版本）

1. 打开 [`macos/`](./macos/)，双击 `Install Codex Dream Skin.command`。
2. 双击 `Customize Codex Dream Skin.command`，在 Finder 选择图片并输入主题名称。
3. 双击 `Start Codex Dream Skin.command` 应用主题；已运行时会优先热应用。
4. 需要确认效果时，双击 `Verify Codex Dream Skin.command`；截图保存到桌面。

想回到官方外观，双击 `Restore Codex Dream Skin.command`。

### Windows

Windows 入口与说明见 [`windows/`](./windows/)：先运行 `scripts/install-dream-skin.ps1`，再运行 `scripts/start-dream-skin.ps1`。

> macOS 使用前请先启动过一次官方 Codex Desktop；安装后引擎位于 `~/.codex/codex-dream-skin-studio`，你的图片、主题状态与日志保存在 `~/Library/Application Support/CodexDreamSkinStudio`。

## 你会得到什么

- **原生可交互**：侧栏、建议卡、项目选择、任务内容与输入框仍是官方原生控件，不是整窗截图。
- **一图一主题**：选一张图片即可生成横幅和低干扰任务背景；随时可以再次换图。
- **可验证、可恢复**：提供验证截图和一键恢复入口，不把你锁在某个主题里。
- **安全边界明确**：CDP 只监听 `127.0.0.1`，不改官方安装包，也不会修改 API Key 或 Base URL。

## 主题预览

<p align="center">
  <img src="assets/e160a0ccf5ab668284bde06b3c18de85.png" alt="Codex Skin 主题预览" width="900">
</p>

<p align="center">
  <img src="docs/images/gallery/skin-01.jpg" alt="粉系定制主题" width="440">
  <img src="docs/images/gallery/skin-06.jpg" alt="紫夜限定主题" width="440">
</p>

<p align="center">
  <img src="docs/images/gallery/skin-03.jpg" alt="红白科幻主题" width="440">
  <img src="docs/images/gallery/skin-08.jpg" alt="舞台黑金主题" width="440">
</p>

更多示例和 macOS 的图片尺寸、命令行参数说明，见 [`macos/README.md`](./macos/README.md)。

## 使用 `codex-skin` skill

已安装全局 skill 后，直接告诉 Codex 你想做什么即可，例如：

- “安装 Codex Skin”
- “用这张图定制 Codex Skin”
- “应用当前主题并截图验证”
- “恢复 Codex 官方外观”

它会复用上面的安全入口完成安装、定制、热应用、验证或恢复；重启前会先征得确认。

## 安全说明

- 主题通过本机回环 CDP 注入，监听地址固定为 `127.0.0.1`。主题运行期间，请避免运行来源不明的本机程序。
- 不修改官方 Codex 安装目录、二进制、`app.asar` 或代码签名。
- 换肤与 API 中转配置相互独立；本项目不会静默改写 API Key、Base URL 或模型提供商。
- 预览中的人物和 IP 形象仅作主题效果示意；用于商业或公开再分发前，请自行确认相关权利。

## 文档与贡献

- macOS 使用与命令行参数：[`macos/README.md`](./macos/README.md)
- 平台路径对照：[`docs/platforms.md`](./docs/platforms.md)
- 问题与功能建议：[Issue 模板](./.github/ISSUE_TEMPLATE/)
- 提交改动：[PR 模板](./.github/pull_request_template.md)
- 许可与声明：[`macos/LICENSE`](./macos/LICENSE) · [`macos/NOTICE.md`](./macos/NOTICE.md)

## 微信交流

<table align="center">
  <tr>
    <td align="center">
      <img src="./docs/images/wechat-qr.png" alt="Codex Dream Skin 微信交流群二维码" width="220"><br>
      <sub>微信群：扫码加入交流</sub>
    </td>
    <td align="center">
      <img src="./docs/images/wechat.png" alt="作者个人微信二维码" width="220"><br>
      <sub>个人微信：添加时请备注“Codex Skin”</sub>
    </td>
  </tr>
</table>

---

本仓库基于 [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 二次开发并遵循其 [MIT License](./macos/LICENSE)。Codex 及相关权利归其权利人所有；本项目与 OpenAI 无关联。

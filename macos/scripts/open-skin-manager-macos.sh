#!/bin/bash

# One-click entrypoint for everyday Codex Skin actions.
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

ensure_state_root
ensure_node_runtime

ACTION="$(/usr/bin/osascript -e 'choose from list {"换一张图片并应用", "切换已安装主题", "验证当前效果", "恢复官方外观"} with title "Codex Skin" with prompt "你想做什么？" default items {"换一张图片并应用"}' 2>/dev/null || true)"
[ -n "$ACTION" ] && [ "$ACTION" != "false" ] || exit 0

case "$ACTION" in
  "换一张图片并应用")
    exec "$SCRIPT_DIR/customize-theme-macos.sh"
    ;;
  "切换已安装主题")
    THEMES_ROOT="$STATE_ROOT/themes"
    /bin/mkdir -p "$THEMES_ROOT"
    THEME_IDS=()
    for theme in "$THEMES_ROOT"/*; do
      [ -d "$theme" ] && [ -f "$theme/theme.json" ] || continue
      THEME_IDS+=("$(/usr/bin/basename "$theme")")
    done
    [ "${#THEME_IDS[@]}" -gt 0 ] || fail "No saved themes yet. Choose ‘换一张图片并应用’ first."
    THEME_ID="$(/usr/bin/osascript - "${THEME_IDS[@]}" <<'APPLESCRIPT'
on run themeIds
  set picked to choose from list themeIds with title "Codex Skin" with prompt "选择要应用的主题"
  if picked is false then return ""
  return item 1 of picked
end run
APPLESCRIPT
)"
    [ -n "$THEME_ID" ] || exit 0
    exec "$SCRIPT_DIR/switch-theme-macos.sh" --id "$THEME_ID"
    ;;
  "验证当前效果")
    SCREENSHOT="$HOME/Desktop/Codex Skin Verification.png"
    "$SCRIPT_DIR/verify-dream-skin-macos.sh" --screenshot "$SCREENSHOT"
    /usr/bin/open "$SCREENSHOT"
    ;;
  "恢复官方外观")
    CONFIRM="$(/usr/bin/osascript -e 'button returned of (display dialog "这会移除当前皮肤并重启 Codex 以恢复官方外观。继续吗？" buttons {"取消", "恢复"} default button "恢复" with icon caution)' 2>/dev/null || true)"
    [ "$CONFIRM" = "恢复" ] || exit 0
    exec "$SCRIPT_DIR/restore-dream-skin-macos.sh" --restart-codex
    ;;
esac

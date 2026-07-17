#!/bin/bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

PACKAGE=""
APPLY_NOW=true
LIST_ONLY=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --package) PACKAGE="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW=false; shift ;;
    --list) LIST_ONLY=true; shift ;;
    *) fail "Unknown apply-skin-package argument: $1" ;;
  esac
done
ensure_state_root
ensure_node_runtime
[ "$LIST_ONLY" = false ] || { "$SCRIPT_DIR/list-themes-macos.sh"; exit 0; }
[ -n "$PACKAGE" ] && [ -e "$PACKAGE" ] || fail "Pass --package <skin-folder-or-zip>"
TEMP_ROOT=""
cleanup() { [ -z "$TEMP_ROOT" ] || /bin/rm -rf "$TEMP_ROOT"; }
trap cleanup EXIT
SKIN_ROOT="$PACKAGE"
case "$PACKAGE" in
  *.zip|*.ZIP)
    ZIP_NAMES="$(/usr/bin/zipinfo -1 "$PACKAGE")" || fail "Could not inspect ZIP package."
    ZIP_COUNT="$(printf '%s\n' "$ZIP_NAMES" | /usr/bin/awk 'NF { count += 1 } END { print count + 0 }')"
    [ "$ZIP_COUNT" -le 128 ] || fail "ZIP contains too many entries (maximum: 128)."
    printf '%s\n' "$ZIP_NAMES" | /usr/bin/awk 'index($0, "../") || $0 ~ /^\// || $0 ~ /\\/ { exit 1 }' \
      || fail "ZIP contains an unsafe path."
    ZIP_TOTALS="$(/usr/bin/zipinfo -t "$PACKAGE")" || fail "Could not read ZIP totals."
    ZIP_BYTES="$(printf '%s\n' "$ZIP_TOTALS" | /usr/bin/awk '/bytes uncompressed/ { for (i = 1; i <= NF; i += 1) if ($i == "bytes") { print $(i - 1); exit } }')"
    case "$ZIP_BYTES" in ''|*[!0-9]*) fail "Could not verify ZIP uncompressed size." ;; esac
    [ "$ZIP_BYTES" -le $((64 * 1024 * 1024)) ] || fail "ZIP expands beyond the 64 MB safety limit."
    TEMP_ROOT="$(/usr/bin/mktemp -d /tmp/codex-skin-package.XXXXXX)"
    /usr/bin/ditto -x -k "$PACKAGE" "$TEMP_ROOT"
    if [ -f "$TEMP_ROOT/skin.json" ]; then SKIN_ROOT="$TEMP_ROOT"; else
      SKIN_ROOT="$(/usr/bin/find "$TEMP_ROOT" -mindepth 1 -maxdepth 1 -type d | /usr/bin/head -n 1)"
      [ -f "${SKIN_ROOT:-}/skin.json" ] || fail "ZIP must contain skin.json at the root or inside one top-level folder."
    fi ;;
esac
SKIN_JSON="$("$NODE" "$SCRIPT_DIR/skin-package.mjs" validate "$SKIN_ROOT")" || fail "Skin package validation failed."
SKIN_ID="$(printf '%s' "$SKIN_JSON" | "$NODE" -e 'let raw=""; process.stdin.on("data", d => raw += d).on("end", () => process.stdout.write(JSON.parse(raw).id || ""));')"
[ -n "$SKIN_ID" ] || fail "Skin package did not provide a valid ID."
THEMES_ROOT="$STATE_ROOT/themes"
"$NODE" "$SCRIPT_DIR/skin-package.mjs" install "$SKIN_ROOT" --output-dir "$THEMES_ROOT/$SKIN_ID" >/dev/null
[ "$APPLY_NOW" = true ] || { printf 'Skin package installed in theme library as %s.\n' "$SKIN_ID"; exit 0; }
"$SCRIPT_DIR/switch-theme-macos.sh" --id "$SKIN_ID"
exit 0

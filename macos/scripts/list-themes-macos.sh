#!/bin/bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

ensure_state_root
ensure_node_runtime
THEMES_ROOT="$STATE_ROOT/themes"
/bin/mkdir -p "$THEMES_ROOT"
for theme in "$THEMES_ROOT"/*; do
  [ -d "$theme" ] && [ -f "$theme/theme.json" ] || continue
  "$NODE" -e 'try { const t = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); console.log(JSON.stringify({ id: t.id || process.argv[2], name: t.name || process.argv[2] })); } catch {}' "$theme/theme.json" "$(basename "$theme")"
done

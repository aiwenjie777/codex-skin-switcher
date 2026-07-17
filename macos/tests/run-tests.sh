#!/bin/bash

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
NODE="${NODE:-/Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node}"
[ -x "$NODE" ] || { printf 'Codex bundled Node.js was not found: %s\n' "$NODE" >&2; exit 1; }

while IFS= read -r file; do /bin/bash -n "$file"; done < <(
  /usr/bin/find "$ROOT" -type f \( -name '*.sh' -o -name '*.command' \) \
    ! -path '*/release/*' -print
)
while IFS= read -r file; do "$NODE" --check "$file" >/dev/null; done < <(
  /usr/bin/find "$ROOT/scripts" "$ROOT/assets" -type f \( -name '*.mjs' -o -name '*.js' \) -print
)

if /usr/bin/grep -R -n -E 'dream-skin-skin|DREAM_SKIN_SKIN|1\.0\.0-rc2' \
  "$ROOT/scripts" "$ROOT/assets" >/dev/null; then
  printf 'Legacy release-candidate identifiers remain in runtime files.\n' >&2
  exit 1
fi
if /usr/bin/grep -R -n -E '(writeFile|rename|copyFile|rm).*app\.asar' "$ROOT/scripts" >/dev/null; then
  printf 'A runtime script appears to mutate app.asar.\n' >&2
  exit 1
fi

"$NODE" "$ROOT/scripts/injector.mjs" --check-payload >/dev/null

TMP="$(/usr/bin/mktemp -d /tmp/codex-dream-skin-tests.XXXXXX)"
trap '/bin/rm -rf "$TMP"' EXIT
/bin/mkdir -p "$TMP/theme"
/bin/cp "$ROOT/assets/portal-hero.png" "$TMP/theme/background.png"
"$NODE" "$ROOT/scripts/write-theme.mjs" custom --output-dir "$TMP/theme" \
  --image background.png --name '测试主题' --tagline '测试口号' --quote 'TEST' \
  --accent '#11aa55' --secondary '#22bbcc' --highlight '#663399' >/dev/null
PAYLOAD_JSON="$("$NODE" "$ROOT/scripts/injector.mjs" --check-payload --theme-dir "$TMP/theme")"
"$NODE" -e '
  const value = JSON.parse(process.argv[1]);
  if (!value.pass || value.themeName !== "测试主题" || value.imageBytes < 1) process.exit(1);
' "$PAYLOAD_JSON"
"$NODE" "$ROOT/scripts/write-theme.mjs" reset-demo --output-dir "$TMP/theme" >/dev/null
[ ! -e "$TMP/theme" ]

SKIN="$TMP/skin"
/bin/mkdir -p "$SKIN"
/bin/cp "$ROOT/assets/portal-hero.png" "$SKIN/background.png"
/usr/bin/printf '%s\n' '{"schemaVersion":1,"image":"background.png"}' > "$SKIN/theme.json"
/usr/bin/printf '%s\n' '{"schemaVersion":1,"id":"test-skin","name":"Test Skin","version":"1.0.0","platforms":["macos"],"files":{"theme":"theme.json","background":"background.png"}}' > "$SKIN/skin.json"
"$NODE" "$ROOT/scripts/skin-package.mjs" install "$SKIN" --output-dir "$TMP/themes/test-skin" >/dev/null
[ -f "$TMP/themes/test-skin/theme.json" ]
[ -f "$TMP/themes/test-skin/installed-skin.json" ]

"$NODE" "$ROOT/scripts/theme-config.mjs" | /usr/bin/grep -q 'never reads or writes Codex config.toml'

/usr/bin/env -u HOME /bin/bash -c '. "$1/scripts/common-macos.sh"; [ -n "$HOME" ] && [ "$SKIN_VERSION" = "1.3.4" ]' _ "$ROOT"

/usr/bin/grep -q '/usr/bin/nohup "\$CODEX_EXE"' "$ROOT/scripts/common-macos.sh"
if /usr/bin/sed -n '/^launch_codex_with_cdp()/,/^}/p' "$ROOT/scripts/common-macos.sh" | /usr/bin/grep -q 'open -na'; then
  printf 'CDP launcher must not use open -na because recent Codex builds can drop Chromium flags.\n' >&2
  exit 1
fi
/usr/bin/grep -q -- '--internal-restart-worker' "$ROOT/scripts/start-dream-skin-macos.sh"
/usr/bin/grep -q '<key>KeepAlive</key><false/>' "$ROOT/scripts/start-dream-skin-macos.sh"
/usr/bin/grep -q -- '--internal-restore-worker' "$ROOT/scripts/restore-dream-skin-macos.sh"
/usr/bin/grep -q '<key>KeepAlive</key><false/>' "$ROOT/scripts/restore-dream-skin-macos.sh"
if /usr/bin/grep -q 'open -na.*remote-debugging' "$ROOT/scripts/start-dream-skin-macos.sh"; then
  printf 'Start script must not spawn a second normal Codex instance while enabling CDP.\n' >&2
  exit 1
fi
"$ROOT/scripts/doctor-macos.sh" >/dev/null

printf 'PASS: syntax, payload, custom-theme, skin-package library install, config isolation, HOME recovery, signature, and doctor checks.\n'

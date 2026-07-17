#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

PORT=9341
PORT_EXPLICIT="false"
RESTORE_BASE_THEME="false"
RESTART_CODEX="false"
UNINSTALL="false"
INTERNAL_RESTORE_WORKER="false"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --port) PORT="${2:-}"; PORT_EXPLICIT="true"; shift 2 ;;
    --restore-base-theme) RESTORE_BASE_THEME="true"; shift ;;
    --restart-codex) RESTART_CODEX="true"; shift ;;
    --uninstall) UNINSTALL="true"; shift ;;
    --internal-restore-worker) INTERNAL_RESTORE_WORKER="true"; shift ;;
    *) fail "Unknown restore argument: $1" ;;
  esac
done

discover_codex_app
require_macos_runtime
ensure_state_root
if [ "$PORT_EXPLICIT" = "false" ] && [ -f "$STATE_PATH" ]; then
  PORT="$(state_field port)" || fail "Could not read the saved CDP port; state was preserved."
fi

[ -f "$STATE_PATH" ] && stop_recorded_injector
# Always remove the themed Codex launchd babysitter so quitting Codex stays quit.
release_codex_launchd_job || true
CODEX_RUNNING="false"
codex_is_running && CODEX_RUNNING="true"
DEBUG_READY="false"
verified_cdp_endpoint "$PORT" && DEBUG_READY="true"

if [ "$DEBUG_READY" = "true" ]; then
  "$NODE" "$INJECTOR" --remove --port "$PORT" --theme-dir "$THEME_DIR" --timeout-ms 8000 >/dev/null \
    || fail "The live skin could not be removed and verified; restore stopped safely."
elif [ "$CODEX_RUNNING" = "true" ] && [ "$RESTART_CODEX" = "false" ]; then
  fail "Codex is still running but its saved CDP endpoint cannot be verified. Pass --restart-codex for a full restore."
fi

if [ "$RESTORE_BASE_THEME" = "true" ]; then
  printf '%s\n' '--restore-base-theme is deprecated and ignored; Codex config.toml is never modified.' >&2
fi

if [ "$RESTART_CODEX" = "true" ]; then
  if [ "$CODEX_RUNNING" = "true" ] && [ "$INTERNAL_RESTORE_WORKER" = "false" ]; then
    RESTORE_JOB_LABEL="com.openai.codex-dream-skin-studio.restore-worker"
    RESTORE_PLIST="$STATE_ROOT/restore-worker.plist"
    RESTORE_LOG="$STATE_ROOT/restore-handoff.log"
    uid="$(/usr/bin/id -u)"
    /bin/launchctl bootout "gui/$uid/$RESTORE_JOB_LABEL" >/dev/null 2>&1 || true
    xml_escape() {
      /usr/bin/sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
    }
    worker_script="$(printf '%s' "$SCRIPT_DIR/restore-dream-skin-macos.sh" | xml_escape)"
    worker_log="$(printf '%s' "$RESTORE_LOG" | xml_escape)"
    /usr/bin/printf '%s\n' \
      '<?xml version="1.0" encoding="UTF-8"?>' \
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
      '<plist version="1.0"><dict>' \
      "<key>Label</key><string>$RESTORE_JOB_LABEL</string>" \
      '<key>ProgramArguments</key><array>' \
      '<string>/bin/bash</string>' \
      "<string>$worker_script</string>" \
      '<string>--port</string>' \
      "<string>$PORT</string>" \
      '<string>--restart-codex</string>' \
      '<string>--internal-restore-worker</string>' \
      '</array>' \
      '<key>RunAtLoad</key><true/>' \
      '<key>KeepAlive</key><false/>' \
      "<key>StandardOutPath</key><string>$worker_log</string>" \
      "<key>StandardErrorPath</key><string>$worker_log</string>" \
      '</dict></plist>' > "$RESTORE_PLIST"
    /bin/chmod 600 "$RESTORE_PLIST"
    : > "$RESTORE_LOG"
    /bin/launchctl bootstrap "gui/$uid" "$RESTORE_PLIST" \
      || fail "Could not start the one-shot restore handoff."
    /bin/rm -f "$STATE_PATH"
    printf 'Restore handoff prepared. Codex will relaunch with the official appearance.\n'
    exit 0
  fi
  [ "$CODEX_RUNNING" = "true" ] && stop_codex true
  launch_codex_normally
fi

/bin/rm -f "$STATE_PATH"
if [ "$UNINSTALL" = "true" ]; then
  /bin/rm -f "$HOME/Desktop/Codex Dream Skin.command"
  /bin/rm -f "$HOME/Desktop/Codex Dream Skin - Customize.command"
  /bin/rm -f "$HOME/Desktop/Codex Dream Skin - Verify.command"
  /bin/rm -f "$HOME/Desktop/Codex Dream Skin - Restore.command"
fi

printf 'Codex Dream Skin Studio was removed and the requested macOS restore actions completed successfully.\n'

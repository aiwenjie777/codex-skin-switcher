#!/usr/bin/env bash
set -euo pipefail

readonly PUBLIC_NAME="aiwenjie777"
readonly PUBLIC_EMAIL="305695997+aiwenjie777@users.noreply.github.com"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_repo() {
  git rev-parse --show-toplevel >/dev/null 2>&1 || die "not inside a Git repository"
}

check_identity() {
  local actual_name actual_email
  actual_name="$(git config --local --get user.name || true)"
  actual_email="$(git config --local --get user.email || true)"
  [[ "$actual_name" == "$PUBLIC_NAME" ]] || die "repository user.name must be $PUBLIC_NAME"
  [[ "$actual_email" == "$PUBLIC_EMAIL" ]] || die "repository user.email must be $PUBLIC_EMAIL"
  printf 'PASS: public Git identity is configured.\n'
}

configure_identity() {
  local hook_path
  git config --local user.name "$PUBLIC_NAME"
  git config --local user.email "$PUBLIC_EMAIL"
  hook_path="$(git config --local --get core.hooksPath || true)"
  if [[ -z "$hook_path" || "$hook_path" == ".githooks" ]]; then
    git config --local core.hooksPath .githooks
  else
    die "core.hooksPath is already $hook_path; keep it or install the identity hook manually"
  fi
  check_identity
}

audit_range() {
  local base_ref="${1:-}"
  local invalid
  [[ -n "$base_ref" ]] || die "usage: $0 audit-range <base-ref>"
  git rev-parse --verify "$base_ref^{commit}" >/dev/null 2>&1 || die "unknown base ref: $base_ref"
  invalid="$(git log --format='%H%x09%an%x09%ae%x09%cn%x09%ce' "$base_ref..HEAD" | awk -F '\t' -v name="$PUBLIC_NAME" -v email="$PUBLIC_EMAIL" '$2 != name || $3 != email || $4 != name || $5 != email')"
  [[ -z "$invalid" ]] || die "non-public identity found in commits after $base_ref:\n$invalid"
  printf 'PASS: commits after %s use the public Git identity.\n' "$base_ref"
}

require_repo
case "${1:-check}" in
  check)
    check_identity
    ;;
  configure)
    configure_identity
    ;;
  audit-range)
    audit_range "${2:-}"
    ;;
  *)
    die "usage: $0 {check|configure|audit-range <base-ref>}"
    ;;
esac

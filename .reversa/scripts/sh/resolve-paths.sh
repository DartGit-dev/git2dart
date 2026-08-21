#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SETUP_FILE="$PROJECT_ROOT/.reversa/setup.json"

read_setup_path() {
  local key="$1"
  local fallback="$2"
  local value=""

  if [ -f "$SETUP_FILE" ]; then
    value="$(sed -nE "s/^[[:space:]]*\"$key\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\1/p" "$SETUP_FILE" | head -n 1)"
  fi
  printf '%s\n' "${value:-$fallback}"
}

resolve_project_path() {
  local name="$1"
  local fallback="$2"
  local relative_path
  relative_path="$(read_setup_path "$name" "$fallback")"

  case "$relative_path" in
    /*|[A-Za-z]:*|../*|*/../*|*/..)
      echo "Reversa path '$name' must stay inside the project root: $relative_path" >&2
      return 2
      ;;
  esac
  printf '%s/%s\n' "$PROJECT_ROOT" "$relative_path"
}

REVERSA_DIR="$(resolve_project_path 'config-dir' '.reversa')" || exit $?
SDD_DIR="$(resolve_project_path 'sdd-dir' 'reversa/sdd')" || exit $?
FORWARD_DIR="$(resolve_project_path 'forward-dir' 'reversa/forward')" || exit $?
DOCS_DIR="$(resolve_project_path 'docs-dir' 'reversa/docs')" || exit $?
BUGS_DIR="$(resolve_project_path 'bugs-dir' 'reversa/bugs')" || exit $?

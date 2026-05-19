#!/usr/bin/env sh
set -eu

REPO_OWNER="KimoLink"
REPO_NAME=".agents"
TARGET=""
REF="master"
YES=0
DRY_RUN=0

show_help() {
  cat <<EOF
Install KimoLink agent rules and skills.

Usage:
  sh install.sh [options]
  curl -fsSL https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/master/install.sh | sh

Options:
  --target codex|claude|agents|all  Install target. Omit for interactive selection.
  --ref <ref>                       Git branch or tag to install from. Default: master.
  --yes                             Accept overwrite prompts.
  --dry-run                         Print planned changes without writing files.
  --version                         Print installer version.
  --help                            Print this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --ref)
      REF="${2:-}"
      shift 2
      ;;
    --yes|-y)
      YES=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --version)
      if [ -f "./VERSION" ]; then
        head -n 1 ./VERSION
      else
        printf '%s\n' "$REF"
      fi
      exit 0
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

case "$TARGET" in
  ""|codex|claude|agents|all) ;;
  *)
    printf 'Invalid target: %s\n' "$TARGET" >&2
    exit 1
    ;;
esac

confirm_overwrite() {
  path="$1"
  if [ "$YES" -eq 1 ]; then
    return 0
  fi

  if [ ! -r /dev/tty ]; then
    printf 'Overwrite prompt requires a TTY. Re-run with --yes for non-interactive install.\n' >&2
    return 1
  fi

  printf 'Overwrite existing %s ? [Y/n] ' "$path"
  read answer </dev/tty
  case "$answer" in
    ""|Y|y|YES|Yes|yes) return 0 ;;
    *) return 1 ;;
  esac
}

backup_existing() {
  path="$1"
  timestamp="$2"
  if [ ! -e "$path" ]; then
    return 0
  fi

  backup_path="$path.bak.$timestamp"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] backup %s -> %s\n' "$path" "$backup_path"
    return 0
  fi

  mv "$path" "$backup_path"
  printf 'Backed up %s -> %s\n' "$path" "$backup_path"
}

copy_path_with_backup() {
  source="$1"
  destination="$2"
  timestamp="$3"

  if [ -e "$destination" ]; then
    if ! confirm_overwrite "$destination"; then
      printf 'Skipped %s\n' "$destination"
      return 0
    fi
    backup_existing "$destination" "$timestamp"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] copy %s -> %s\n' "$source" "$destination"
    return 0
  fi

  mkdir -p "$(dirname "$destination")"
  cp -R "$source" "$destination"
  printf 'Installed %s\n' "$destination"
}

select_target() {
  if [ -n "$TARGET" ]; then
    printf '%s\n' "$TARGET"
    return 0
  fi

  if [ ! -r /dev/tty ]; then
    printf 'Interactive target selection requires a TTY. Re-run with --target codex|claude|agents|all.\n' >&2
    exit 1
  fi

  printf 'Select install target:\n'
  printf '  1. Codex       ~/.codex\n'
  printf '  2. Claude Code ~/.claude\n'
  printf '  3. Common      ~/.agents\n'
  printf '  4. All\n'
  printf 'Target [1-4] '
  read choice </dev/tty

  case "$choice" in
    1) printf 'codex\n' ;;
    2) printf 'claude\n' ;;
    3) printf 'agents\n' ;;
    4) printf 'all\n' ;;
    *) printf 'Invalid target selection: %s\n' "$choice" >&2; exit 1 ;;
  esac
}

install_to_target() {
  source_root="$1"
  name="$2"
  root="$3"
  rules_file="$4"
  timestamp="$5"

  printf 'Installing to %s: %s\n' "$name" "$root"
  copy_path_with_backup "$source_root/AGENTS.md" "$root/$rules_file" "$timestamp"

  if [ ! -d "$source_root/skills" ]; then
    printf 'Missing source skills directory: %s\n' "$source_root/skills" >&2
    exit 1
  fi

  for skill in "$source_root"/skills/*; do
    [ -d "$skill" ] || continue
    copy_path_with_backup "$skill" "$root/skills/$(basename "$skill")" "$timestamp"
  done
}

download_source() {
  work_dir="$1"
  archive_path="$work_dir/agents.tar.gz"
  branch_url="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/heads/$REF.tar.gz"
  tag_url="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/tags/$REF.tar.gz"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$branch_url" -o "$archive_path" || curl -fsSL "$tag_url" -o "$archive_path"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$branch_url" -O "$archive_path" || wget -q "$tag_url" -O "$archive_path"
  else
    printf 'curl or wget is required.\n' >&2
    exit 1
  fi

  tar -xzf "$archive_path" -C "$work_dir"
  find "$work_dir" -maxdepth 1 -type d -name "$REPO_NAME-*" | head -n 1
}

selected_target="$(select_target)"
timestamp="$(date +%Y%m%d%H%M%S)"
unique_suffix="$$"
if command -v od >/dev/null 2>&1 && [ -r /dev/urandom ]; then
  unique_suffix="$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
fi
work_dir="${TMPDIR:-/tmp}/agents-install-$timestamp-$unique_suffix"
mkdir -p "$work_dir"

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT INT TERM

source_root="$(download_source "$work_dir")"
if [ -z "$source_root" ]; then
  printf 'Unable to locate extracted source directory.\n' >&2
  exit 1
fi

case "$selected_target" in
  codex)
    install_to_target "$source_root" "Codex" "$HOME/.codex" "AGENTS.md" "$timestamp"
    ;;
  claude)
    install_to_target "$source_root" "Claude Code" "$HOME/.claude" "CLAUDE.md" "$timestamp"
    ;;
  agents)
    install_to_target "$source_root" "Common" "$HOME/.agents" "AGENTS.md" "$timestamp"
    ;;
  all)
    install_to_target "$source_root" "Codex" "$HOME/.codex" "AGENTS.md" "$timestamp"
    install_to_target "$source_root" "Claude Code" "$HOME/.claude" "CLAUDE.md" "$timestamp"
    install_to_target "$source_root" "Common" "$HOME/.agents" "AGENTS.md" "$timestamp"
    ;;
esac

printf 'Done.\n'

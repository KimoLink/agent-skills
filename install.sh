#!/usr/bin/env sh
set -eu

REPO_OWNER="KimoLink"
REPO_NAME="agent-skills"
TARGET=""
REF="master"
YES=0
DRY_RUN=0
COLOR=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  COLOR=1
fi

color() {
  if [ "$COLOR" -eq 1 ]; then
    printf '\033[%sm' "$1"
  fi
}

reset_color() {
  if [ "$COLOR" -eq 1 ]; then
    printf '\033[0m'
  fi
}

status() {
  kind="$1"
  shift
  case "$kind" in
    step) prefix="[step]"; code="36" ;;
    ok) prefix="[ok]"; code="32" ;;
    warn) prefix="[warn]"; code="33" ;;
    dry-run) prefix="[dry-run]"; code="35" ;;
    *) prefix="[info]"; code="90" ;;
  esac

  color "$code"
  printf '%s' "$prefix"
  reset_color
  printf ' '
  printf "$@"
  printf '\n'
}

option() {
  number="$1"
  name="$2"
  path="$3"
  printf '  '
  color "33"
  printf '[%s]' "$number"
  reset_color
  printf ' %s  ' "$name"
  color "90"
  printf '%s' "$path"
  reset_color
  printf '\n'
}

show_help() {
  cat <<EOF
Install Kimo Agent Skill Pack.

Usage:
  sh install.sh [options]
  curl -fsSL https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/master/install.sh | sh

Options:
  --target codex|claude|agents|trae|all  Install target. Omit for interactive selection.
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
  ""|codex|claude|agents|trae|all) ;;
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
  backup_path="${3:-}"
  if [ ! -e "$path" ]; then
    return 0
  fi

  if [ -z "$backup_path" ]; then
    backup_path="$path.bak.$timestamp"
  fi
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$backup_path")"
    mv "$path" "$backup_path"
  fi
  printf '%s\n' "$backup_path"
}

copy_path_with_backup() {
  source="$1"
  destination="$2"
  timestamp="$3"
  backup_destination="${4:-}"

  if [ -e "$destination" ]; then
    if ! confirm_overwrite "$destination"; then
      status "warn" 'skipped %s' "$destination"
      return 0
    fi
    backup_path="$(backup_existing "$destination" "$timestamp" "$backup_destination")"
    verb="update"
    done_verb="updated"
  else
    backup_path=""
    verb="install"
    done_verb="installed"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -n "$backup_path" ]; then
      status "dry-run" 'would %s %s (backup: %s)' "$verb" "$destination" "$backup_path"
    else
      status "dry-run" 'would %s %s' "$verb" "$destination"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$destination")"
  cp -R "$source" "$destination"
  if [ -n "$backup_path" ]; then
    status "ok" '%s %s (backup: %s)' "$done_verb" "$destination" "$backup_path"
  else
    status "ok" '%s %s' "$done_verb" "$destination"
  fi
}

move_legacy_skill_backups() {
  target_skills="$1"
  backup_root="$2"

  if [ ! -d "$target_skills" ]; then
    return 0
  fi

  for legacy_backup in "$target_skills"/*.bak.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; do
    [ -d "$legacy_backup" ] || continue
    [ -f "$legacy_backup/SKILL.md" ] || continue

    destination="$backup_root/$(basename "$legacy_backup")"
    if [ -e "$destination" ]; then
      status "warn" 'legacy backup already exists, skipped %s' "$legacy_backup"
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      status "dry-run" 'would move legacy skill backup %s to %s' "$legacy_backup" "$destination"
      continue
    fi

    mkdir -p "$backup_root"
    mv "$legacy_backup" "$destination"
    status "ok" 'moved legacy skill backup %s to %s' "$legacy_backup" "$destination"
  done
}

select_target() {
  if [ -n "$TARGET" ]; then
    printf '%s\n' "$TARGET"
    return 0
  fi

  if [ ! -r /dev/tty ]; then
    printf 'Interactive target selection requires a TTY. Re-run with --target codex|claude|agents|trae|all.\n' >&2
    exit 1
  fi

  status "step" 'Select install target'
  option "1" "Codex      " "~/.codex"
  option "2" "Claude Code" "~/.claude"
  option "3" "Common     " "~/.agents"
  option "4" "Trae       " "~/.trae"
  option "5" "All        " "all targets"
  printf 'Target [1-5] '
  read choice </dev/tty

  case "$choice" in
    1) printf 'codex\n' ;;
    2) printf 'claude\n' ;;
    3) printf 'agents\n' ;;
    4) printf 'trae\n' ;;
    5) printf 'all\n' ;;
    *) printf 'Invalid target selection: %s\n' "$choice" >&2; exit 1 ;;
  esac
}

install_to_target() {
  source_root="$1"
  name="$2"
  root="$3"
  rules_file="$4"
  timestamp="$5"

  status "step" 'Installing to %s: %s' "$name" "$root"
  copy_path_with_backup "$source_root/AGENTS.md" "$root/$rules_file" "$timestamp"

  if [ ! -d "$source_root/skills" ]; then
    printf 'Missing source skills directory: %s\n' "$source_root/skills" >&2
    exit 1
  fi

  move_legacy_skill_backups "$root/skills" "$root/.skill-backups/skills"

  for skill in "$source_root"/skills/*; do
    [ -d "$skill" ] || continue
    skill_name="$(basename "$skill")"
    copy_path_with_backup "$skill" "$root/skills/$skill_name" "$timestamp" "$root/.skill-backups/skills/$skill_name.bak.$timestamp"
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
  find "$work_dir" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r source_root; do
    if [ -f "$source_root/AGENTS.md" ] && [ -d "$source_root/skills" ] && [ -f "$source_root/install.sh" ]; then
      printf '%s\n' "$source_root"
      break
    fi
  done
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

status "step" 'Downloading %s/%s@%s' "$REPO_OWNER" "$REPO_NAME" "$REF"
source_root="$(download_source "$work_dir")"
if [ -z "$source_root" ]; then
  printf 'Unable to locate extracted source directory.\n' >&2
  exit 1
fi
status "ok" 'source ready: %s' "$source_root"

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
  trae)
    install_to_target "$source_root" "Trae" "$HOME/.trae" "user_rules.md" "$timestamp"
    ;;
  all)
    install_to_target "$source_root" "Codex" "$HOME/.codex" "AGENTS.md" "$timestamp"
    install_to_target "$source_root" "Claude Code" "$HOME/.claude" "CLAUDE.md" "$timestamp"
    install_to_target "$source_root" "Common" "$HOME/.agents" "AGENTS.md" "$timestamp"
    install_to_target "$source_root" "Trae" "$HOME/.trae" "user_rules.md" "$timestamp"
    ;;
esac

status "ok" 'Done.'

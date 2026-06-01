#!/usr/bin/env sh
set -eu

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
temp_root="${TMPDIR:-/tmp}/agent-skills-backup-test-$$"
installer_functions="$temp_root/installer-functions.sh"

assert_exists() {
  if [ ! -e "$1" ]; then
    printf '%s\n' "$2" >&2
    exit 1
  fi
}

assert_missing() {
  if [ -e "$1" ]; then
    printf '%s\n' "$2" >&2
    exit 1
  fi
}

cleanup() {
  rm -rf "$temp_root"
}
trap cleanup EXIT INT TERM

mkdir -p "$temp_root"
sed '/^selected_target=/,$d' "$repo_root/install.sh" >"$installer_functions"
. "$installer_functions"

source_root="$temp_root/source"
target_root="$temp_root/target"
source_skill="$source_root/skills/sample-skill"
target_skill="$target_root/skills/sample-skill"
legacy_backup="$target_root/skills/sample-skill.bak.20260101010101"
timestamp="20260601123456"

mkdir -p "$source_skill" "$target_skill" "$legacy_backup"
printf '%s\n' "new rules" >"$source_root/AGENTS.md"
printf '%s\n' "old rules" >"$target_root/AGENTS.md"
printf '%s\n' "new skill" >"$source_skill/SKILL.md"
printf '%s\n' "old skill" >"$target_skill/SKILL.md"
printf '%s\n' "legacy backup skill" >"$legacy_backup/SKILL.md"

YES=1
DRY_RUN=0
install_to_target "$source_root" "Test" "$target_root" "AGENTS.md" "$timestamp"

assert_exists "$target_skill/SKILL.md" "updated skill was not installed"
assert_exists "$target_root/AGENTS.md.bak.$timestamp" "rules backup should remain next to the rules file"
assert_exists "$target_root/.skill-backups/skills/sample-skill.bak.$timestamp/SKILL.md" "old skill was not moved to backup directory"
assert_missing "$target_root/skills/sample-skill.bak.$timestamp" "backup remained under skills directory"
assert_exists "$target_root/.skill-backups/skills/sample-skill.bak.20260101010101/SKILL.md" "legacy skill backup was not migrated"
assert_missing "$legacy_backup" "legacy skill backup remained under skills directory"

printf '%s\n' "install-backup.sh passed"

#!/usr/bin/env bash
# Install the Night Parade calibration skills into ~/.claude/ WITHOUT the plugin system.
# Copies each skill's SKILL.md (+ docs) to ~/.claude/skills/<name>/ and each slash
# command to ~/.claude/commands/. Use this on any Claude Code setup; or install via the
# plugin marketplace instead (see README).
#
# Idempotent: safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="${REPO_DIR}/skills"
SKILLS_DST="${HOME}/.claude/skills"
COMMANDS_DST="${HOME}/.claude/commands"

SKILLS=(anti-sycophancy anti-hallucination anti-fictional-frame anti-dependency)

# Ensure submodules are present (fresh clones without --recurse-submodules miss them)
if [ ! -f "${SKILLS_SRC}/anti-dependency/SKILL.md" ]; then
  echo "Submodules not initialized; fetching..."
  git -C "${REPO_DIR}" submodule update --init --recursive
fi

mkdir -p "${COMMANDS_DST}"

for skill in "${SKILLS[@]}"; do
  src="${SKILLS_SRC}/${skill}"
  if [ ! -f "${src}/SKILL.md" ]; then
    echo "ERROR: ${src}/SKILL.md missing. Run: git submodule update --init --recursive" >&2
    exit 1
  fi
  mkdir -p "${SKILLS_DST}/${skill}/docs"
  cp "${src}/SKILL.md" "${SKILLS_DST}/${skill}/SKILL.md"
  [ -f "${src}/README.md" ] && cp "${src}/README.md" "${SKILLS_DST}/${skill}/README.md"
  [ -d "${src}/docs" ] && cp -r "${src}/docs/." "${SKILLS_DST}/${skill}/docs/"
  if [ -d "${src}/commands" ]; then
    cp "${src}/commands/"*.md "${COMMANDS_DST}/"
  fi
  echo "Installed: ${skill}"
done

echo
echo "All four Night Parade skills installed to ${SKILLS_DST}/"
echo "Slash commands installed to ${COMMANDS_DST}/"
echo
echo "Verify with /sycophancy-check, /hallucination-check, /fictional-frame-check, /dependency-check in a new session."
echo "Optional: append each skill's CLAUDE.md self-check snippet (see each skill's README) to ~/.claude/CLAUDE.md."

#!/usr/bin/env bash
# style-guard.sh - deterministic style enforcement for gtm-engineer-stack.
#
# Flags the hard bans defined in CLAUDE.md: em dashes, exclamation points,
# cold-email cliches, try-hard phrasing, and SaaS jargon. This is the
# mechanical pass; the output-review skill handles the judgment rules.
#
# Usage:
#   style-guard.sh <file>...        scan the given files
#   echo "text" | style-guard.sh    scan stdin text
#
# Exit 0 = clean. Exit 2 = violations found.
#
# This is invoked explicitly, not as a PostToolUse hook. It ran as one until the
# skip list was removed, and the skip list was removed because it could never
# work: every file a Write|Edit hook receives is repository-authored content
# (config, examples, motion definitions, docs, run artifacts), and none of it is
# outbound copy this script should judge. Generated drafts never arrive as files.
# They arrive on stdin, from the output-review skill, which is the enforcement
# path that has always carried the real traffic. Path cannot separate a new repo
# doc from a saved draft, since both are new markdown in the working tree, so
# per-directory exclusions kept growing and kept producing false positives.
#
# Callers pass either a draft on stdin or an explicit file they mean to scan, so
# nothing is skipped by path. Pointing this at a stack file that holds banned
# phrases as rule definitions will flag them, which is correct: you asked.

set -uo pipefail

# Each entry: "Category|pat1|pat2|..." - patterns are joined into one regex.
CATS=(
  "Em dash|—"
  "Exclamation point|!"
  "Cliche|quick question|circling back|touching base|wanted to reach out|very real, very fast|i noticed your linkedin|loved your post|huge fan|hope this finds you well"
  "Try-hard phrasing|spun up an account|really stuck|got me thinking|blown away|deep dive|in the weeds"
  "SaaS jargon|synergy|leverage|unlock|level up|scale[ -]up|10x|world-class|best-in-class|game-changer|ai-powered|intelligence layer|unified platform|help you [a-z]+"
)

# scan <source-label> <text>  -> prints violations, returns 1 if any found
scan() {
  local src="$1" text="$2" found=0 header_done=0
  local cat name pats hits
  for cat in "${CATS[@]}"; do
    name="${cat%%|*}"
    pats="${cat#*|}"
    hits="$(printf '%s\n' "$text" | grep -inE "$pats" || true)"
    if [ -n "$hits" ]; then
      if [ "$header_done" -eq 0 ]; then
        printf '%s:\n' "$src" >&2
        header_done=1
      fi
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        printf '  [%s] %s\n' "$name" "$line" >&2
      done <<< "$hits"
      found=1
    fi
  done
  return "$found"
}

files=()
stdin_text=""

if [ "$#" -gt 0 ]; then
  files=("$@")
else
  # Everything on stdin is draft text. The PostToolUse JSON branch that used to
  # live here is gone with the hook wiring; keeping it would misparse any draft
  # that happens to start with a brace.
  stdin_text="$(cat)"
fi

status=0

if [ -n "$stdin_text" ]; then
  scan "stdin" "$stdin_text" || status=2
fi

for f in "${files[@]:-}"; do
  [ -z "$f" ] && continue
  [ -f "$f" ] || continue
  scan "$f" "$(cat "$f")" || status=2
done

if [ "$status" -ne 0 ]; then
  echo "style-guard: voice violations found (see above). Fix before sending." >&2
  exit 2
fi
exit 0

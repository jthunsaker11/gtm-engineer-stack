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
#   (as a PostToolUse hook)         reads the tool JSON on stdin and scans the
#                                   written file
#
# Exit 0 = clean. Exit 2 = violations found (blocks the action when used as a
# hook). Files inside the stack's own directories are skipped, since they hold
# banned phrases as rule definitions and examples. Matches either path
# separator so Windows and POSIX paths both skip correctly.

set -uo pipefail

INTERNAL_RE='(^|[/\])(reference|skills|commands|hooks|docs|\.claude-plugin)[/\]'

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
  raw="$(cat)"
  if [ -n "$raw" ] && [ "${raw:0:1}" = "{" ]; then
    # PostToolUse JSON payload - pull out the written file path.
    fp="$(printf '%s' "$raw" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
    if [ -n "$fp" ]; then
      files=("$fp")
    else
      stdin_text="$raw"
    fi
  else
    stdin_text="$raw"
  fi
fi

status=0

if [ -n "$stdin_text" ]; then
  scan "stdin" "$stdin_text" || status=2
fi

for f in "${files[@]:-}"; do
  [ -z "$f" ] && continue
  if printf '%s' "$f" | grep -qE "$INTERNAL_RE"; then
    continue
  fi
  [ -f "$f" ] || continue
  scan "$f" "$(cat "$f")" || status=2
done

if [ "$status" -ne 0 ]; then
  echo "style-guard: voice violations found (see above). Fix before sending." >&2
  exit 2
fi
exit 0

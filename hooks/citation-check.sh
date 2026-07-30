#!/usr/bin/env bash
# citation-check.sh - deterministic pre-check for the source-preservation rule.
#
# Flags a speaking verb (said, mentioned, wrote, posted, shared, told, talked)
# that has no citation marker within 15 tokens on either side. This is the
# mechanical counterpart to output-review Criterion A.
#
# Usage mirrors style-guard.sh: file args, stdin text, or a PostToolUse JSON
# payload. Only markdown files are scanned; internal stack files are skipped.
# Exit 0 = clean, exit 2 = unsourced claims found.

set -uo pipefail

INTERNAL_RE='(^|[/\])(reference|skills|commands|hooks|docs|\.claude-plugin)[/\]|(^|[/\])CLAUDE\.md$'

scan() {
  local src="$1" text="$2"
  printf '%s' "$text" | awk -v src="$src" '
    { for (i=1;i<=NF;i++){ n++; w[n]=$i } }
    END {
      split("said mentioned wrote posted shared told talked", v, " ")
      for (k in v) verb[v[k]]=1
      viol=0; hdr=0
      for (i=1;i<=n;i++){
        tok=tolower(w[i]); gsub(/[^a-z]/,"",tok)
        if (tok in verb){
          lo=i-15; if(lo<1)lo=1
          hi=i+15; if(hi>n)hi=n
          win=""
          for (j=lo;j<=hi;j++) win=win " " w[j]
          wl=tolower(win)
          cited=0
          if      (win ~ /https?:\/\//)                                   cited=1
          else if (wl  ~ /according to/)                                  cited=1
          else if (wl  ~ /in the/)                                        cited=1
          else if (win ~ /\[[^]]+\]\([^)]+\)/)                            cited=1
          else if (win ~ /\([^)]*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) cited=1
          else if (wl  ~ /source:/)                                       cited=1
          if (!cited){
            if (!hdr){ printf "%s:\n", src > "/dev/stderr"; hdr=1 }
            printf "  [Unsourced claim] verb \"%s\" near:%s\n", tok, substr(win,1,110) > "/dev/stderr"
            viol=1
          }
        }
      }
      exit viol
    }'
}

files=(); stdin_text=""
if [ "$#" -gt 0 ]; then
  files=("$@")
else
  raw="$(cat)"
  if [ -n "$raw" ] && [ "${raw:0:1}" = "{" ]; then
    fp="$(printf '%s' "$raw" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
    if [ -n "$fp" ]; then files=("$fp"); else stdin_text="$raw"; fi
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
  case "$f" in *.md|*.markdown) : ;; *) continue ;; esac
  if printf '%s' "$f" | grep -qE "$INTERNAL_RE"; then continue; fi
  [ -f "$f" ] || continue
  scan "$f" "$(cat "$f")" || status=2
done

if [ "$status" -ne 0 ]; then
  echo "citation-check: unsourced claims found (see above). Add the source or remove the quoted claim." >&2
  exit 2
fi
exit 0

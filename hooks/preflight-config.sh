#!/usr/bin/env bash
# preflight-config.sh - deterministic config validation before any run that spends credits.
#
# Validates config/icp.md, config/personas.md, and config/offering.md, then derives
# the Apollo employee-size buckets from the ICP range and emits them as the single
# authoritative value a sourcing run may use.
#
# This is NOT a PostToolUse hook. It is invoked explicitly by the commands that
# source or enrich, before they spend anything. It lives in hooks/ because that is
# where this stack keeps its deterministic checks (style-guard, citation-check).
#
# Usage:
#   preflight-config.sh                  validate the repo's config/ directory
#   preflight-config.sh --config-dir D   validate an alternate config directory
#   preflight-config.sh --quiet          emit only failures and the machine-readable block
#
# Exit 0 = pass (warnings may still be printed; unenforced ICP fields are warnings
#          by design, so criteria with no filter behind them stay visible).
# Exit 2 = hard fail. The caller must stop. Never warn and continue.

set -uo pipefail

CONFIG_DIR="config"
QUIET=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --config-dir) CONFIG_DIR="${2:-}"; shift 2 ;;
    --quiet)      QUIET=1; shift ;;
    -h|--help)    sed -n '2,20p' "$0"; exit 0 ;;
    *)            echo "preflight-config: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

ICP="$CONFIG_DIR/icp.md"
PERSONAS="$CONFIG_DIR/personas.md"
OFFERING="$CONFIG_DIR/offering.md"

FAILURES=0
WARNINGS=0

fail() {
  # fail <file> <line> <message>
  printf '  [FAIL] %s:%s  %s\n' "$1" "$2" "$3" >&2
  FAILURES=$((FAILURES + 1))
}
warn() {
  printf '  [WARN] %s:%s  %s\n' "$1" "$2" "$3" >&2
  WARNINGS=$((WARNINGS + 1))
}
note() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$1"; }

# ---------------------------------------------------------------------------
# 0. The three config files must exist and be readable.
# ---------------------------------------------------------------------------
for f in "$ICP" "$PERSONAS" "$OFFERING"; do
  if [ ! -f "$f" ]; then
    fail "$f" "-" "config file is missing. Run /setup to create it."
  fi
done
if [ "$FAILURES" -gt 0 ]; then
  echo "preflight-config: FAILED ($FAILURES). Do not spend credits." >&2
  exit 2
fi

note "preflight-config: validating $CONFIG_DIR"

# ---------------------------------------------------------------------------
# 1. Template and placeholder markers.
#
# The canonical unfilled marker is TODO(setup):, which /setup writes for any field
# its source documents did not support. The historical starter-template forms are
# also matched so an older clone fails rather than silently prospecting on template
# text. An unfilled config must fail loudly; a guessed one fails silently, which is
# worse.
# ---------------------------------------------------------------------------
PLACEHOLDER_RE='TODO\(setup\)|\(replace with yours\)|\(none / specify\)|\(Add or remove\)|\bTBD\b|\bFIXME\b|<your [^>]*>|\[your [^]]*\]'

for f in "$ICP" "$PERSONAS" "$OFFERING"; do
  while IFS=: read -r ln text; do
    [ -z "${ln:-}" ] && continue
    fail "$f" "$ln" "unfilled config: $(printf '%s' "$text" | sed -E 's/^[[:space:]]+//' | cut -c1-90)"
  done < <(grep -nE "$PLACEHOLDER_RE" "$f" || true)
done

# ---------------------------------------------------------------------------
# 2. Required sections present and non-empty.
#
# Two checks, because either alone is defeatable: the named section must exist
# (so deleting a heading does not pass), and every heading carrying the (Required)
# qualifier must have real content under it (so an empty section does not pass).
# ---------------------------------------------------------------------------

# section_body_re <file> <heading-regex>  -> body lines under the first regex match
section_body_re() {
  awk -v re="$2" '
    /^#+ / { if (inb) exit; if ($0 ~ re) { inb=1; next } }
    inb { print }
  ' "$1"
}

# section_body_at <file> <line-number>  -> body lines under the heading on that line
section_body_at() {
  awk -v want="$2" '
    NR == want { inb=1; next }
    inb && /^#+ / { exit }
    inb { print }
  ' "$1"
}

# body_is_empty <text> -> 0 if the body has no substantive content
body_is_empty() {
  printf '%s' "$1" \
    | sed -E 's/<!--.*-->//' \
    | grep -qE '[A-Za-z0-9]' && return 1
  return 0
}

require_section() {
  # require_section <file> <heading-regex> <human name>
  local file="$1" re="$2" name="$3" ln body
  ln="$(grep -nE "$re" "$file" | head -1 | cut -d: -f1)"
  if [ -z "$ln" ]; then
    fail "$file" "-" "required section \"$name\" is missing."
    return
  fi
  body="$(section_body_re "$file" "$re")"
  if body_is_empty "$body"; then
    fail "$file" "$ln" "required section \"$name\" is empty."
  fi
}

require_section "$ICP"      '^#{2,3} Companies you target' "Companies you target"
require_section "$OFFERING" '^#{2,3} Product overview'     "Product overview"
require_section "$OFFERING" '^#{2,3} Value proposition'    "Value proposition"

# personas.md has no fixed heading name (the persona titles are client-specific),
# so the requirement is that at least one persona is marked (Required).
if ! grep -qE '^#{2,3} .*\(Required\)' "$PERSONAS"; then
  fail "$PERSONAS" "-" "no persona is marked (Required). At least one buying-committee role must be."
fi

# Every (Required)-qualified heading in any of the three files must be non-empty.
for f in "$ICP" "$PERSONAS" "$OFFERING"; do
  while IFS=: read -r ln text; do
    [ -z "${ln:-}" ] && continue
    body="$(section_body_at "$f" "$ln")"
    if body_is_empty "$body"; then
      fail "$f" "$ln" "section marked (Required) is empty: $(printf '%s' "$text" | cut -c1-70)"
    fi
  done < <(grep -nE '^#{2,3} .*\(Required\)' "$f" || true)
done

# ---------------------------------------------------------------------------
# 3. ICP employee range -> Apollo bucket derivation and consistency.
#
# This is the check that matters. The 100-company run failed on a hand-typed
# query that matched no version of the config, and a placeholder-only gate would
# have passed it. The fix is not to store the buckets somewhere and compare two
# copies, which just creates a second thing to drift. It is to derive them here,
# from the one number that is written down, and emit them as the only buckets a
# run may use.
#
# Apollo's organization_num_employees_ranges bands are fixed and cannot be
# expressed as arbitrary bounds.
# ---------------------------------------------------------------------------
APOLLO_BANDS="1,10 11,50 51,200 201,500 501,1000 1001,5000 5001,10000 10001,1000000"

EMP_LINE="$(grep -nE '^[-*][[:space:]]*Employee size:' "$ICP" | head -1 || true)"
EMP_LN="${EMP_LINE%%:*}"
EMP_MIN=""; EMP_MAX=""

if [ -z "$EMP_LINE" ]; then
  fail "$ICP" "-" "no \"Employee size:\" line found. Sourcing cannot derive an employee filter."
else
  read -r EMP_MIN EMP_MAX < <(
    printf '%s' "$EMP_LINE" \
      | grep -oE '[0-9][0-9,]*[[:space:]]+to[[:space:]]+[0-9][0-9,]*' \
      | head -1 | tr -d ',' | awk '{print $1, $3}'
  )
  if [ -z "${EMP_MIN:-}" ] || [ -z "${EMP_MAX:-}" ]; then
    fail "$ICP" "$EMP_LN" "\"Employee size\" does not state a numeric \"N to M\" range; buckets cannot be derived."
  elif [ "$EMP_MIN" -gt "$EMP_MAX" ]; then
    fail "$ICP" "$EMP_LN" "employee range is inverted ($EMP_MIN to $EMP_MAX)."
  fi
fi

BUCKETS=""
COVER_LO=""; COVER_HI=""
if [ -n "${EMP_MIN:-}" ] && [ -n "${EMP_MAX:-}" ] && [ "$EMP_MIN" -le "$EMP_MAX" ]; then
  for band in $APOLLO_BANDS; do
    lo="${band%%,*}"; hi="${band##*,}"
    # A band is in the query when it overlaps the ICP range at all.
    if [ "$hi" -ge "$EMP_MIN" ] && [ "$lo" -le "$EMP_MAX" ]; then
      BUCKETS="$BUCKETS \"$lo,$hi\""
      [ -z "$COVER_LO" ] && COVER_LO="$lo"
      COVER_HI="$hi"
    fi
  done
  BUCKETS="$(printf '%s' "$BUCKETS" | sed -E 's/^ //; s/ /,/g')"

  if [ -z "$BUCKETS" ]; then
    fail "$ICP" "$EMP_LN" "employee range $EMP_MIN to $EMP_MAX matches no Apollo band."
  fi
fi

# ---------------------------------------------------------------------------
# 4. Cross-file agreement: the employee range is stated in two places.
# ---------------------------------------------------------------------------
if [ -n "${EMP_MIN:-}" ] && [ -n "${EMP_MAX:-}" ]; then
  TM_LINE="$(grep -nE '[0-9][0-9,]*[[:space:]]+to[[:space:]]+[0-9][0-9,]*[[:space:]]+employees' "$OFFERING" | head -1 || true)"
  if [ -n "$TM_LINE" ]; then
    TM_LN="${TM_LINE%%:*}"
    read -r TM_MIN TM_MAX < <(
      printf '%s' "$TM_LINE" \
        | grep -oE '[0-9][0-9,]*[[:space:]]+to[[:space:]]+[0-9][0-9,]*[[:space:]]+employees' \
        | head -1 | tr -d ',' | awk '{print $1, $3}'
    )
    if [ "${TM_MIN:-}" != "$EMP_MIN" ] || [ "${TM_MAX:-}" != "$EMP_MAX" ]; then
      fail "$OFFERING" "$TM_LN" "target market says $TM_MIN to $TM_MAX employees; $ICP:$EMP_LN says $EMP_MIN to $EMP_MAX. Same fact, two values."
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 5. Unenforced ICP criteria -> warnings, so criteria with no filter stay visible.
#
# Warnings, not failures: an ICP field with no filter behind it is a real gap, but
# it is a known and sometimes deliberate one. Silence is the problem, not the gap.
# ---------------------------------------------------------------------------
declare -A ENFORCED=(
  ["Industry/vertical"]="source filter: q_organization_keyword_tags"
  ["Employee size"]="source filter: organization_num_employees_ranges (derived below)"
  ["CRM"]="source filter: currently_using_any_of_technology_uids"
  ["Geographic constraints"]="source filter: organization_locations"
)

while IFS=$'\t' read -r ln field; do
  [ -z "${ln:-}" ] && continue
  if [ -z "${ENFORCED[$field]:-}" ]; then
    warn "$ICP" "$ln" "ICP criterion \"$field\" has no source filter or post-source gate. It is stated but never enforced."
  fi
done < <(awk '
  /^## Companies you target/ { inb=1; next }
  inb && /^## / { exit }
  inb && /^[-*][[:space:]]+[A-Za-z]/ {
    line = $0
    sub(/^[-*][[:space:]]+/, "", line)
    idx = index(line, ":")
    if (idx > 0) printf "%d\t%s\n", NR, substr(line, 1, idx - 1)
  }
' "$ICP")

# ---------------------------------------------------------------------------
# Report.
# ---------------------------------------------------------------------------
if [ "$FAILURES" -gt 0 ]; then
  echo "" >&2
  echo "preflight-config: FAILED with $FAILURES error(s), $WARNINGS warning(s)." >&2
  echo "Fix the lines named above, or run /setup to populate the config. Do not spend credits." >&2
  exit 2
fi

note ""
note "preflight-config: PASS ($WARNINGS warning(s))"
note ""
note "Derived Apollo employee buckets (the ONLY buckets this run may use):"
note "  ICP range        : $EMP_MIN to $EMP_MAX employees"
note "  Apollo buckets   : [$BUCKETS]"
note "  Buckets cover    : $COVER_LO to $COVER_HI employees"
if [ "$COVER_LO" != "$EMP_MIN" ] || [ "$COVER_HI" != "$EMP_MAX" ]; then
  note "  Bucket slop      : bands are fixed, so the query is wider than the ICP."
  note "                     Re-filter post-source on $EMP_MIN to $EMP_MAX and log how many rows drop."
else
  note "  Bucket slop      : none, the bands tile the ICP range exactly."
fi

# Machine-readable block for the calling command to consume verbatim.
echo "PREFLIGHT_STATUS=pass"
echo "PREFLIGHT_EMP_MIN=$EMP_MIN"
echo "PREFLIGHT_EMP_MAX=$EMP_MAX"
echo "PREFLIGHT_APOLLO_BUCKETS=[$BUCKETS]"
echo "PREFLIGHT_POST_SOURCE_REFILTER=$([ "$COVER_LO" != "$EMP_MIN" ] || [ "$COVER_HI" != "$EMP_MAX" ] && echo required || echo none)"
exit 0

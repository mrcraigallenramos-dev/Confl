#!/usr/bin/env bash
set -euo pipefail

# Config
ROOT="${1:-.}"
REPORT="${2:-_consistency_report.md}"

shopt -s globstar nullglob

# Patterns
MD_RE='.*\.md$'
VALID_FILE_RE='^S[1-6]N[1-5]_(CH[0-9]{2}|Int[A-B]|Epilogue)\.md$'
REQ_KEYS=(series novella file type pov setting word_target_min word_target_max status)
CANON_GODS=("Xilcore" "Leesa" "Blemo" "Seeri")
CANON_TECH=("Wholeness Knot" "Form whisper" "Confluence Cannon" "Pulse Rupture" "Bastion" "Godvein Surge")

# Accumulators
declare -a inconsistencies
declare -a consistencies
total_files=0
md_files=0
consistent_files=0

# Helpers
front_matter_present() {
  awk 'NR==1 && $0 ~ /^---/ {inmeta=1; next}
       inmeta && $0 ~ /^---$/ {print "OK"; exit}
       inmeta {next}
       END{if (!inmeta) print "NO"}' "$1"
}

front_matter_keys() {
  awk 'BEGIN{in=0}
       /^---/ {in=1-in; next}
       in && $0 ~ /^[a-zA-Z0-9_]+:/ {split($0,a,":"); gsub(/ /,"",a[1]); print a[1]}' "$1" | sort -u
}

has_key() {
  local key="$1" file="$2"
  awk -v k="$key" 'BEGIN{in=0; found=0}
       /^---/ {in=1-in; next}
       in && $0 ~ "^"k":[[:space:]]" {found=1}
       END{if(found) print "YES"; else print "NO"}' "$2"
}

get_pov() {
  awk 'BEGIN{in=0}
       /^---/ {in=1-in; next}
       in && $0 ~ /^pov:/ {sub(/^pov:[[:space:]]*/,""); print; exit}' "$1"
}

file_is_valid_name() {
  local name="$1"
  if [[ "$name" =~ $VALID_FILE_RE ]]; then echo "YES"; else echo "NO"; fi
}

check_quotes_dashes() {
  # Flags smart quotes and mixed hyphens/en dashes
  LC_ALL=C grep -n -E "[\xE2\x80\x98\xE2\x80\x99\xE2\x80\x9C\xE2\x80\x9D]" "$1" >/dev/null && echo "smart_quotes"
  LC_ALL=C grep -n -E "[[:alnum:]]--[[:alnum:]]" "$1" >/dev/null && echo "double_hyphen"
}

check_duplicate_title() {
  awk '/^# /{sub(/^# /,""); print; exit}' "$1"
}

is_empty_or_tiny() {
  local sz
  sz=$(wc -c < "$1")
  if (( sz < 40 )); then echo "tiny"; fi
}

contains_any() {
  local file="$1"; shift
  local t
  for t in "$@"; do
    LC_ALL=C grep -F -q "$t" "$file" && { echo "yes"; return; }
  done
  echo "no"
}

# Title index for duplicate detection per novella folder
declare -A title_index

# Traverse
while IFS= read -r -d '' f; do
  (( total_files++ ))
  if [[ ! "$f" =~ $MD_RE ]]; then
    continue
  fi
  (( md_files++ ))
  rel="${f#$ROOT/}"

  dir="$(dirname "$rel")"
  base="$(basename "$rel")"

  # 1) Filename schema
  if [[ "$dir" =~ ^06_Outlines/Series_[1-6]/Novella_[1-5]$ ]]; then
    if [[ "$(file_is_valid_name "$base")" == "NO" ]]; then
      inconsistencies+=("BAD_NAME|$rel|Expected S#N#_(CH##|IntA|IntB|Epilogue).md")
    else
      consistencies+=("OK_NAME|$rel")
    fi
  fi

  # 2) Front matter presence
  if [[ "$(front_matter_present "$f")" != "OK" ]]; then
    inconsistencies+=("NO_FRONT_MATTER|$rel|Missing --- blocks")
    continue
  else
    consistencies+=("OK_FRONT_MATTER|$rel")
  fi

  # 3) Required keys
  missing_keys=()
  for k in "${REQ_KEYS[@]}"; do
    if [[ "$(has_key "$k" "$f")" != "YES" ]]; then
      missing_keys+=("$k")
    fi
  done
  if (( ${#missing_keys[@]} )); then
    inconsistencies+=("MISSING_KEYS|$rel|${missing_keys[*]}")
  else
    consistencies+=("OK_KEYS|$rel")
  fi

  # 4) POV vs ability language heuristic
  pov="$(get_pov "$f" | tr -d '\r')"
  if [[ -n "$pov" ]]; then
    if [[ "$pov" == "Jhace" ]]; then
      # Jhace should lean Wholeness language; flag explicit Form-only phrasing
      if LC_ALL=C grep -qiE '\bForm whisper\b|\bgeometric lattice\b' "$f"; then
        inconsistencies+=("POV_TECH_MISMATCH|$rel|pov:Jhace with Form-only phrasing")
      fi
    fi
    if [[ "$pov" == "Tiffani" ]]; then
      # Tiffani should lean Form; flag Wholeness-only phrasing
      if LC_ALL=C grep -qiE '\bWholeness Knot\b|\bharmonic choir\b' "$f"; then
        # Not always wrong, but mark for review if used as signature move
        inconsistencies+=("POV_TECH_REVIEW|$rel|pov:Tiffani with Wholeness signature phrasing")
      fi
    fi
  fi

  # 5) Canonical god names spelling
  for g in "${CANON_GODS[@]}"; do
    :
  done
  # Flag near-miss spellings (simple heuristics)
  if LC_ALL=C grep -qiE '\bXilcor(e)?\b|\bLees(a|e)\b|\bBlemo+\b|\bSeer(i|y)\b' "$f"; then
    # If exact canon not present alongside, flag
    miss=0
    for g in "${CANON_GODS[@]}"; do
      LC_ALL=C grep -F -q "$g" "$f" || miss=1
    done
    (( miss )) && inconsistencies+=("GOD_NAME_SUSPECT|$rel|Check spellings of god names")
  else
    # If file mentions any gods and matches canon names, mark okay
    if LC_ALL=C grep -qiE '\bXilcore\b|\bLeesa\b|\bBlemo\b|\bSeeri\b' "$f"; then
      consistencies+=("OK_GOD_NAMES|$rel")
    fi
  fi

  # 6) Duplicate titles within novella dir
  title="$(check_duplicate_title "$f")"
  if [[ -n "$title" ]]; then
    key="$dir|$title"
    if [[ -n "${title_index[$key]:-}" ]]; then
      inconsistencies+=("DUP_TITLE|$rel|${title_index[$key]}|$title")
    else
      title_index[$key]="$rel"
      consistencies+=("OK_TITLE_UNIQUE|$rel")
    fi
  fi

  # 7) Text health checks
  flags="$(check_quotes_dashes "$f" | paste -sd',' -)"
  if [[ -n "$flags" ]]; then
    inconsistencies+=("TYPOGRAPHY|$rel|$flags")
  else
    consistencies+=("OK_TYPOGRAPHY|$rel")
  fi

  # 8) Tiny/empty files
  if [[ "$(is_empty_or_tiny "$f")" == "tiny" ]]; then
    inconsistencies+=("TINY_FILE|$rel|<40 bytes")
  fi

done < <(find "$ROOT" -type f -print0)

# Check required novellas have README.md
while IFS= read -r -d '' dir; do
  if [[ ! -f "$dir/README.md" ]]; then
    inconsistencies+=("MISSING_README|${dir#$ROOT/}|No README.md")
  else
    consistencies+=("OK_README|${dir#$ROOT/}/README.md")
  fi
done < <(find "$ROOT/06_Outlines" -type d -regex '.*/Series_[1-6]/Novella_[1-5]' -print0)

# Render report
{
  echo "# Repository Consistency Report"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  echo "Total files scanned: $total_files"
  echo "Markdown files scanned: $md_files"
  echo
  echo "## Inconsistencies"
  if ((${#inconsistencies[@]}==0)); then
    echo "- None found"
  else
    for i in "${inconsistencies[@]}"; do
      IFS='|' read -r kind path detail rest <<< "$i"
      echo "- [$kind] $path — ${detail:-""} ${rest:+($rest)}"
    done
  fi
  echo
  echo "## Confirmed Consistencies"
  if ((${#consistencies[@]}==0)); then
    echo "- None recorded"
  else
    for i in "${consistencies[@]}"; do
      IFS='|' read -r kind path rest <<< "$i"
      echo "- [$kind] $path ${rest:+— $rest}"
    done
  fi
} > "$REPORT"

echo "Wrote report to: $REPORT"

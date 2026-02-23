#!/usr/bin/env bash
# validate-backlog.sh — Lint tickets for missing fields and broken Depends refs
# Only validates new-format tickets (those with a "Tags:" field).
set -euo pipefail

BACKLOG="agents/BACKLOG.md"
COMPLETED="agents/COMPLETED.md"

errors=()

# Collect all known ticket IDs
all_ids=$(grep -hEo 'T-[0-9]+' "$BACKLOG" "$COMPLETED" 2>/dev/null | sort -u)

# Parse tickets via Python for portability (macOS bash 3.2 lacks associative arrays)
while IFS= read -r result; do
  errors+=("$result")
done < <(python3 - "$BACKLOG" <<'PYEOF'
import sys, re

REQUIRED = ["Title:", "Status:", "Assigned:", "Priority:", "Milestone:",
            "Tags:", "Depends:", "Blocked-by:", "Refs:"]

backlog = open(sys.argv[1]).read()
# Split into ticket blocks
blocks = re.split(r'\n(?=### T-)', backlog)

for block in blocks:
    m = re.match(r'### (T-\d+)', block)
    if not m:
        continue
    ticket_id = m.group(1)
    # Only validate new-format tickets (those with Tags: field)
    if "Tags:" not in block:
        continue
    for field in REQUIRED:
        pattern = r'- ' + re.escape(field)
        if not re.search(pattern, block):
            print(f"{ticket_id}: missing field '{field}'")
    # Validate Depends ref
    dep_m = re.search(r'- Depends: (T-\d+)', block)
    if dep_m:
        dep = dep_m.group(1)
        print(f"__check_dep__{ticket_id}__{dep}")
PYEOF
)

# Re-collect errors vs dep-checks
real_errors=()
for item in "${errors[@]+"${errors[@]}"}"; do
  if [[ "$item" == __check_dep__* ]]; then
    ticket_id="${item#__check_dep__}"
    dep="${ticket_id##*__}"
    ticket_id="${ticket_id%__*}"
    if ! echo "$all_ids" | grep -qx "$dep"; then
      real_errors+=("$ticket_id: Depends: $dep — ticket not found in BACKLOG or COMPLETED")
    fi
  else
    real_errors+=("$item")
  fi
done

echo "=== Backlog Validation ==="
echo ""

if [[ ${#real_errors[@]} -eq 0 ]]; then
  echo "OK — no validation errors found."
  echo "(Note: only tickets with a 'Tags:' field are checked for all 9 required fields.)"
  exit 0
else
  echo "ERRORS found:"
  for err in "${real_errors[@]}"; do
    echo "  - $err"
  done
  exit 1
fi

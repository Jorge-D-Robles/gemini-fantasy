#!/usr/bin/env bash
# close-sprint.sh — Archive Done This Sprint → COMPLETED.md
# Usage: bash agents/close-sprint.sh [agent-name]
# Note: Does NOT modify SPRINT.md — starting a new sprint requires setting goal/milestone
#       which needs agent judgment. This script handles the mechanical archive step only.
set -euo pipefail

SPRINT="agents/SPRINT.md"
COMPLETED="agents/COMPLETED.md"
AGENT="${1:-agent}"
DATE=$(date +%Y-%m-%d)

echo "=== Close Sprint ==="
echo ""

# Extract Done This Sprint lines
done_lines=$(awk '/^## Done This Sprint/,/^---/' "$SPRINT" | grep -E '^- T-[0-9]+:' || true)

if [[ -z "$done_lines" ]]; then
  echo "No done tickets found in '## Done This Sprint' section."
  exit 0
fi

count=0
while IFS= read -r line; do
  # line format: "- T-XXXX: Title"
  entry="- [$DATE] ${line#- } ($AGENT)"
  echo "$entry" >> "$COMPLETED"
  echo "  Archived: $entry"
  ((count++))
done <<< "$done_lines"

echo ""
echo "Archived $count ticket(s) to $COMPLETED."
echo ""
echo "NEXT STEPS (manual — requires agent judgment):"
echo "  1. Update SPRINT.md: set new sprint name, goal, milestone, Started date"
echo "  2. Reset velocity block: Completed: 0, Added mid-sprint: 0, Rolled over: <count>"
echo "  3. Move unfinished Queue items to new sprint or back to BACKLOG.md"
echo "  4. Clear '## Done This Sprint' section"

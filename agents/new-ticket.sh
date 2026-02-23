#!/usr/bin/env bash
# new-ticket.sh — Scaffold next ticket with auto-incremented ID
# Usage: bash agents/new-ticket.sh "Title" <priority> <milestone> [tags]
set -euo pipefail

BACKLOG="agents/BACKLOG.md"

if [[ $# -lt 3 ]]; then
  echo "Usage: bash agents/new-ticket.sh \"Title\" <priority> <milestone> [tags]"
  echo "  priority: high | medium | low"
  echo "  milestone: M0 | M1 | M2 | M3 | M4 | M5 | —"
  echo "  tags: optional comma-separated list (e.g. 'battle,ui')"
  exit 1
fi

TITLE="$1"
PRIORITY="$2"
MILESTONE="$3"
TAGS="${4:-—}"

# Find highest existing T-XXXX ID across BACKLOG and SPRINT
highest=$(grep -hEo 'T-[0-9]+' agents/BACKLOG.md agents/SPRINT.md agents/COMPLETED.md 2>/dev/null \
  | grep -Eo '[0-9]+' | sort -n | tail -1)
next=$(printf "%04d" $((highest + 1)))
ID="T-$next"

TICKET=$(cat <<EOF

### $ID
- Title: $TITLE
- Status: todo
- Assigned: unassigned
- Priority: $PRIORITY
- Milestone: $MILESTONE
- Tags: $TAGS
- Depends: —
- Blocked-by: —
- Refs: —
EOF
)

echo "$TICKET" >> "$BACKLOG"

echo "Created $ID — move to correct milestone section in BACKLOG.md"
echo ""
echo "$TICKET"

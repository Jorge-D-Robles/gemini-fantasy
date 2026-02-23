#!/usr/bin/env bash
# check-backlog.sh — Health check: counts, blockers, oldest unassigned high-pri ticket
set -euo pipefail

BACKLOG="agents/BACKLOG.md"
SPRINT="agents/SPRINT.md"

echo "=== Backlog Health Check ==="
echo ""

echo "--- Open tickets by priority ---"
high=$(grep -c "Priority: high" "$BACKLOG" 2>/dev/null || echo 0)
medium=$(grep -c "Priority: medium" "$BACKLOG" 2>/dev/null || echo 0)
low=$(grep -c "Priority: low" "$BACKLOG" 2>/dev/null || echo 0)
echo "  High:   $high"
echo "  Medium: $medium"
echo "  Low:    $low"
echo ""

echo "--- Active in-progress tickets (SPRINT.md) ---"
grep "Status: in-progress" "$SPRINT" 2>/dev/null | sed 's/^/  /' || echo "  (none)"
echo ""

echo "--- Oldest unassigned high-priority ticket ---"
awk '
  /^### T-/ { ticket=$0; title=""; priority=""; assigned="" }
  /Title:/ { title=$0 }
  /Priority: high/ { priority="high" }
  /Assigned: unassigned/ { assigned="unassigned" }
  /^$/ && priority=="high" && assigned=="unassigned" && ticket!="" {
    print ticket; print title; ticket=""; priority=""; assigned=""
  }
' "$BACKLOG" | head -4 | sed 's/^/  /' || echo "  (none)"
echo ""

echo "--- Tickets with active Blocked-by entries ---"
grep -B5 "Blocked-by: T-" "$BACKLOG" 2>/dev/null | grep "^### T-" | sed 's/^/  /' || echo "  (none)"
echo ""

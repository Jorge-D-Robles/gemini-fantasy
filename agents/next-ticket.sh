#!/usr/bin/env bash
# next-ticket.sh — Find and print the next unblocked unassigned ticket
set -euo pipefail

SPRINT="agents/SPRINT.md"
BACKLOG="agents/BACKLOG.md"

echo "=== Next Available Tickets ==="
echo ""

echo "--- Sprint Queue ---"
awk '/^## Queue/,/^---/' "$SPRINT" | grep -E '^\s*[-*]\s+\*\*T-' | head -10 | sed 's/^/  /' || echo "  (empty)"
echo ""

# Use python3 for reliable multi-line ticket parsing
echo "--- High Priority (unassigned, unblocked) from Backlog ---"
python3 - "$BACKLOG" high <<'PYEOF'
import sys, re

path = sys.argv[1]
pri_filter = sys.argv[2]
text = open(path).read()

# Split on ticket boundaries
blocks = re.split(r'\n(?=### T-)', text)
results = []
for block in blocks:
    m = re.match(r'### (T-\d+)', block)
    if not m:
        continue
    tid = m.group(1)
    title_m = re.search(r'- Title: (.+)', block)
    title = title_m.group(1).strip() if title_m else "?"
    pri_m = re.search(r'- Priority: (\S+)', block)
    priority = pri_m.group(1).strip() if pri_m else ""
    assigned_m = re.search(r'- Assigned: (\S+)', block)
    assigned = assigned_m.group(1).strip() if assigned_m else ""
    blocked_m = re.search(r'- Blocked-by: (.+)', block)
    blocked = blocked_m.group(1).strip() if blocked_m else "—"
    if priority == pri_filter and assigned == "unassigned" and not blocked.startswith("T-"):
        results.append(f"  {tid}: {title}")
for r in results[:5]:
    print(r)
PYEOF

echo ""
echo "--- Medium Priority (unassigned, unblocked) from Backlog ---"
python3 - "$BACKLOG" medium <<'PYEOF'
import sys, re

path = sys.argv[1]
pri_filter = sys.argv[2]
text = open(path).read()

blocks = re.split(r'\n(?=### T-)', text)
results = []
for block in blocks:
    m = re.match(r'### (T-\d+)', block)
    if not m:
        continue
    tid = m.group(1)
    title_m = re.search(r'- Title: (.+)', block)
    title = title_m.group(1).strip() if title_m else "?"
    pri_m = re.search(r'- Priority: (\S+)', block)
    priority = pri_m.group(1).strip() if pri_m else ""
    assigned_m = re.search(r'- Assigned: (\S+)', block)
    assigned = assigned_m.group(1).strip() if assigned_m else ""
    blocked_m = re.search(r'- Blocked-by: (.+)', block)
    blocked = blocked_m.group(1).strip() if blocked_m else "—"
    if priority == pri_filter and assigned == "unassigned" and not blocked.startswith("T-"):
        results.append(f"  {tid}: {title}")
for r in results[:5]:
    print(r)
PYEOF
echo ""

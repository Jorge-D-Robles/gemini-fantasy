---
name: review-tutorial
description: Review tutorial modules for completeness, correctness, and self-sufficiency. Runs adversarial and neutral reviewers in parallel, synthesizes their consensus, then applies required changes. Use to ensure the tutorial is a complete standalone JRPG learning resource.
argument-hint: [module numbers or "all"] e.g. "1-5", "11", "all"
---

# Tutorial Review

Run adversarial and neutral tutorial reviewers in parallel, synthesize their consensus, and apply the required changes.

**Target:** $ARGUMENTS

## Step 1 — Determine Scope

Parse the target to determine which modules to review:
- `all` → review all 21 modules (review in batches of 5-6 to keep context manageable)
- `1-5` → review modules 1 through 5
- `11` → review module 11 only
- No argument → review all modules

Build the list of module files from `tutorial/` (e.g., `tutorial/01_the_journey_begins.md` through `tutorial/21_finish_line.md`).

## Step 2 — Launch Both Reviewers in Parallel

Spawn **both reviewers simultaneously** as parallel Agent calls:

```
Agent(subagent_type="tutorial-reviewer-adversarial", model="opus", prompt="""
Review the following tutorial modules for completeness, correctness, and self-sufficiency.

Target modules: <list of module filenames>

Instructions:
1. Read tutorial/PLAN.md first for full context (design principles, spiral learning plan, demo game scope)
2. Read tutorial/REGRESSION.md — this is the regression checklist. Verify every item that applies to your target modules. Flag any regressions as CRITICAL.
3. Read each target module thoroughly
4. Read adjacent modules (one before and one after each target) for continuity
5. Check docs/best-practices/ for Godot convention alignment
6. Verify Godot API claims against docs/godot-docs/classes/ when the module makes specific API assertions
7. Produce your full adversarial review following your output format
""")

Agent(subagent_type="tutorial-reviewer-neutral", model="opus", prompt="""
Review the following tutorial modules for pedagogical quality, pacing, and practical completeness.

Target modules: <list of module filenames>

Instructions:
1. Read tutorial/PLAN.md first for full context (design principles, spiral learning plan, demo game scope)
2. Read tutorial/REGRESSION.md — this is the regression checklist. Verify relevant items haven't regressed. Report any regressions as high-priority concerns.
3. Read each target module thoroughly
4. Read adjacent modules for continuity and flow assessment
5. Check docs/best-practices/ for convention alignment
6. Produce your full neutral review following your output format
""")
```

## Step 3 — Synthesize Consensus

After both reviewers return, synthesize their findings:

### Consensus Rules
- **Both APPROVE** → No changes needed. Summarize strengths and any minor notes.
- **Both REJECT** → Fundamental rework needed. List all blocking issues from both reviewers.
- **One APPROVE, one REVISE** → Apply the revision suggestions. The approving reviewer's strengths list validates what to preserve.
- **Both REVISE** → Apply all revision suggestions. Prioritize issues both reviewers flagged.
- **Any REJECT + other REVISE** → Major rework needed. Address all CRITICAL issues before minor ones.

### Priority Triage

Merge both reviewers' issue lists and deduplicate. Classify each issue:

| Priority | Criteria | Action |
|----------|----------|--------|
| **P0 — Blocking** | Reader WILL get stuck. Both reviewers agree. | Fix immediately |
| **P1 — Important** | Reader might struggle. At least one reviewer flags as CRITICAL/MODERATE. | Fix in this pass |
| **P2 — Quality** | Improvement that makes the tutorial better but reader can proceed without it. | Fix if time permits |
| **P3 — Polish** | Style, minor wording, nice-to-have additions. | Track for later |

When reviewers disagree on severity:
- If the adversarial reviewer says CRITICAL and neutral says it's overcritical → treat as P1 (important but not blocking)
- If the neutral reviewer flags something the adversarial missed → treat at the neutral reviewer's severity level
- If both flag the same issue → use the higher severity

## Step 4 — Apply Changes

Work through the prioritized issue list, editing tutorial module files directly:

1. **P0 issues first** — Fix every blocking issue before moving on
2. **P1 issues second** — Fix all important issues
3. **P2 issues if scope permits** — Apply quality improvements
4. **Skip P3** — These are tracked but not applied in this pass

For each change:
- Read the relevant section of the module file
- Apply the fix using the Edit tool
- Verify the fix addresses both reviewers' concerns where applicable
- If a fix requires cross-module changes (e.g., updating a forward reference in module 5 that points to module 11), apply changes to all affected modules

### Types of Changes to Apply

- **Missing code:** Add complete, runnable code blocks with proper GDScript 4.x syntax
- **Missing explanations:** Add "why" context, gotcha warnings, or concept introductions
- **Broken cross-references:** Fix module numbers, concept names, and callback citations
- **Incorrect Godot API usage:** Fix class names, method signatures, property names to match Godot 4.x
- **Missing doc references:** Add links to specific Godot doc pages (use `docs/godot-docs/` path structure to verify)
- **Pacing issues:** Split overloaded sections, merge thin sections, add or remove runnable checkpoints
- **Missing "What You Should See" sections:** Add verification steps at module end
- **Incomplete scene trees:** Add full node hierarchy descriptions
- **Missing file paths:** Add explicit paths for every file the reader creates

## Step 5 — Summary Report

After applying changes, output a summary:

```markdown
## Tutorial Review Summary

### Reviewers
- **Adversarial:** Score X/5 — <key finding>
- **Neutral:** Score X/5 — <key finding>
- **Consensus:** <APPROVE / REVISE / REJECT>

### Changes Applied
| Module | P0 Fixes | P1 Fixes | P2 Fixes | Description |
|--------|----------|----------|----------|-------------|
| 01     | 0        | 2        | 1        | Added missing scene tree, fixed API name |
| ...    | ...      | ...      | ...      | ... |

### Total: X changes across Y modules

### Remaining P3 Items (not applied)
- <Module N:> <issue description>

### Self-Sufficiency Assessment
Can a reader complete the full tutorial without external resources? [Yes / Mostly / No]
- <Explanation of any remaining gaps>
```

## Step 6 — Update Regression Checklist

After applying changes, update `tutorial/REGRESSION.md` with any NEW issues that were found and fixed in this pass. This ensures future review runs can verify these fixes haven't regressed.

For each new fix applied:
1. Determine which category it belongs to (API Correctness, Cross-Module Data Consistency, Input Handling, etc.)
2. Add a checkbox item with: the rule, which modules it affects, and why it matters
3. If a fix spans multiple modules, list all affected modules

Do NOT remove existing items from the regression checklist. They are cumulative across all review passes.

## Important Notes

- **Never invent game mechanics or story content.** If the tutorial references Crystal Saga specifics, preserve them as-is.
- **Preserve the author's voice.** Fixes should match the existing writing style — approachable, direct, programmer-to-programmer.
- **Don't over-expand.** A tutorial that's too long is as bad as one that's too short. Add only what's needed.
- **Verify Godot API claims.** When fixing code, check against `docs/godot-docs/classes/` to ensure accuracy.
- **Maintain spiral learning.** When adding content, check if it should reference earlier or later modules.
- **Update PLAN.md if needed.** If changes alter a module's scope or topic coverage, update the corresponding entry in `tutorial/PLAN.md`.

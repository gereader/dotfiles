---
name: spec-to-tasks
description: Convert a project spec into a grouped, dependency-aware markdown task list (TASKS.md)
disable-model-invocation: true
argument-hint: "[path to spec file]"
---

# Spec to Tasks

You are converting a project spec into an actionable task breakdown.

## Step 1: Find the Spec

- If `$ARGUMENTS` is provided, treat it as a path to the spec file.
- If not, look for spec documents in `docs/` in the current project.
- If multiple specs exist, ask which one to use.
- If no spec exists, suggest running `/write-spec` first.

Read the spec fully before proceeding.

## Step 2: Break Down Tasks

Create a `TASKS.md` file in the project root. If one already exists, ask whether to replace it or append to it.

**Structure:**

```markdown
# Tasks

## Legend
- 🟢 Independent — can be worked in parallel with other independent tasks
- 🔗 Depends on — must wait for specified tasks to complete
- 🔒 Blocks — other tasks depend on this completing first

## Phase 1: [Phase Name]

- [ ] **T1: [Task name]** 🟢
  Brief description of what to do.

- [ ] **T2: [Task name]** 🟢
  Brief description of what to do.

## Phase 2: [Phase Name]

- [ ] **T3: [Task name]** 🔗 T1, T2
  Brief description of what to do.

- [ ] **T4: [Task name]** 🟢
  Brief description of what to do.

## Parallel Work Guide

### Can run simultaneously
- T1, T2, T4 (no dependencies between them)

### Sequential chains
- T1 → T3 (T3 needs T1's output)
- T2 → T3 (T3 needs T2's output)
```

**Task guidelines:**
- Each task should be completable in a single focused session (not days of work, not 5 minutes of work).
- Use task IDs (T1, T2, ...) so dependencies are easy to reference.
- Every task gets a dependency marker: 🟢 independent, or 🔗 with the IDs it depends on.
- Group by phase/milestone from the spec.
- End with a "Parallel Work Guide" section that summarizes which tasks can be farmed out to subagents simultaneously and which chains must run sequentially.

## Step 3: Summary

After saving, give a quick summary: how many tasks, how many phases, and what the critical path looks like (the longest sequential chain).

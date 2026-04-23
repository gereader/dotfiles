---
name: spec-to-tasks
description: Convert a project spec into a grouped, dependency-aware markdown task list (TASKS.md). Use when the user has a spec and wants to break it into actionable tasks with dependency tracking and parallel work guidance.
---

# Spec to Tasks

You are converting a project spec into an actionable, implementation-ready task breakdown.

Your goal is NOT to maximize the number of tasks.
Your goal is to produce a realistic, dependency-aware plan that can actually be executed.

---

## Step 1: Find the Spec

* If `$ARGUMENTS` is provided, treat it as a path to the spec file.
* If not, look for spec documents in `docs/` in the current project.
* If multiple specs exist, ask which one to use.
* If no spec exists, suggest running `$write-spec` first.

Read the spec fully before proceeding.

---

## Step 2: Break Down Tasks

Create a `TASKS.md` file in the project root.
If one already exists, ask whether to replace it or append to it.

---

## Structure

```markdown
# Tasks

## Legend
- Independent — can be worked in parallel with other independent tasks
- Depends on — must wait for specified tasks to complete
- Blocks — other tasks depend on this completing first

## Phase 1: [Phase Name]

- [ ] **T1: [Task name]** Independent
  Brief description of what to do.
  _Verify: how to confirm this task is complete_

- [ ] **T2: [Task name]** Depends on T1
  Brief description of what to do.
  _Verify: how to confirm this task is complete_

## Phase 2: [Phase Name]

- [ ] **T3: [Task name]** Depends on T1, T2
  Brief description of what to do.
  _Verify: how to confirm this task is complete_

## Parallel Work Guide

### Can run simultaneously
- T1, T4

### Sequential chains
- T1 → T2 → T3
```

---

## Task Generation Rules

### Scope discipline

* Do NOT create tasks for:

  * post-MVP features
  * open questions
  * future optimizations
* Only include what is explicitly in scope for the current milestones.

---

### Use the spec properly

* Preserve milestone/phase boundaries exactly as defined in the spec.
* Use milestone acceptance criteria to shape tasks.
* Do NOT convert every bullet point into a task.
* Combine related work into a single task when it belongs together.

---

### Task sizing

* Each task should be completable in a single focused session.
* Avoid:

  * 5-minute trivial tasks
  * multi-day “mega tasks”
* Default to ~5–10 tasks per phase unless clearly justified.

---

### Implementation boundaries

* Create tasks based on real implementation units:

  * files
  * modules
  * contracts
  * integrations
* Prefer tasks that produce concrete artifacts.

Examples:

* create `shared/scripts/delegate.py`
* define `delegation-result.v1.json`
* implement supervisor routing logic

---

### Dependencies (critical)

* Be conservative with **Independent**.
* A task is only Independent if it requires NOTHING from other tasks.

Most early tasks are NOT independent.

Common blockers:

* shared schemas
* delegation wrapper
* repo scaffolding
* env contract
* supervisor shell

---

### Cross-cutting work

* Identify foundational tasks early:

  * schemas
  * wrapper
  * base structure
  * config
* Later tasks should depend on these, not duplicate them.

---

### File awareness

* When the spec references files or directories:

  * include them in task descriptions
* Prefer concrete outputs over abstract work.

---

### Verification

* Add a short `_Verify:` line for each task when useful.
* Focus on observable completion:

  * file exists
  * command runs
  * output matches expectation
  * contract validated

---

## Preflight Check (Before Writing Output)

Before generating `TASKS.md`, validate:

* No tasks were created from out-of-scope or post-MVP items
* No major dependency mistakes (false “Independent”)
* No over-splitting into tiny tasks
* No overly large, vague tasks
* Foundational work appears early in the critical path

---

## Step 3: Summary

After saving `TASKS.md`, provide:

* total number of phases
* total number of tasks
* the critical path (longest dependency chain)
* a brief note on where parallel work is actually safe

---

## Output Expectations

* Clean, readable markdown
* Realistic sequencing
* Minimal ambiguity
* Optimized for execution, not completeness theater

---
name: write-spec
description: Produce a structured project spec, generate/update AGENTS.md and architecture docs for a project. Use when the user wants to formalize a project plan, write requirements, or create project documentation.
---

# Write Spec

You are helping the user produce a structured project specification, along with AGENTS.md and architecture documentation.

## Step 1: Gather Context

**Check what already exists in the project:**
- Look for an existing grill-me summary in `docs/`
- Read existing AGENTS.md if present
- Read existing architecture docs in `docs/` if present
- Scan the project structure and key source files

**If the project appears significantly broader than what the user is focused on** (large existing codebase, many modules unrelated to the current topic), flag it: "This project covers more than what we're speccing — you might want to run `$audit-project` first to map the full project. Up to you."

**If `$ARGUMENTS` is provided**, use it as the starting point. If a grill-me summary exists, use that as the foundation. If invoked mid-conversation, use conversation context.

## Step 2: Discovery (if needed)

If there isn't enough context to write a spec, run inline discovery:
- Check the codebase, AGENTS.md, conversation history, and general knowledge before asking anything.
- Lead with assumptions: "I'm assuming X — that right?"
- One or two questions at a time.
- Keep going until you can write the spec, or the user says to wrap up.

## Step 3: Write the Spec

Save a structured spec to `docs/` in the current project. Create the directory if needed.

**Spec structure:**
```markdown
# [Project/Feature Name] — Spec

## Problem Statement
What problem are we solving and why.

## Goals
- Specific outcomes we're targeting

## Non-Goals / Out of Scope
- What we're explicitly not doing

## Requirements
### Functional
- What it should do

### Non-Functional
- Performance, security, compatibility constraints

## Architecture / Approach
High-level approach. How components fit together.

## Key Decisions
- Decisions made and their rationale

## Open Questions
- Unresolved items

## Task Breakdown
- High-level phases or milestones (not granular tasks — that's `$spec-to-tasks`)
```

## Step 4: AGENTS.md

**Always ensure an AGENTS.md exists after this step.**

- If no AGENTS.md exists: create one with project-specific instructions derived from the spec.
- If one exists: surgically update or append only sections relevant to the current spec. Do not modify or remove content unrelated to this spec work. Preserve existing instructions, conventions, and context.

The AGENTS.md should help the coding agent work effectively on this project — coding conventions, architecture decisions, key files, things to watch out for.

## Step 5: Architecture Docs

**Always ensure architecture documentation exists after this step.**

- If no architecture docs exist in `docs/`: create them — at minimum a high-level overview of how the system is structured, key components, and how they interact.
- If architecture docs exist: update only sections relevant to the current spec. Don't overwrite unrelated content.

Scale the docs to the project — a small CLI tool needs a paragraph, not a 10-page design doc.

## Step 6: Fork

After saving everything, summarize what was created/updated and ask: "Want me to keep going and break this into tasks, or are you good for now?"

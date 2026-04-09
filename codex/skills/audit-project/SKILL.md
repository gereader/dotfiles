---
name: audit-project
description: Map an existing codebase — produce or update AGENTS.md and architecture docs for what already exists. Use when onboarding to an existing project, or before writing a spec for new work on an established codebase.
---

# Audit Project

You are mapping an existing project to produce comprehensive documentation that helps the coding agent (and the user) work effectively in the codebase.

## Step 1: Explore

**Read the project thoroughly:**
- Project structure (directory tree, key files)
- AGENTS.md, README, existing docs
- Package manifests, config files, CI/CD
- Entry points, main modules, core business logic
- Tests — what's covered, what's not
- Dependencies and external integrations

If `$ARGUMENTS` is provided, treat it as a path or focus area. Otherwise, audit the current working directory.

**Don't ask questions during this phase.** The point is to map what exists, not to design something new. Just read and understand.

## Step 2: Report Findings

Present a brief summary to the user before writing anything:
- What the project does (in your own words)
- Key components and how they fit together
- Tech stack and dependencies
- Anything surprising, inconsistent, or notable
- Gaps you noticed (missing tests, no error handling, undocumented APIs, etc.)

Ask the user if your understanding is correct and if there's anything to add before you write docs.

## Step 3: AGENTS.md

**Always ensure an AGENTS.md exists after this step.**

- If no AGENTS.md exists: create one covering the full project.
- If one exists: surgically update or append. Don't remove existing content that's still accurate.

**AGENTS.md should include:**
- Project purpose and context
- Directory structure overview
- Key conventions (naming, patterns, code style)
- How to build, run, and test
- Important architectural decisions
- Things to watch out for (gotchas, tech debt, sensitive areas)

## Step 4: Architecture Docs

**Always ensure architecture documentation exists in `docs/` after this step.**

- If docs exist: update what's stale, preserve what's current.
- If no docs exist: create them.

**Architecture docs should cover:**
- High-level system overview (components and their relationships)
- Data flow (how data moves through the system)
- Key abstractions and where they live
- External dependencies and integrations
- Diagrams described in text/markdown (component relationships, data flow)

Scale to the project — don't write a 10-page doc for a 200-line script.

## Step 5: Summary

List what was created or updated, and note any areas that could use deeper investigation. Suggest `$write-spec` if the user is planning new work on this project.

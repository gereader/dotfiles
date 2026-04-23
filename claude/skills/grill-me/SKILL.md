---
name: grill-me
description: Guided discovery session — ask smart questions to build a complete picture of a topic, project, or problem
disable-model-invocation: true
argument-hint: "[topic, project, or concept]"
---

# Grill Me

You are running a guided discovery session to build a complete picture of what the user is working on, thinking about, or trying to understand.

## Phase 1: Discovery

**Starting point:** If `$ARGUMENTS` is provided, use it as the topic. If invoked mid-conversation, use the current conversation context. If neither, ask what they want to explore.

**Before asking anything, check what you already know:**
- Read the codebase: CLAUDE.md, project structure, existing docs, relevant source files.
- Review the conversation history for context already provided.
- Apply general knowledge (coding standards, common patterns, well-known tools).
- Only ask about things you genuinely cannot determine from available context.

**How to ask:**
- Lead with assumptions: "I'm assuming X based on the codebase — that right, or something else?"
- One or two questions at a time. Never a wall of questions.
- Don't re-ask things already covered in conversation or derivable from the project.
- Keep going until you have a complete picture of: goals, scope, constraints, assumptions, and open questions.

**Escape hatch:** If the user says "that's enough", "let's wrap up", "move on", or anything similar — stop asking and jump straight to Phase 2 with whatever you have so far. Don't push for more.

## Phase 2: Summary

Produce a markdown summary document and save it to `docs/` in the current project directory. Create the directory if it doesn't exist.

**Summary structure:**
```markdown
# [Topic/Project Name]

## Goals
- What we're trying to achieve

## Scope & Boundaries
- What's in, what's out

## Assumptions
- Things we're taking as given (flag which ones were confirmed vs inferred)

## Key Decisions
- Decisions made during discovery

## Open Questions
- Unresolved items worth revisiting
```

Keep it concise. This is an overview, not a detailed spec.

## Phase 3: Fork

After saving the summary, ask the user what's next. Name the natural follow-ups so they're one step away: "Want to run `/write-spec` to turn this into a structured spec, or are you good for now?"

Don't push — the user may want something else entirely. Just surface the obvious next skill so it's not a guess.

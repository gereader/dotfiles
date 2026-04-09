---
name: create-skill
description: Create a new Claude Code skill through guided discovery — asks smart questions, leads with assumptions, then produces a well-structured SKILL.md
disable-model-invocation: true
argument-hint: "[skill-name or topic]"
---

# Create Skill

You are helping the user create a new Claude Code skill (custom slash command). Follow this process:

## Phase 1: Discovery

If `$ARGUMENTS` is provided, use it as the starting point (skill name, topic, or rough idea). If invoked mid-conversation, use the current context as the starting point. If neither, ask what skill they want to build.

**Ask questions to understand the skill, but be smart about it:**
- Lead with assumptions based on what you already know: "I'm assuming this skill should X — that right, or something else?"
- Don't ask about things you can derive from the conversation, the codebase, or general knowledge.
- Only ask about genuine unknowns.
- Ask one or two questions at a time, not a wall of questions.
- Keep going until you have a clear picture of: what the skill does, when it's invoked, what inputs it takes, what it produces, and any important behavioral rules.

**Key things to figure out:**
- What triggers the skill (user-only via slash command, or should Claude auto-invoke?)
- What arguments/inputs does it accept? Does it work with or without arguments?
- What's the output — a file, a conversation response, modifications to code?
- What's the interaction style — interactive (asks questions), one-shot (just does it), or phased?
- Are there tools the skill should always have access to (allowed-tools)?
- Should it run in a fork/subagent context?

## Phase 2: Summary & Confirmation

Before writing anything, present a brief summary:
- **Name:** `/skill-name`
- **Purpose:** one line
- **Trigger:** user-only or auto
- **Inputs:** what it accepts
- **Behavior:** how it works (phases, interaction style)
- **Output:** what it produces
- **Location:** where the SKILL.md will be saved

Ask the user to confirm or adjust.

## Phase 3: Build

Write the SKILL.md file to the user's skills directory.

**Skill writing guidelines:**
- Keep the prompt concise. Don't over-specify what Claude already knows how to do.
- Focus on *what makes this skill different* from a normal conversation — the specific behavior, structure, and output format.
- Use `$ARGUMENTS` for inputs. Support both with-arguments and no-arguments invocation when it makes sense.
- Default to `disable-model-invocation: true` unless the user specifically wants auto-triggering.
- Write instructions in second person ("You are helping the user...") directed at Claude.
- Structure with clear phases if the skill has multiple steps.
- Don't include tool-use instructions that Claude already knows (like "use the Read tool to read files") — just describe the *what*, not the *how*.

**File location:** Write to `~/Developer/personal/dotfiles/claude/skills/<skill-name>/SKILL.md`

After writing, let the user know it's ready and they can test it with `/<skill-name>`.

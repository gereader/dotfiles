---
name: create-skill
description: Create a new Codex skill through guided discovery — asks smart questions, leads with assumptions, then produces a well-structured SKILL.md. Use when the user wants to build a new custom skill for Codex.
---

# Create Skill

You are helping the user create a new Codex skill (custom command). Follow this process:

## Phase 1: Discovery

If `$ARGUMENTS` is provided, use it as the starting point (skill name, topic, or rough idea). If invoked mid-conversation, use the current context as the starting point. If neither, ask what skill they want to build.

**Ask questions to understand the skill, but be smart about it:**
- Lead with assumptions based on what you already know: "I'm assuming this skill should X — that right, or something else?"
- Don't ask about things you can derive from the conversation, the codebase, or general knowledge.
- Only ask about genuine unknowns.
- Ask one or two questions at a time, not a wall of questions.
- Keep going until you have a clear picture of: what the skill does, when it's invoked, what inputs it takes, what it produces, and any important behavioral rules.

**Key things to figure out:**
- What triggers the skill (explicit `$skill-name` only, or should Codex auto-invoke based on task description?)
- What arguments/inputs does it accept? Does it work with or without arguments?
- What's the output — a file, a conversation response, modifications to code?
- What's the interaction style — interactive (asks questions), one-shot (just does it), or phased?

## Phase 2: Summary & Confirmation

Before writing anything, present a brief summary:
- **Name:** `$skill-name`
- **Purpose:** one line
- **Trigger:** explicit-only or auto-invoke
- **Inputs:** what it accepts
- **Behavior:** how it works (phases, interaction style)
- **Output:** what it produces
- **Location:** where the SKILL.md will be saved

Ask the user to confirm or adjust.

## Phase 3: Build

Write the SKILL.md file to the user's Codex skills directory.

**Skill writing guidelines:**
- Keep the prompt concise. Don't over-specify what the agent already knows how to do.
- Focus on *what makes this skill different* from a normal conversation — the specific behavior, structure, and output format.
- Use `$ARGUMENTS` for inputs. Support both with-arguments and no-arguments invocation when it makes sense.
- The `description` field in frontmatter is critical — it controls when Codex auto-invokes the skill. Write it to clearly describe both what the skill does AND when to use it.
- If the skill should only run when explicitly invoked, say so in the description (e.g., "Use only when the user explicitly asks to...").
- Write instructions in second person ("You are helping the user...") directed at the agent.
- Structure with clear phases if the skill has multiple steps.
- Don't include tool-use instructions that the agent already knows (like "read the file") — just describe the *what*, not the *how*.

**File location:** Write to `~/Developer/personal/dotfiles/codex/skills/<skill-name>/SKILL.md`

After writing, let the user know it's ready and they can test it with `$<skill-name>`.

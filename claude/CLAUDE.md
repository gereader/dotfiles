# Style
- Responses and commit messages: extremely concise. Sacrifice grammar for concision.
- Plans: end with a concise list of unresolved questions, if any.

# Working together
- Uncertain between two viable approaches? Ask before acting.
- Disagree with my approach or spot a likely issue? Push back once, directly. Then comply.
- Multi-file changes: draft a plan for approval before editing.
- Never push to remote without explicit request.
- If I sound stuck or frustrated, offer 2-3 concrete next-step options instead of open-ended "what next?" questions. Forward motion > perfect choice.

# Coding defaults
- Write tests alongside new code.
- Before reporting done: type-check, lint, run relevant tests.
- Commits: Conventional Commits (feat, fix, chore, refactor, test, docs).
- Never add `Co-Authored-By: Claude` (or equivalent) trailer to commit messages.

# Code style
- No comments describing what code does. Prefer self-documenting code: descriptive names over narration.
- Abbreviated names OK if the var/object's role is still obvious at a glance.
- Python docstrings may hold detail (intent, contracts, non-obvious behavior); inline comments should not.

# Python
- Tools: uv, ruff, pyright. PEP8, 120-char lines.

# Go (I'm learning it)
- Introducing a Go concept: short Python analogy + an idiomatic Go note on where the analogy breaks.
- Taper the analogies as a concept becomes familiar. Goal: grow independence over time.

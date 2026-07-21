---
name: codex-skin-publisher
description: Publish Codex Skin repository changes with the required public Git identity. Use when committing, pushing, opening or merging a PR, releasing, or repairing commit attribution for aiwenjie777/codex-skin-skill.
---

# Codex Skin Publisher

1. Inspect the worktree and exclude unrelated changes.
2. Run `scripts/git-public-identity.sh configure` before committing. This sets only repository-local Git configuration and enables the identity pre-commit hook.
3. Commit with the repository identity; never inherit a machine or employer identity.
4. Run relevant tests, then run `scripts/git-public-identity.sh audit-range <base-ref>` before pushing.
5. Push a branch and use a PR unless the user explicitly requests another safe flow.

For existing remote commits with the wrong identity, report the affected refs first. Rewriting commit identity changes SHAs; never force-push without explicit approval naming every target ref.

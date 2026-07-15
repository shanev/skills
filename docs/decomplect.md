# Decomplect

Decomplect reviews architecture through simplicity, functional core/imperative shell, and
cohesion/coupling. It looks for demonstrated correctness, testability, reasoning, and change
costs rather than enforcing a preferred style.

## Language-agnostic analysis

The skill reasons about state, effects, policy, boundaries, dependency direction, and change
propagation using each repository's own languages and conventions. Language constructs are
signals, not verdicts: mutation, objects, exceptions, callbacks, dependency injection, and pure
functions can all be appropriate in context.

## Scope

Give the skill files, directories, snippets, diffs, commits, branches, pull-request refs, or an
entire repository. Without an explicit scope, it reviews working-tree changes. When the working
tree is clean, it reviews the current branch from its merge base with the detected remote
default branch. It never assumes the default branch is `main`.

## Output

Findings are ordered by severity and include a precise location, lens, confidence, evidence,
impact, and proportionate recommendation. Candidates below 80% confidence and preferences
without demonstrated cost are omitted. The skill does not grade code and does not modify it
unless asked.

## Installation

Install globally for all supported coding agents:

```bash
npx skills add shanev/skills --skill decomplect --agent '*' -g -y
```

Claude Code users may alternatively install the plugin:

```bash
/plugin marketplace add shanev/skills
/plugin install decomplect@shanev-skills
```

Claude Code supports `/decomplect:decomplect`, `--simplicity`, `--fcis`, `--coupling`, and
`--sequential`. Other agents follow the portable `SKILL.md` workflow directly.

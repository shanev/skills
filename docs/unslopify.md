# Unslopify

Unslopify reviews contract strength, single responsibility, failure integrity, and duplicated
knowledge. It focuses on concrete correctness, debugging, maintenance, and change-propagation
costs instead of treating code smells as automatic defects.

## Language-agnostic analysis

The skill uses the strongest mechanisms idiomatic to each ecosystem. Static types, dynamic
validation, schemas, protocols, tests, result values, exceptions, optionals, retries, and
fallbacks are evaluated as different ways to express contracts and failure policy—not as
universally good or bad syntax.

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
npx skills add shanev/skills --skill unslopify --agent '*' -g -y
```

Claude Code users may alternatively install the plugin:

```bash
/plugin marketplace add shanev/skills
/plugin install unslopify@shanev-skills
```

Claude Code supports `/unslopify:unslopify`, `--types`, `--srp`, `--fail-fast`, `--dry`, and
`--sequential`. Other agents follow the portable `SKILL.md` workflow directly.

# Skill evaluations

`cases.json` contains three minimum behaviors for every analyzer:

- `positive`: a concrete issue the analyzer should report
- `clean`: a straightforward design that should produce no finding
- `trap`: a smell-like pattern that should not become a false positive

The artifacts deliberately span typed, dynamic, and pseudocode examples so evaluations test
semantic reasoning rather than syntax matching.

Validate fixture structure and coverage with:

```bash
python3 evals/validate.py
```

For behavioral evaluation, give a fresh agent only the target skill, the case's `request`, and
its `artifact`. Compare the result with `expectation`; do not reveal the expectation beforehand.

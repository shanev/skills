#!/usr/bin/env python3
"""Validate structural coverage of the language-agnostic skill evaluation cases."""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parent
EXPECTED = {
    "decomplect": {"simplicity", "functional-core", "coupling"},
    "unslopify": {"contracts", "responsibility", "failure-integrity", "duplication"},
}
KINDS = {"positive", "clean", "trap"}
REQUIRED_FIELDS = {"id", "analyzer", "kind", "request", "artifact", "expectation"}


def main() -> None:
    data = json.loads((ROOT / "cases.json").read_text())
    seen_ids: set[str] = set()

    for skill, analyzers in EXPECTED.items():
        cases = data.get(skill)
        if not isinstance(cases, list):
            raise SystemExit(f"{skill}: expected a list of cases")

        coverage: Counter[tuple[str, str]] = Counter()
        for case in cases:
            missing = REQUIRED_FIELDS - case.keys()
            if missing:
                raise SystemExit(f"{skill}: case missing fields: {sorted(missing)}")
            if case["id"] in seen_ids:
                raise SystemExit(f"duplicate case id: {case['id']}")
            seen_ids.add(case["id"])
            if case["analyzer"] not in analyzers:
                raise SystemExit(f"{case['id']}: unknown analyzer {case['analyzer']}")
            if case["kind"] not in KINDS:
                raise SystemExit(f"{case['id']}: unknown kind {case['kind']}")
            for field in REQUIRED_FIELDS:
                if not isinstance(case[field], str) or not case[field].strip():
                    raise SystemExit(f"{case['id']}: {field} must be a non-empty string")
            coverage[(case["analyzer"], case["kind"])] += 1

        missing_coverage = [
            f"{analyzer}/{kind}"
            for analyzer in sorted(analyzers)
            for kind in sorted(KINDS)
            if coverage[(analyzer, kind)] == 0
        ]
        if missing_coverage:
            raise SystemExit(f"{skill}: missing coverage: {', '.join(missing_coverage)}")

    extra_skills = set(data) - set(EXPECTED)
    if extra_skills:
        raise SystemExit(f"unexpected skill groups: {sorted(extra_skills)}")

    print(f"Validated {len(seen_ids)} cases across {sum(map(len, EXPECTED.values()))} analyzers.")


if __name__ == "__main__":
    main()

---
title: "[Capability Title]"
capability: "[capability-id]"
description: "[One-line summary of what this capability does]"
lastUpdated: "[YYYY-MM-DD]"
---

# [Capability Title]

[1-2 sentence overview derived from user stories or requirements.]

## Why This Exists

[1-3 sentences from proposal.md "Why" section of the relevant archive.
 Rewrite in user-facing language.
 OMIT this section if no archive data or initial-spec-only with no useful Purpose.]

<!-- initial-spec fallback — how to write "Why This Exists" from spec Purpose:

BAD (restating Purpose): "A consistent spec format is essential for both human
readability and system automation."

GOOD (problem-framing): "Without a consistent spec format, scenarios break
automated parsing, normative language becomes ambiguous, and delta specs can't
be reliably merged into baselines."

When deriving "Why This Exists" from spec Purpose for initial-spec-only capabilities:
- Frame as what problem the capability solves, not what it is
- Consider what would happen WITHOUT this capability
- Use the spec's User Stories ("so that...") for motivation
- Keep the same narrative tone as enriched docs
-->

## Background

[3-5 sentences summarizing research context: what was investigated,
 key findings, alternatives explored. Derived from research.md.
 OMIT this section entirely if research.md is trivial or missing.]

## Design Rationale

[3-5 sentences for initial-spec-only capabilities ONLY.
 Derived from the initial-spec archive's research.md (approaches, decisions)
 or from the spec's Assumptions section.
 Explains why this specific design was chosen.
 OMIT for enriched capabilities — they get this context through Background
 and Known Limitations already.
 OMIT if initial-spec research.md lacks useful data for this capability.]

## Features

- [Bullet list of what users can do — derived from stories/requirements]

## Behavior

<!-- For capabilities that involve multiple commands or phases
     (e.g., quality-gates covers /opsx:preflight and /opsx:verify),
     add a brief workflow sequence note at the TOP of this section:
     "Run /opsx:preflight before tasks (pre-implementation).
      Run /opsx:verify after implementation (post-implementation)."
-->

### [Feature Group]

[Plain-language description of key scenarios. Derived from Gherkin scenario
 titles and WHEN/THEN structure. Group related scenarios.]

## Known Limitations

- [design.md Non-Goals rewritten as "Does not support X"]
- [design.md Risks rewritten as user-relevant limitations]
- [preflight.md assumptions rated "Acceptable Risk" that affect users]
[Max 5 bullets. OMIT this section entirely if empty.]

## Edge Cases

<!-- ONLY include surprising states, error conditions, or non-obvious interactions.
     Normal flow variants and expected UX behaviors belong in Behavior.
     Test: would a user be SURPRISED by this behavior? If not, it's Behavior. -->

- [Edge case description]

---
name: docs
description: Generate or update user-facing documentation from merged specs. Run after /opsx:archive to create capability docs and a table of contents.
disable-model-invocation: false
---

# /opsx:docs — Generate User Documentation

> Run this **after** `/opsx:archive` to generate or update user-facing documentation.

**Input**: Optional argument:
- No argument → regenerate all capability docs
- A capability name (e.g., `auth`) → regenerate only that capability's docs

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:init` first and stop.

### Step 1: Discover Specs

Glob `openspec/specs/*/spec.md` to find all available capabilities. The directory name is the capability ID.

If a capability name argument was given, process only that one (error if not found).

### Step 2: Extract Features

From each spec, extract (in order of preference):
- **User Stories** (primary — the "User Stories" section)
- **Fallback:** If no User Stories section exists, derive features from Requirements + Scenario titles (OpenSpec standard format)
- **Scenario titles** (from Gherkin scenarios — always include regardless of format)
- **Edge Cases** (from Edge Cases section, if present)
- **Capability name** (from the spec directory name)

### Step 3: Generate Documentation

For each capability, write or update `docs/capabilities/<capability>.md`:

```markdown
---
title: "[Capability Title]"
capability: "[capability-id]"
description: "[One-line summary of what this capability does]"
order: [number]
lastUpdated: "[YYYY-MM-DD]"
---

# [Capability Title]

[1-2 sentence overview derived from user stories or requirements.]

## Features

- [Bullet list of what users can do — derived from stories/requirements]

## Behavior

### [Feature Group]

[Plain-language description of key scenarios. Derived from Gherkin scenario titles and WHEN/THEN structure. Group related scenarios.]

## Edge Cases

- [All edge cases from the spec, rewritten in user-facing language. Include every edge case — do not drop any.]
```

#### YAML Frontmatter Fields

| Field | Description |
|-------|-------------|
| `title` | Human-readable capability name |
| `capability` | Machine-readable ID (matches spec directory name) |
| `description` | One-line summary for the table of contents |
| `order` | Display order in the TOC (lower = higher) |
| `lastUpdated` | Date of last generation (`YYYY-MM-DD`) |

#### Mapping Rules

| Spec Element | Doc Element |
|---|---|
| User Story title + motivation | Features bullet |
| Gherkin scenario title | Behavior subsection |
| GIVEN/WHEN/THEN detail | Plain-language example under behavior |
| Edge Cases section | Edge Cases (simplified) |
| Technical terms (API, DB, etc.) | Replaced with plain-language or omitted |
| Product names (OpenSpec, Claude Code, etc.) | **Preserved as-is** — never abstract product names into generic terms |
| Implementation details (file paths, configs) | Omitted entirely |
| User-facing syntax/markers (`<!-- ASSUMPTION -->`, `<!-- REVIEW -->`, `[P]`, etc.) | **Included** — if users need to recognize or use a syntax convention, document it |

### Step 4: Update Table of Contents

Create or update `docs/README.md` with a linked table of all capability documents, ordered by the `order` frontmatter field:

Generate a markdown table. Each capability title links to its doc file under `capabilities/`. Use the capability ID as filename.

```
# Documentation

| Capability | Description |
|---|---|
| Capability Title (linked) | One-line summary (from frontmatter `description`) |
```

### Step 5: Confirm

Show the user which docs were created/updated and a summary of changes.

---

## Output On Success

```
## Docs Generated

**Generated**: N capability docs + README
**Output**: `docs/capabilities/<capability>.md` + `docs/README.md`

### Capabilities
- [x] Capability Title (capability-id)
- [x] ...

### Skipped (no changes)
- ...
```

## Output When No Specs

```
## Docs

No specs found in openspec/specs/. Run /opsx:archive first to merge specs.
```

## Quality Guidelines

- Write for **end users**, not developers
- No technical jargon, no implementation details
- Use present tense ("You can...", "The system...")
- Each capability doc should be self-contained and understandable on its own
- Keep it concise: 1-2 pages per capability maximum
- Focus on WHAT users can do, not HOW the system implements it

## Guardrails

- Always read the spec file before generating — do not generate from memory
- If a spec has no User Stories and no Requirements section, skip it and warn
- If a doc file already exists, update it — don't overwrite manual additions
- Preserve existing docs for specs not being regenerated (single-capability mode)
- The overview page (`docs/README.md`) must always be regenerated — it links all capabilities
- Use consistent terminology across all generated docs
- **Internal consistency check**: After generating each doc, verify that the Behavior section and Edge Cases section do not contradict each other. If an edge case qualifies a behavior (e.g., "X is blocked, unless user explicitly confirms"), the behavior section must reflect the nuance — not state an absolute that the edge case then contradicts.

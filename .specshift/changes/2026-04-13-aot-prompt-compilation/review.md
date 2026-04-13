## Review: AOT Prompt Compilation

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 7/7 implementation tasks complete |
| Requirements | 6/6 new/modified requirements verified |
| Scenarios | 15/15 covered |
| Tests | Manual only (no framework) — scenarios verified via implementation |
| Scope | Clean — all 40 changed files trace to tasks or design |

### Metric Check

| Metric | Target | Actual | Result |
|--------|--------|--------|--------|
| Token reduction (propose) | < 350 lines | 324 lines (vs ~700 JIT) | PASS |
| Self-contained plugin | `.claude/` has SKILL.md, actions, templates, plugin.json | All present (20 files) | PASS |
| Compilation correctness | 4 actions, count match | 36/36, 0 warnings | PASS |
| Standard plugin layout | `.claude-plugin/`, `skills/`, auto-discovery | Correct layout, `source: "./.claude"` | PASS |

### Requirement Verification

**release-workflow.md (3 new requirements):**
- AOT Skill Compilation: `scripts/compile-skills.sh` loops `src/actions/*.md`, extracts from `docs/specs/`, copies source files, validates counts. Finalize step 4 in WORKFLOW.md. ✓
- Compiled Action File Contract: Files contain `# Requirements` + extracted blocks only. No frontmatter, no instructions. `src/actions/*.md` as manifest with clickable relative links. ✓
- Dev Sync Script: Bash-only, POSIX utilities, exits on missing source, prints summary. ✓

**release-workflow.md (3 modified requirements):**
- Source and Release Directory Structure: `src/` = source, `.claude/` = plugin root with standard layout. ✓
- Marketplace Source Configuration: `source: "./.claude"`, version via copied plugin.json. ✓
- Repository Layout Separation: Three-way separation (src, .claude, root). ✓

**workflow-contract.md (2 modified requirements):**
- Inline Action Definitions: Router reads instruction JIT from WORKFLOW.md + requirements AOT from compiled files. Links in `src/actions/` not SKILL.md. ✓
- Router Dispatch Pattern: Step 4 reads instruction + compiled requirements. Dispatch sections use "instruction as directive, bounded by requirements". ✓

### Scenario Spot-Checks

- **Finalize triggers AOT compilation**: Compiler copies source + generates 4 action files ✓
- **Count validation**: Tested with prefix-match fix for parenthetical headings — 36/36 ✓
- **Compiled file contains only requirements**: `head -3` shows `# Requirements` only ✓
- **Dev script outside repo root**: Checks for `src/skills/specshift/SKILL.md`, exits with error ✓
- **Marketplace points to plugin root**: `source: "./.claude"` in marketplace.json ✓
- **Plugin root resolves to .claude**: Standard layout with `.claude-plugin/`, `skills/`, `templates/` ✓
- **Router with instruction + requirements**: SKILL.md Step 4+5 reads both, dispatch says "bounded by strict requirements" ✓

### Design Adherence

| Decision | Verified |
|----------|----------|
| Instructions JIT, Requirements AOT | SKILL.md reads WORKFLOW.md + actions/*.md separately ✓ |
| Plugin root `.claude/` | marketplace source `./.claude`, standard layout ✓ |
| `src/actions/*.md` as compiler input | 4 files with relative links, compiler loops over them ✓ |
| No frontmatter in compiled files | `# Requirements` only, no YAML ✓ |
| Git persistence | `.gitignore` whitelists `.claude/skills/`, `.claude/.claude-plugin/` ✓ |
| Bash-only compiler | No Node/Python dependencies ✓ |

### Scope Control

All 40 changed files trace to the design:
- `scripts/compile-skills.sh` — compiler (task 1.1)
- `.claude/**` — release directory (design: compilation flow)
- `src/actions/*.md` — compiler input (design: src/actions)
- `src/skills/specshift/SKILL.md` — router update (task 2.1)
- `.specshift/WORKFLOW.md`, `src/templates/workflow.md` — finalize step (task 2.2-2.3)
- `.gitignore`, `.claude-plugin/marketplace.json` — config (task 2.4-2.5)
- `.specshift/CONSTITUTION.md`, `CLAUDE.md` — docs (task 2.6-2.7)
- `docs/specs/release-workflow.md`, `docs/specs/workflow-contract.md` — spec updates
- `.specshift/changes/**` — change artifacts

No untraced files.

### Findings

#### CRITICAL

(none)

#### WARNING

- **tasks.md is outdated**: The tasks.md was written before many design iterations (frontmatter removal, instruction/requirements separation, `src/actions/` split, `.claude/` as plugin root). It describes the original approach, not the final implementation. This is expected for an iterative change and does not affect the implementation.

#### SUGGESTION

(none)

### Verdict

**PASS**

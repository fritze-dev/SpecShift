# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-04-13 — Fix CLAUDE.md re-init drift + finalize version-bump conditionality

### Fixed
- CLAUDE.md bootstrap template is now checked during re-init — missing standard sections (Workflow, Knowledge Management) are reported as WARNING instead of going undetected (#10)
- Finalize version-bump step is now conditional on `plugin.json` existence — consumer projects without plugin manifests skip silently instead of encountering friction (#11)
- Template synchronization convention corrected: `src/templates/` is the authoritative plugin source, `.specshift/` is synced from it

### Added
- Edge Cases section added to release-workflow spec
- File Ownership section added to CLAUDE.md documenting `src/` vs `.specshift/` vs `docs/` distinction

## [0.1.0-beta] - 2026-04-12

Initial beta release. Complete restructuring and rebrand based on [opsx-enhanced-flow](https://github.com/fritze-dev/opsx-enhanced-flow).

# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-04-13 — Fix CLAUDE.md re-init drift + agnostic finalize version-bump

### Fixed
- CLAUDE.md bootstrap template is now checked during re-init — missing standard sections (Workflow, Knowledge Management) are reported as WARNING instead of going undetected (#10)
- Template synchronization convention corrected: `src/templates/` is the authoritative plugin source, `.specshift/` is synced from it

### Changed
- Consumer finalize version-bump step is now constitution-driven instead of plugin-specific — follows the version-bump convention from the project's constitution, skips if none defined (#11)
- Constitution generation now detects version files (package.json, pyproject.toml, Cargo.toml, etc.) during codebase scan and auto-generates a matching version-bump convention

### Added
- File Ownership section added to CLAUDE.md documenting `src/` vs `.specshift/` vs `docs/` distinction

## [0.1.0-beta] - 2026-04-12

Initial beta release. Complete restructuring and rebrand based on [opsx-enhanced-flow](https://github.com/fritze-dev/opsx-enhanced-flow).

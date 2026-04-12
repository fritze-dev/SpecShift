# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0-beta] - 2026-04-12

### Added
- SpecShift Beta — complete restructuring from OpenSpec/OPSX
- `.specshift/` hidden infrastructure directory (WORKFLOW.md, CONSTITUTION.md, templates, changes)
- `docs/specs/` flat spec files (14 capabilities)
- `specshift` skill with 4 actions: init, propose, apply, finalize
- `CLAUDE.md` as single agent entry point (replaces AGENTS.md + symlink)

### Changed
- Plugin name: `opsx` → `specshift`
- Skill name: `workflow` → `specshift`
- All paths: `openspec/` → `.specshift/` and `docs/specs/`
- All commands: `workflow <action>` → `specshift <action>`
- All branding: "OpenSpec"/"OPSX" removed from specs, templates, and skill

### Removed
- `openspec/` directory (restructured into `.specshift/` and `docs/`)
- `.agents/` directory (broken symlinks)
- `AGENTS.md` + `CLAUDE.md` symlink pattern
- Template duplication (local templates now managed via `specshift init`)

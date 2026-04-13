---
has_decisions: true
---
# Technical Design: AOT Prompt Compilation for Action Skills

## Context

Der Router-Skill (`src/skills/specshift/SKILL.md`) löst Requirements aktuell zur Laufzeit auf, indem er komplette Spec-Dateien aus `docs/specs/` liest. Dieser JIT-Ansatz verursacht ~50% Token-Overhead, verhindert eine saubere Distribution (Endnutzer haben keine Specs) und erhöht die Latenz.

Dieses Design führt einen AOT (Ahead-of-Time) Compilations-Step ein, der Requirements in statische Dateien extrahiert. Instructions bleiben projektspezifisch in WORKFLOW.md (JIT), Requirements werden vorkompiliert (AOT).

## Architecture & Components

### Compilation Flow

```
src/actions/*.md ────────────────┐
  (Requirement-Links pro Action) │
                                 │
src/skills/specshift/SKILL.md ───┤
  (Router, 1:1 kopiert)          │
                                 ├──→ scripts/compile-skills.sh ──→ .claude/
src/templates/ ──────────────────┤                                    ├── .claude-plugin/plugin.json
  (Smart Templates, kopiert)     │                                    └── skills/specshift/
                                 │                                        ├── SKILL.md
src/.claude-plugin/plugin.json ──┤                                        ├── actions/*.md (kompiliert)
                                 │                                        └── templates/
docs/specs/*.md ─────────────────┘
  (Requirement-Blöcke)
```

`src/` = authoritative Quelle (Hand-edit). `.claude/` = Plugin-Root und Release-Artefakt (generiert, in Git eingecheckt). Marketplace `source: "./.claude"`.

### Dateien

| Datei | Rolle |
|-------|-------|
| `src/skills/specshift/SKILL.md` | Router-Source — reines Runtime-Dokument, keine Spec-Links |
| `src/actions/{propose,apply,finalize,init}.md` | Compiler-Input — klickbare relative Links zu Specs |
| `src/templates/` | Template-Source |
| `src/.claude-plugin/plugin.json` | Version Source of Truth |
| `scripts/compile-skills.sh` | AOT Compiler — loopt über `src/actions/`, extrahiert, kopiert |
| `.claude/` | Plugin-Root (standard Layout: `.claude-plugin/`, `skills/`, alles in Git) |
| `.specshift/WORKFLOW.md` | Finalize-Instruction enthält Compile-Step |
| `.specshift/CONSTITUTION.md` | Release-Directory-Regel, AOT-Konvention |

### Compiler Algorithmus

1. Kopiere `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md`
2. Kopiere `src/templates/` → `.claude/skills/specshift/templates/`
3. Kopiere `src/.claude-plugin/plugin.json` → `.claude/.claude-plugin/plugin.json`
4. Für jede `src/actions/<action>.md`:
   - Parse Markdown-Links, löse relative Pfade zu `docs/specs/` auf
   - Extrahiere `### Requirement: <Name>` Blöcke aus den Specs
   - Schreibe `.claude/skills/specshift/actions/<action>.md` mit `# Requirements` + Blöcken
5. Validiere: Link-Count vs extrahierte Count pro Action
6. Report ausgeben

### Runtime-Trennung

| Was | Quelle | Wann | Warum |
|-----|--------|------|-------|
| Instructions | `.specshift/WORKFLOW.md` | JIT (Runtime) | Projektspezifisch — jedes Projekt kann Actions anpassen |
| Requirements | `.claude/skills/specshift/actions/*.md` | AOT (Compile-Time) | Plugin-level — konsistent über alle Consumer |

## Goals & Success Metrics

- **Token-Reduktion**: Compiled propose.md < 350 Zeilen (vs ~700 bei JIT). PASS/FAIL per Zeilenvergleich.
- **Self-contained Plugin**: `.claude/` enthält alles für die Laufzeit. Kein `docs/specs/` nötig. PASS/FAIL.
- **Kompilierungs-Korrektheit**: `bash scripts/compile-skills.sh` erzeugt 4 Dateien, Count-Match mit Source-Links. PASS/FAIL.
- **Standard Plugin Layout**: `.claude/` folgt Claude Code Konvention (`.claude-plugin/`, `skills/`, auto-discovery). PASS/FAIL.

## Non-Goals

- Änderung des Markdown-Spec-Formats
- Änderung des Smart Template Formats
- Änderung der `specshift <action>` UX
- Kompilierung von Custom Action Instructions
- CI-Check für veraltete kompilierte Dateien

## Decisions

| Entscheidung | Rationale | Alternativen |
|-------------|-----------|--------------|
| Instructions JIT, Requirements AOT | Instructions sind projektspezifisch (WORKFLOW.md), Requirements sind plugin-level (Specs). Saubere Trennung. | Beides AOT (bricht Projekt-Anpassung), beides JIT (Token-Overhead) |
| Plugin-Root `.claude/` mit `source: "./.claude"` | Standard Claude Code Layout. Auto-Discovery + Marketplace gleichzeitig. | `source: "./.claude/skills/specshift"` (doppeltes .claude-plugin nötig) |
| `src/actions/*.md` als Compiler-Input | Eine Datei pro Action, klickbare Links, spiegelt Zielstruktur. SKILL.md bleibt sauber. | Monolithisches Manifest, Links in SKILL.md (SKILL.md wird unreines Runtime-Dokument) |
| Keine Frontmatter in kompilierten Dateien | Vermeidet Agent-Confusion. Nur `# Requirements` + Blöcke. | Frontmatter mit compiled-at/version/sources (Noise für den Agent) |
| Git-Persistenz | Release-Verzeichnis eingecheckt — Consumer brauchen keinen Build-Step. | .gitignore (erfordert Build bei jedem Nutzer) |
| Bash-only Compiler | Passt zum Tech-Stack (keine Runtime-Dependencies). | Python/Node (fügt Dependency hinzu) |

## Risiken & Gegenmaßnahmen

- **Veraltete Artefakte im Dev-Loop** → Finalize erzwingt Kompilierung. `bash scripts/compile-skills.sh` für schnellen Loop.
- **Fragiles Bash-Parsing** → Robuste Pfad-Auflösung (`sed` statt starres Prefix-Match), CRLF-Handling, Count-Validierung.

## Open Questions

No open questions.

## Assumptions

- Spec-Dateien behalten das konsistente Heading-Format (`### Requirement: <Name>`). <!-- ASSUMPTION: Consistent spec heading format -->
- `scripts/` ist ein akzeptabler Ort für Developer-Utilities. <!-- ASSUMPTION: Scripts directory convention -->

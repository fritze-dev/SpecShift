---
has_decisions: true
---
# Technical Design: AOT Prompt Compilation for Action Skills

## Context

Der Router-Skill (`src/skills/specshift/SKILL.md`) löst Requirements aktuell zur Laufzeit auf, indem er komplette Spec-Dateien aus `docs/specs/` liest. Dieser JIT-Ansatz verursacht hohen Token-Overhead (~60%), verhindert eine saubere Distribution (da Endnutzer keine Specs im Workspace haben) und erhöht die Latenz.

Dieses Design führt einen AOT (Ahead-of-Time) Compilations-Step ein. Dieser extrahiert während der finalize-Phase alle relevanten Requirement-Blöcke in statische Markdown-Dateien pro Aktion. Die JIT-Auflösung wird für Built-in Actions durch einen performanten Datei-Read ersetzt.

## Architecture & Components

### Compilation Flow

```
src/skills/specshift/SKILL.md ───┐
  (Source + Requirement-Links)   │
                                 │
src/templates/ ──────────────────┤
  (Source Templates)             │
                                 ├──→ scripts/compile-skills.sh ──→ .claude/skills/specshift/
docs/specs/*.md ─────────────────┤                                    ├── SKILL.md (kopiert)
  (Requirement-Blöcke)          │                                    ├── templates/ (kopiert)
                                 │                                    └── actions/
.specshift/WORKFLOW.md ──────────┘                                        ├── propose.md (kompiliert)
  (Action Instructions)                                                   ├── apply.md (kompiliert)
                                                                          ├── finalize.md (kompiliert)
                                                                          └── init.md (kompiliert)
```

`src/` ist die authoritative Quelle (Hand-edit). `.claude/skills/specshift/` ist das Release-Artefakt (generiert und in Git eingecheckt). Claude Code entdeckt den Skill automatisch über den `.claude/skills/` Pfad.

### Dateianpassungen

| Datei | Änderung |
|-------|----------|
| `src/skills/specshift/SKILL.md` | Schritt 4: Liest kompilierte Dateien aus `actions/` statt Links aufzulösen. Markierung der Link-Sektionen mit `<!-- AOT-COMPILER-INPUT -->`. Entfernung der JIT-Logik für Standard-Aktionen. |
| `.specshift/WORKFLOW.md` | Ergänzung des Compilation-Steps in der finalize Instruction. |
| `.specshift/CONSTITUTION.md` | Neue Architektur-Regel: `.claude/skills/specshift/` ist das offizielle Release-Verzeichnis und MUSS in Git eingecheckt werden. |
| `.gitignore` | Sicherstellen, dass `.claude/skills/specshift/` nicht ignoriert wird (Whitelist: `!/.claude/skills/`). |
| `.claude-plugin/marketplace.json` | Update des `source` Pfads auf `.claude/skills/specshift`. |

### Neue Dateien

| Datei | Zweck |
|-------|-------|
| `scripts/compile-skills.sh` | Standalone-Compilations-Skript. Kopiert Source + kompiliert Actions. |
| `.claude/skills/specshift/SKILL.md` | Kopiert von `src/skills/specshift/SKILL.md` |
| `.claude/skills/specshift/templates/` | Gespiegelt von `src/templates/` |
| `.claude/skills/specshift/actions/propose.md` | Kompiliert: Instruction + 8 Requirement-Blöcke |
| `.claude/skills/specshift/actions/apply.md` | Kompiliert: Instruction + 10 Requirement-Blöcke |
| `.claude/skills/specshift/actions/finalize.md` | Kompiliert: Instruction + 10 Requirement-Blöcke |
| `.claude/skills/specshift/actions/init.md` | Kompiliert: Instruction + 8 Requirement-Blöcke |

### Compiler Algorithmus (scripts/compile-skills.sh)

1. **Struktur kopieren**: `src/skills/specshift/SKILL.md` → `.claude/skills/specshift/SKILL.md` kopieren. `src/templates/` nach `.claude/skills/specshift/templates/` spiegeln.
2. **SKILL.md parsen**: Text zwischen `<!-- AOT-COMPILER-INPUT -->` Markern extrahieren, um die Mapping-Liste (Aktion → Specs) zu erhalten.
3. **Extraktion**: Für jeden Link die Ziel-Spec in `docs/specs/` lesen und exakt den Block unter `### Requirement: <Name>` extrahieren (bis zum nächsten Heading gleicher oder höherer Ebene).
4. **Instructions lesen**: Die `### Instruction` Texte aus der `.specshift/WORKFLOW.md` für die jeweilige Aktion extrahieren.
5. **Version lesen**: `version` aus `src/.claude-plugin/plugin.json` parsen.
6. **Assemblierung**: Die Dateien in `.claude/skills/specshift/actions/<action>.md` schreiben (Frontmatter + Instruction + extrahierte Requirements).
7. **Validierung**: Anzahl extrahierter Requirements mit Anzahl der Links in SKILL.md abgleichen. Bei Diskrepanz → Warning mit konkreter Angabe fehlender Requirements.
8. **Report**: Zusammenfassung ausgeben (kompilierte Aktionen, Requirements pro Aktion, Warnungen).

### Router Logik (SKILL.md Schritt 4)

**Neu:**
- Für Built-in Actions (propose, apply, finalize, init): Lese `actions/<action>.md`.
- **Wenn Datei fehlt**: Hard Error — "Kompilierte Aktions-Datei fehlt. Bitte `bash scripts/compile-skills.sh` ausführen."
- Für Custom Actions: Weiterhin JIT-Read der Instruction aus der lokalen WORKFLOW.md.

## Goals & Success Metrics

- **Token-Reduktion**: Kompilierte propose-Datei < 300 Zeilen (vs ~695 Zeilen bei JIT). PASS/FAIL per Zeilenvergleich.
- **Self-contained Release**: `.claude/skills/specshift/` enthält alles für die Laufzeit. Kein Zugriff auf `docs/specs/` nötig. PASS/FAIL durch Ausführung in einem Projekt ohne `docs/specs/`.
- **Kompilierungs-Korrektheit**: `bash scripts/compile-skills.sh` erzeugt 4 nicht-leere Action-Dateien. Jede Datei enthält alle verlinkten Requirements (Count-Match mit SKILL.md Links). PASS/FAIL per Count-Vergleich.
- **Rückwärts-Kompatibilität**: `specshift <action>` Befehle funktionieren nach der Änderung identisch. PASS/FAIL durch propose/apply/finalize Zyklus.

## Non-Goals

- Änderung des Markdown-Spec-Formats
- Änderung des Smart Template Formats
- Änderung der `specshift <action>` UX
- Kompilierung von Custom Action Instructions (bleiben JIT)
- CI-Check für veraltete kompilierte Dateien (Future Enhancement)

## Decisions

| Entscheidung | Rationale | Alternativen |
|-------------|-----------|--------------|
| Kein JIT-Fallback | "Fail Fast"-Prinzip. Da die Artefakte im Git liegen, deutet eine fehlende Datei auf ein korruptes Repo hin. Ein Fallback würde bei Endnutzern (ohne `docs/specs/`) ohnehin fehlschlagen. | JIT-Fallback (komplexer, unzuverlässig beim Nutzer) |
| Release in `.claude/skills/` | Nutzt Claude Codes native Skill-Discovery. Macht das Tool "Zero-Config" für neue Teammitglieder. | Distribution via `src/` (erfordert manuelle Plugin-Installation) |
| Git-Persistenz | Das Release-Verzeichnis wird eingecheckt, damit der Workflow auch ohne lokalen Build-Step für reine "Nutzer" funktioniert. | Verzeichnis auf `.gitignore` setzen (erfordert Build-Step bei jedem Nutzer) |
| Hybrid: Thin Router + kompilierte Action-Dateien | Erhält ~40 Zeilen shared Logic (Steps 1-3), behält `specshift` Skill-Registrierung, Zero Breaking Change. | Full Standalone Skills pro Action (bricht UX, dupliziert Logic) |
| Requirement-Links bleiben in SKILL.md als Compiler-Input | Single Source of Truth für Action-Requirement-Mapping; keine neuen Dateien. | Separate `requirements.md` Manifest-Datei |
| Bash-only Compiler-Skript | Passt zum Tech-Stack (keine Runtime-Dependencies), Specs nutzen konsistentes Format. | Python/Node-Skript (fügt Dependency hinzu) |
| Custom Actions bleiben JIT | Keine Spec-Requirements zu kompilieren; Instruction-Text ist self-contained in WORKFLOW.md. | Custom Action Instructions auch kompilieren (kein Vorteil) |

## Risiken & Gegenmaßnahmen

- **Veraltete Artefakte im Dev-Loop**: Entwickler könnten Specs ändern, aber vergessen zu kompilieren. → Maßnahme: Der finalize-Schritt erzwingt die Kompilierung. Für den schnellen Loop gibt es `bash scripts/compile-skills.sh`.
- **Fragiles Bash-Parsing**: Markdown-Strukturen sind Text. → Maßnahme: Das Skript validiert, dass die Anzahl der extrahierten Requirements mit der Anzahl der Links in SKILL.md übereinstimmt. Bei Diskrepanz → Warning/Error.
- **Zwei Compilation-Einstiegspunkte** (Skript + finalize) → Maßnahme: finalize delegiert an dasselbe Skript; eine Implementierung.
- **Zusätzliche Dateien in `.claude/`** → Akzeptabler Trade-off für Token-Einsparung, Auto-Discovery und Self-contained Distribution.

## Open Questions

No open questions.

## Assumptions

- Spec-Dateien behalten das konsistente Heading-Format (`### Requirement: <Name>` gefolgt von Content bis zum nächsten `### ` oder `## `). <!-- ASSUMPTION: Consistent spec heading format -->
- Das `scripts/` Verzeichnis ist ein akzeptabler Ort für Developer-Utilities in diesem Projekt. <!-- ASSUMPTION: Scripts directory convention -->

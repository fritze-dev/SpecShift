#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift (multi-target, agnostic).
# Plugin root = ./ (repo root). Both target manifests AND both marketplace files
# are hand-edited at the root (`.claude-plugin/plugin.json`,
# `.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
# `.agents/plugins/marketplace.json`); the shared skill tree compiles to
# ./skills/specshift/.
#
# This script does NOT copy manifests or marketplace files from src/ — they
# live at the root. It reads the version from .claude-plugin/plugin.json
# (the source of truth) and stamps it into .codex-plugin/plugin.json and
# .agents/plugins/marketplace.json in place via `jq` (preserving every other
# field verbatim).
#
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
ACTIONS_SRC="src/actions"

PLUGIN_ROOT="."
SKILL_DIR="$PLUGIN_ROOT/skills/specshift"
CLAUDE_MANIFEST="$PLUGIN_ROOT/.claude-plugin/plugin.json"
CODEX_MANIFEST="$PLUGIN_ROOT/.codex-plugin/plugin.json"
CODEX_MARKETPLACE="$PLUGIN_ROOT/.agents/plugins/marketplace.json"
LEGACY_SKILL_DIR=".claude/skills"

# --- Preflight ---

if [[ ! -f "$SKILL_SRC" ]]; then
  echo "Error: $SKILL_SRC not found. Run this script from the repository root." >&2
  exit 1
fi

if [[ ! -d "$ACTIONS_SRC" ]]; then
  echo "Error: $ACTIONS_SRC/ not found." >&2
  exit 1
fi

if [[ ! -f "$CLAUDE_MANIFEST" ]]; then
  echo "Error: $CLAUDE_MANIFEST not found (the Claude plugin manifest is the version source of truth and must be hand-edited at the repository root)." >&2
  exit 1
fi

if [[ ! -f "$CODEX_MANIFEST" ]]; then
  echo "Error: $CODEX_MANIFEST not found (the Codex plugin manifest must be hand-edited at the repository root)." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required (used to read/stamp manifest versions)." >&2
  exit 1
fi

warnings=0

# --- Template-version enforcement ---
# Modified templates must have their template-version bumped.
# Compares working tree against main to detect unbumped versions.

tv_errors=0
base_ref=""
if git rev-parse --verify --quiet main &>/dev/null; then
  base_ref="main"
elif git rev-parse --verify --quiet origin/main &>/dev/null; then
  base_ref="origin/main"
fi

if [[ -n "$base_ref" ]]; then
  echo "Checking template-version freshness (vs $base_ref)..."

  while IFS= read -r tpl; do
    [[ -n "$tpl" ]] || continue
    [[ -f "$tpl" ]] || continue

    # If the diff does not contain a new +template-version line,
    # the file was modified without bumping its version.
    if ! git diff "$base_ref" -- "$tpl" | grep -qE '^\+template-version: '; then
      echo "  ERROR: $tpl modified without template-version bump" >&2
      ((tv_errors++)) || true
    fi
  done < <(git diff "$base_ref" --name-only -- src/templates/)

  if [[ "$tv_errors" -gt 0 ]]; then
    echo "ERROR: $tv_errors template(s) modified without version bump." >&2
    echo "Increment template-version in each listed file's YAML frontmatter." >&2
    exit 1
  fi

  echo "  All modified templates have bumped versions."
else
  echo "Skipping template-version check (no main branch for comparison)."
fi

# --- Read plugin version from the Claude manifest (source of truth) ---

PLUGIN_VERSION=$(jq -r '.version // empty' "$CLAUDE_MANIFEST")
if [[ -z "$PLUGIN_VERSION" ]]; then
  echo "Error: could not read .version from $CLAUDE_MANIFEST" >&2
  exit 1
fi

# --- Clean previous build outputs ---
# Plugin manifests and marketplace files are hand-edited at the root and SHALL
# NOT be removed. Only generated outputs are cleaned: the shared skill tree
# and any legacy compiled tree from the pre-multi-target layout.

echo "Building release at $PLUGIN_ROOT/ (version: $PLUGIN_VERSION) ..."
rm -rf "$SKILL_DIR"
# Remove legacy compiled tree from the pre-multi-target layout, if present.
rm -rf "$LEGACY_SKILL_DIR"

# --- Copy shared skill tree (one tree, served to both targets) ---

mkdir -p "$SKILL_DIR/actions"
cp "$SKILL_SRC" "$SKILL_DIR/SKILL.md"
cp -r src/templates/ "$SKILL_DIR/templates/"

# --- Stamp plugin-version into compiled workflow template ---

sed -i "s/^plugin-version: \"\"$/plugin-version: $PLUGIN_VERSION/" "$SKILL_DIR/templates/workflow.md"
echo "Stamped plugin-version: $PLUGIN_VERSION into compiled workflow template"

# --- Stamp Codex manifest version (preserve all other fields) ---

CODEX_CURRENT_VERSION=$(jq -r '.version // empty' "$CODEX_MANIFEST")
if [[ "$CODEX_CURRENT_VERSION" != "$PLUGIN_VERSION" ]]; then
  jq --arg v "$PLUGIN_VERSION" '.version = $v' "$CODEX_MANIFEST" > "$CODEX_MANIFEST.tmp" \
    && mv "$CODEX_MANIFEST.tmp" "$CODEX_MANIFEST"
  echo "Stamped Codex manifest version: $CODEX_CURRENT_VERSION → $PLUGIN_VERSION ($CODEX_MANIFEST)"
else
  echo "Codex manifest version already at $PLUGIN_VERSION ($CODEX_MANIFEST)"
fi

# Cross-check: emitted Codex manifest version must equal Claude source version.
CODEX_STAMPED_VERSION=$(jq -r '.version // empty' "$CODEX_MANIFEST")
if [[ "$CODEX_STAMPED_VERSION" != "$PLUGIN_VERSION" ]]; then
  echo "Error: Codex manifest version ($CODEX_STAMPED_VERSION) does not match Claude source version ($PLUGIN_VERSION) after stamping." >&2
  exit 1
fi

# --- Stamp Codex marketplace version (preserve all other fields) ---

if [[ -f "$CODEX_MARKETPLACE" ]]; then
  CODEX_MARKETPLACE_CURRENT_VERSION=$(jq -r '.plugins[0].version // empty' "$CODEX_MARKETPLACE")
  if [[ "$CODEX_MARKETPLACE_CURRENT_VERSION" != "$PLUGIN_VERSION" ]]; then
    jq --arg v "$PLUGIN_VERSION" '(.plugins[] | .version) = $v' "$CODEX_MARKETPLACE" \
      > "$CODEX_MARKETPLACE.tmp" && mv "$CODEX_MARKETPLACE.tmp" "$CODEX_MARKETPLACE"
    echo "Stamped Codex marketplace version: $CODEX_MARKETPLACE_CURRENT_VERSION → $PLUGIN_VERSION ($CODEX_MARKETPLACE)"
  else
    echo "Codex marketplace version already at $PLUGIN_VERSION ($CODEX_MARKETPLACE)"
  fi

  # Cross-check: emitted Codex marketplace version must equal Claude source version.
  CODEX_MARKETPLACE_STAMPED_VERSION=$(jq -r '.plugins[0].version // empty' "$CODEX_MARKETPLACE")
  if [[ "$CODEX_MARKETPLACE_STAMPED_VERSION" != "$PLUGIN_VERSION" ]]; then
    echo "Error: Codex marketplace version ($CODEX_MARKETPLACE_STAMPED_VERSION) does not match Claude source version ($PLUGIN_VERSION) after stamping." >&2
    exit 1
  fi
else
  echo "WARNING: $CODEX_MARKETPLACE not found — skipping Codex marketplace stamp" >&2
  ((warnings++)) || true
fi

total_actions=0
total_requirements=0

# --- Extract requirement block from spec file ---

extract_requirement() {
  local file="$1"
  local req_name="$2"

  if [[ ! -f "$file" ]]; then
    echo "WARNING: Spec file not found: $file" >&2
    ((warnings++)) || true
    return 1
  fi

  local found=false
  local output=""

  while IFS= read -r line; do
    line="${line%$'\r'}"
    if [[ "$found" == false ]]; then
      if [[ "$line" == "### Requirement: $req_name" || "$line" == "### Requirement: $req_name ("* ]]; then
        found=true
        output="$line"
      fi
    else
      if [[ "$line" =~ ^###\  ]] || [[ "$line" =~ ^##\  ]]; then
        break
      fi
      output="$output"$'\n'"$line"
    fi
  done < "$file"

  if [[ "$found" == false ]]; then
    echo "WARNING: Requirement '$req_name' not found in $file" >&2
    ((warnings++)) || true
    return 1
  fi

  echo "$output"
}

# --- Main: loop over src/actions/*.md ---

for action_file in "$ACTIONS_SRC"/*.md; do
  [[ -f "$action_file" ]] || continue

  action=$(basename "$action_file" .md)
  echo ""
  echo "Compiling action: $action ..."

  link_count=0
  extracted_count=0
  requirements_content=""

  # Parse requirement links from this action file
  while IFS= read -r line; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^-\ \[(.+)\]\((.+)\) ]]; then
      req_name="${BASH_REMATCH[1]}"
      req_path="${BASH_REMATCH[2]}"
      # Resolve to repo-root-relative path (tolerates any prefix before docs/)
      file_path=$(echo "${req_path%%#*}" | sed 's|^.*docs/specs/|docs/specs/|')

      ((link_count++)) || true

      block=$(extract_requirement "$file_path" "$req_name") || continue
      ((extracted_count++)) || true
      requirements_content="$requirements_content"$'\n\n'"$block"
    fi
  done < "$action_file"

  # Write compiled action file (requirements only — instructions come from WORKFLOW.md at runtime)
  outfile="$SKILL_DIR/actions/$action.md"
  {
    echo "# Requirements"
    if [[ -n "$requirements_content" ]]; then
      echo "$requirements_content"
    fi
  } > "$outfile"

  # Validate count
  if [[ "$extracted_count" -ne "$link_count" ]]; then
    echo "  WARNING: Expected $link_count requirements, extracted $extracted_count" >&2
    ((warnings++)) || true
  fi

  echo "  $action: $extracted_count/$link_count requirements extracted"
  ((total_actions++)) || true
  ((total_requirements += extracted_count)) || true
done

# --- Summary ---

echo ""
echo "=== Compilation Summary ==="
echo "Actions compiled: $total_actions"
echo "Total requirements: $total_requirements"
echo "Warnings: $warnings"
echo "Plugin version: $PLUGIN_VERSION"
echo "Outputs:"
echo "  - $CLAUDE_MANIFEST (Claude Code, hand-edited; version: $PLUGIN_VERSION)"
echo "  - $CODEX_MANIFEST (Codex, hand-edited + version-stamped: $PLUGIN_VERSION)"
echo "  - $CODEX_MARKETPLACE (Codex marketplace, hand-edited + version-stamped: $PLUGIN_VERSION)"
echo "  - $SKILL_DIR/ (shared skill tree)"
echo ""

if [[ "$warnings" -gt 0 ]]; then
  echo "Done with $warnings warning(s)."
  exit 1
else
  echo "Done."
fi

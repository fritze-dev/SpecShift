#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift (multi-target).
# Plugin root = ./ (repo root). Both manifests sit side-by-side at the root,
# the shared skill tree lives at ./skills/specshift/, and the Codex marketplace
# entry is emitted under .agents/plugins/.
#
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
ACTIONS_SRC="src/actions"
CLAUDE_PLUGIN_JSON="src/.claude-plugin/plugin.json"
CODEX_PLUGIN_JSON="src/.codex-plugin/plugin.json"
CODEX_MARKETPLACE_SRC="src/marketplace/codex.json"
PLUGIN_ROOT="."
SKILL_DIR="$PLUGIN_ROOT/skills/specshift"
CLAUDE_MANIFEST_DIR="$PLUGIN_ROOT/.claude-plugin"
CODEX_MANIFEST_DIR="$PLUGIN_ROOT/.codex-plugin"
CODEX_MARKETPLACE_DIR="$PLUGIN_ROOT/.agents/plugins"
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

if [[ ! -f "$CLAUDE_PLUGIN_JSON" ]]; then
  echo "Error: $CLAUDE_PLUGIN_JSON not found." >&2
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

# --- Read plugin version (Claude manifest is the source of truth) ---

PLUGIN_VERSION=$(jq -r '.version // empty' "$CLAUDE_PLUGIN_JSON")
if [[ -z "$PLUGIN_VERSION" ]]; then
  echo "Error: could not read .version from $CLAUDE_PLUGIN_JSON" >&2
  exit 1
fi

# --- Clean previous build outputs ---
# Note: .claude-plugin/marketplace.json is hand-maintained (not compiled),
# so we only remove generated files inside .claude-plugin/, not the whole directory.

echo "Building release at $PLUGIN_ROOT/ ..."
rm -rf "$SKILL_DIR"
rm -f "$CLAUDE_MANIFEST_DIR/plugin.json"
rm -rf "$CODEX_MANIFEST_DIR"
rm -rf "$CODEX_MARKETPLACE_DIR"
# Remove legacy compiled tree from the pre-multi-target layout, if present.
rm -rf "$LEGACY_SKILL_DIR"

# --- Copy shared skill tree ---

mkdir -p "$SKILL_DIR/actions"
cp "$SKILL_SRC" "$SKILL_DIR/SKILL.md"
cp -r src/templates/ "$SKILL_DIR/templates/"

# --- Stamp plugin-version into compiled workflow template ---

sed -i "s/^plugin-version: \"\"$/plugin-version: $PLUGIN_VERSION/" "$SKILL_DIR/templates/workflow.md"
echo "Stamped plugin-version: $PLUGIN_VERSION into compiled workflow template"

# --- Emit Claude Code manifest ---

mkdir -p "$CLAUDE_MANIFEST_DIR"
cp "$CLAUDE_PLUGIN_JSON" "$CLAUDE_MANIFEST_DIR/plugin.json"
echo "Emitted Claude manifest at $CLAUDE_MANIFEST_DIR/plugin.json"

# --- Emit Codex manifest (with version stamped from Claude source) ---

if [[ -f "$CODEX_PLUGIN_JSON" ]]; then
  mkdir -p "$CODEX_MANIFEST_DIR"
  out="$CODEX_MANIFEST_DIR/plugin.json"
  jq --arg v "$PLUGIN_VERSION" '.version = $v' "$CODEX_PLUGIN_JSON" > "$out.tmp" && mv "$out.tmp" "$out"
  echo "Emitted Codex manifest at $out (version stamped: $PLUGIN_VERSION)"
else
  echo "WARNING: $CODEX_PLUGIN_JSON not found — skipping Codex manifest" >&2
  ((warnings++)) || true
fi

# --- Emit Codex marketplace entry ---

if [[ -f "$CODEX_MARKETPLACE_SRC" ]]; then
  mkdir -p "$CODEX_MARKETPLACE_DIR"
  out="$CODEX_MARKETPLACE_DIR/marketplace.json"
  jq --arg v "$PLUGIN_VERSION" '(.plugins[] | .version) = $v' "$CODEX_MARKETPLACE_SRC" > "$out.tmp" && mv "$out.tmp" "$out"
  echo "Emitted Codex marketplace at $out (version stamped: $PLUGIN_VERSION)"
else
  echo "WARNING: $CODEX_MARKETPLACE_SRC not found — skipping Codex marketplace" >&2
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
echo "  - $CLAUDE_MANIFEST_DIR/plugin.json (Claude Code)"
echo "  - $CODEX_MANIFEST_DIR/plugin.json (Codex)"
echo "  - $CODEX_MARKETPLACE_DIR/marketplace.json (Codex marketplace)"
echo "  - $SKILL_DIR/ (shared skill tree)"
echo ""

if [[ "$warnings" -gt 0 ]]; then
  echo "Done with $warnings warning(s)."
  exit 1
else
  echo "Done."
fi

#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift
# Builds the release directory at .claude/ from source files.
# Plugin root = .claude/ (marketplace source: "./.claude")
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
ACTIONS_SRC="src/actions"
PLUGIN_JSON="src/.claude-plugin/plugin.json"
PLUGIN_ROOT=".claude"
SKILL_DIR="$PLUGIN_ROOT/skills/specshift"

# --- Preflight ---

if [[ ! -f "$SKILL_SRC" ]]; then
  echo "Error: $SKILL_SRC not found. Run this script from the repository root." >&2
  exit 1
fi

if [[ ! -d "$ACTIONS_SRC" ]]; then
  echo "Error: $ACTIONS_SRC/ not found." >&2
  exit 1
fi

# --- Copy source files ---

echo "Building release at $PLUGIN_ROOT/ ..."
rm -rf "$SKILL_DIR"
rm -rf "$PLUGIN_ROOT/.claude-plugin"
mkdir -p "$SKILL_DIR/actions"
cp "$SKILL_SRC" "$SKILL_DIR/SKILL.md"
cp -r src/templates/ "$SKILL_DIR/templates/"
mkdir -p "$PLUGIN_ROOT/.claude-plugin"
cp "$PLUGIN_JSON" "$PLUGIN_ROOT/.claude-plugin/plugin.json"

# --- Stamp plugin-version into compiled workflow template ---

PLUGIN_VERSION=$(grep -o '"version": *"[^"]*"' "$PLUGIN_JSON" | head -1 | sed 's/"version": *"//;s/"//')
if [[ -n "$PLUGIN_VERSION" ]]; then
  sed -i "s/^plugin-version: \"\"$/plugin-version: $PLUGIN_VERSION/" "$SKILL_DIR/templates/workflow.md"
  echo "Stamped plugin-version: $PLUGIN_VERSION into compiled workflow template"
fi

total_actions=0
total_requirements=0
warnings=0

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
echo "Plugin root: $PLUGIN_ROOT/"
echo ""

if [[ "$warnings" -gt 0 ]]; then
  echo "Done with $warnings warning(s)."
  exit 1
else
  echo "Done."
fi

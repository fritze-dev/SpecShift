#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift
# Builds the release directory at .claude/ from source files.
# Plugin root = .claude/ (marketplace source: "./.claude")
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
REQUIREMENTS_MANIFEST="src/action-requirements.md"
WORKFLOW=".specshift/WORKFLOW.md"
PLUGIN_JSON="src/.claude-plugin/plugin.json"
PLUGIN_ROOT=".claude"
SKILL_DIR="$PLUGIN_ROOT/skills/specshift"

# --- Preflight ---

if [[ ! -f "$SKILL_SRC" ]]; then
  echo "Error: $SKILL_SRC not found. Run this script from the repository root." >&2
  exit 1
fi

if [[ ! -f "$REQUIREMENTS_MANIFEST" ]]; then
  echo "Error: $REQUIREMENTS_MANIFEST not found." >&2
  exit 1
fi

if [[ ! -f "$WORKFLOW" ]]; then
  echo "Error: $WORKFLOW not found." >&2
  exit 1
fi

# --- Read version ---

VERSION="unknown"
if [[ -f "$PLUGIN_JSON" ]]; then
  VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PLUGIN_JSON" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
fi

COMPILED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Copy source files ---

echo "Building release at $PLUGIN_ROOT/ ..."
rm -rf "$SKILL_DIR"
rm -rf "$PLUGIN_ROOT/.claude-plugin"
mkdir -p "$SKILL_DIR/actions"
cp "$SKILL_SRC" "$SKILL_DIR/SKILL.md"
cp -r src/templates/ "$SKILL_DIR/templates/"
mkdir -p "$PLUGIN_ROOT/.claude-plugin"
cp "$PLUGIN_JSON" "$PLUGIN_ROOT/.claude-plugin/plugin.json"

total_actions=0
total_requirements=0
warnings=0

# --- Parse action sections from SKILL.md ---

parse_actions() {
  local current_action=""
  local in_requirements=false

  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ Action:\ ([a-z]+)\ —\ Requirements ]]; then
      current_action="${BASH_REMATCH[1]}"
      in_requirements=true
      echo "ACTION:$current_action"
    elif [[ "$in_requirements" == true && "$line" =~ ^##\  ]]; then
      # Next heading at same level — end of this action's requirements
      in_requirements=false
      current_action=""
    elif [[ "$in_requirements" == true && "$line" =~ ^-\ \[(.+)\]\((.+)\) ]]; then
      local req_name="${BASH_REMATCH[1]}"
      local req_path="${BASH_REMATCH[2]}"
      # Split path from anchor
      local file_path="${req_path%%#*}"
      echo "LINK:$current_action|$req_name|$file_path"
    fi
  done < "$REQUIREMENTS_MANIFEST"
}

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
    if [[ "$found" == false ]]; then
      # Match exact heading or heading with parenthetical suffix
      if [[ "$line" == "### Requirement: $req_name" || "$line" == "### Requirement: $req_name ("* ]]; then
        found=true
        output="$line"
      fi
    else
      # Stop at next ### or ## heading
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

# --- Extract action instruction from WORKFLOW.md ---

extract_instruction() {
  local action="$1"
  local found_action=false
  local found_instruction=false
  local output=""

  while IFS= read -r line; do
    if [[ "$found_action" == false ]]; then
      if [[ "$line" == "## Action: $action" ]]; then
        found_action=true
      fi
    elif [[ "$found_instruction" == false ]]; then
      if [[ "$line" == "### Instruction" ]]; then
        found_instruction=true
      elif [[ "$line" =~ ^##\  ]]; then
        # Hit another top-level section without finding ### Instruction
        break
      fi
    else
      # Collecting instruction content — stop at next ## heading
      if [[ "$line" =~ ^##\  ]]; then
        break
      fi
      output="$output"$'\n'"$line"
    fi
  done < "$WORKFLOW"

  if [[ "$found_instruction" == false ]]; then
    echo "WARNING: Instruction for action '$action' not found in $WORKFLOW" >&2
    ((warnings++)) || true
    return 1
  fi

  # Trim leading blank lines
  echo "$output" | sed '/./,$!d'
}

# --- Main compilation ---

declare -A action_links  # action -> list of "name|file" pairs
declare -A action_order  # preserve discovery order
action_list=()

while IFS= read -r parsed_line; do
  if [[ "$parsed_line" =~ ^ACTION:(.+) ]]; then
    action="${BASH_REMATCH[1]}"
    action_links[$action]=""
    action_list+=("$action")
  elif [[ "$parsed_line" =~ ^LINK:([^|]+)\|([^|]+)\|(.+) ]]; then
    action="${BASH_REMATCH[1]}"
    req_name="${BASH_REMATCH[2]}"
    file_path="${BASH_REMATCH[3]}"
    if [[ -n "${action_links[$action]:-}" ]]; then
      action_links[$action]="${action_links[$action]}"$'\n'"$req_name|$file_path"
    else
      action_links[$action]="$req_name|$file_path"
    fi
  fi
done < <(parse_actions)

for action in "${action_list[@]}"; do
  echo ""
  echo "Compiling action: $action ..."

  link_count=0
  extracted_count=0
  sources=()
  requirements_content=""

  if [[ -n "${action_links[$action]:-}" ]]; then
    while IFS='|' read -r req_name file_path; do
      ((link_count++)) || true

      # Track unique source files
      already_tracked=false
      for s in "${sources[@]:-}"; do
        if [[ "$s" == "$file_path" ]]; then
          already_tracked=true
          break
        fi
      done
      if [[ "$already_tracked" == false ]]; then
        sources+=("$file_path")
      fi

      block=$(extract_requirement "$file_path" "$req_name") || {
        continue
      }
      ((extracted_count++)) || true
      requirements_content="$requirements_content"$'\n\n'"$block"
    done <<< "${action_links[$action]}"
  fi

  # Extract instruction
  instruction=$(extract_instruction "$action") || {
    echo "  Skipping action '$action' — no instruction found."
    continue
  }

  # Build sources YAML array
  sources_yaml=""
  for s in "${sources[@]:-}"; do
    sources_yaml="$sources_yaml"$'\n'"  - $s"
  done

  # Write compiled action file
  outfile="$SKILL_DIR/actions/$action.md"
  {
    echo "---"
    echo "compiled-at: $COMPILED_AT"
    echo "specshift-version: $VERSION"
    echo "sources:$sources_yaml"
    echo "---"
    echo ""
    echo "## Instruction"
    echo ""
    echo "$instruction"
    if [[ -n "$requirements_content" ]]; then
      echo ""
      echo "## Requirements"
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
  exit 0
else
  echo "Done."
fi

#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift.
# Builds Claude and Codex release artifacts from source files.
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
ACTIONS_SRC="src/actions"
TEMPLATES_SRC="src/templates"

CLAUDE_PLUGIN_JSON="src/.claude-plugin/plugin.json"
CLAUDE_PLUGIN_ROOT=".claude"
CLAUDE_SKILL_DIR="$CLAUDE_PLUGIN_ROOT/skills/specshift"

CODEX_PLUGIN_JSON="src/.codex-plugin/plugin.json"
CODEX_AGENT_TEMPLATE="src/codex/templates/agents.md"
CODEX_PLUGIN_DIR=".codex-plugin"
CODEX_SKILL_DIR="skills/specshift"

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

if [[ ! -f "$CODEX_PLUGIN_JSON" ]]; then
  echo "Error: $CODEX_PLUGIN_JSON not found." >&2
  exit 1
fi

if [[ ! -f "$CODEX_AGENT_TEMPLATE" ]]; then
  echo "Error: $CODEX_AGENT_TEMPLATE not found." >&2
  exit 1
fi

# --- Template-version enforcement ---
# Modified common templates must have their template-version bumped.
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
    git diff --quiet --ignore-cr-at-eol "$base_ref" -- "$tpl" && continue

    # If the diff does not contain a new +template-version line,
    # the file was modified without bumping its version.
    if ! git diff --ignore-cr-at-eol "$base_ref" -- "$tpl" | grep -qE '^\+template-version: '; then
      echo "  ERROR: $tpl modified without template-version bump" >&2
      ((tv_errors++)) || true
    fi
  done < <(git ls-files "$TEMPLATES_SRC/")

  if [[ "$tv_errors" -gt 0 ]]; then
    echo "ERROR: $tv_errors template(s) modified without version bump." >&2
    echo "Increment template-version in each listed file's YAML frontmatter." >&2
    exit 1
  fi

  echo "  All modified templates have bumped versions."
else
  echo "Skipping template-version check (no main branch for comparison)."
fi

plugin_version_from() {
  local manifest="$1"
  grep -o '"version": *"[^"]*"' "$manifest" | head -1 | sed 's/"version": *"//;s/"//'
}

stamp_plugin_version() {
  local workflow_template="$1"
  local version="$2"

  if [[ -n "$version" && -f "$workflow_template" ]]; then
    sed -i "s/^plugin-version: \"\".*$/plugin-version: $version/" "$workflow_template"
  fi
}

rewrite_codex_file() {
  local file="$1"

  sed -i \
    -e 's/Claude Code Web/Codex/g' \
    -e 's/Claude Code/Codex/g' \
    -e 's/CLAUDE\.md/AGENTS.md/g' \
    -e 's/claude\.md/agents.md/g' \
    -e 's/\.claude\/worktrees/.specshift\/worktrees/g' \
    -e 's/\${CLAUDE_PLUGIN_ROOT}/the installed plugin root/g' \
    "$file"
}

rewrite_codex_requirements_file() {
  local file="$1"

  sed -i \
    -e 's/`CLAUDE_PLUGIN_ROOT`/the Claude plugin root environment variable/g' \
    -e 's/CLAUDE\.md/AGENTS.md/g' \
    -e 's/\.claude\/worktrees/.specshift\/worktrees/g' \
    -e 's/\${CLAUDE_PLUGIN_ROOT}/the installed plugin root/g' \
    "$file"
}

write_codex_skill() {
  awk '
    BEGIN { in_desc = 0 }
    $0 ~ /^description: \|/ {
      print
      print "  Central SpecShift workflow command for Codex. Use when the user explicitly invokes `specshift <action>` or when the current repository already has `.specshift/WORKFLOW.md` or AGENTS.md instructions requiring SpecShift."
      print "  Actions: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version), review (PR review + merge). Example: specshift propose"
      print "  DO NOT TRIGGER for ordinary coding requests unless the user asks for SpecShift or the project is already governed by SpecShift."
      in_desc = 1
      next
    }
    in_desc && $0 ~ /^---/ {
      in_desc = 0
      print
      next
    }
    in_desc { next }
    {
      gsub("Claude Code Web", "Codex")
      gsub("Claude Code", "Codex")
      gsub("CLAUDE.md", "AGENTS.md")
      print
    }
  ' "$SKILL_SRC" > "$CODEX_SKILL_DIR/SKILL.md"
}

write_requirements_file() {
  local outfile="$1"
  local requirements_content="$2"

  {
    echo "# Requirements"
    if [[ -n "$requirements_content" ]]; then
      echo "$requirements_content"
    fi
  } > "$outfile"
}

# --- Copy source files ---

echo "Building Claude release at $CLAUDE_PLUGIN_ROOT/ ..."
rm -rf "$CLAUDE_SKILL_DIR"
rm -rf "$CLAUDE_PLUGIN_ROOT/.claude-plugin"
mkdir -p "$CLAUDE_SKILL_DIR/actions"
cp "$SKILL_SRC" "$CLAUDE_SKILL_DIR/SKILL.md"
cp -r "$TEMPLATES_SRC/" "$CLAUDE_SKILL_DIR/templates/"
mkdir -p "$CLAUDE_PLUGIN_ROOT/.claude-plugin"
cp "$CLAUDE_PLUGIN_JSON" "$CLAUDE_PLUGIN_ROOT/.claude-plugin/plugin.json"

CLAUDE_PLUGIN_VERSION=$(plugin_version_from "$CLAUDE_PLUGIN_JSON")
stamp_plugin_version "$CLAUDE_SKILL_DIR/templates/workflow.md" "$CLAUDE_PLUGIN_VERSION"
if [[ -n "$CLAUDE_PLUGIN_VERSION" ]]; then
  echo "Stamped Claude plugin-version: $CLAUDE_PLUGIN_VERSION"
fi

echo "Building Codex release at repository root ..."
rm -rf "$CODEX_SKILL_DIR"
rm -rf "$CODEX_PLUGIN_DIR"
mkdir -p "$CODEX_SKILL_DIR/actions"
write_codex_skill
cp -r "$TEMPLATES_SRC/" "$CODEX_SKILL_DIR/templates/"
rm -f "$CODEX_SKILL_DIR/templates/claude.md"
cp "$CODEX_AGENT_TEMPLATE" "$CODEX_SKILL_DIR/templates/agents.md"
find "$CODEX_SKILL_DIR/templates" -type f -name '*.md' -print0 | while IFS= read -r -d '' file; do
  rewrite_codex_file "$file"
done
mkdir -p "$CODEX_PLUGIN_DIR"
cp "$CODEX_PLUGIN_JSON" "$CODEX_PLUGIN_DIR/plugin.json"

CODEX_PLUGIN_VERSION=$(plugin_version_from "$CODEX_PLUGIN_JSON")
if [[ -n "$CLAUDE_PLUGIN_VERSION" && -n "$CODEX_PLUGIN_VERSION" && "$CLAUDE_PLUGIN_VERSION" != "$CODEX_PLUGIN_VERSION" ]]; then
  echo "Error: Claude manifest version ($CLAUDE_PLUGIN_VERSION) does not match Codex manifest version ($CODEX_PLUGIN_VERSION)." >&2
  exit 1
fi
stamp_plugin_version "$CODEX_SKILL_DIR/templates/workflow.md" "$CODEX_PLUGIN_VERSION"
if [[ -n "$CODEX_PLUGIN_VERSION" ]]; then
  echo "Stamped Codex plugin-version: $CODEX_PLUGIN_VERSION"
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

  # Parse requirement links from this action file.
  while IFS= read -r line; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^-\ \[(.+)\]\((.+)\) ]]; then
      req_name="${BASH_REMATCH[1]}"
      req_path="${BASH_REMATCH[2]}"
      # Resolve to repo-root-relative path (tolerates any prefix before docs/).
      file_path=$(echo "${req_path%%#*}" | sed 's|^.*docs/specs/|docs/specs/|')

      ((link_count++)) || true

      block=$(extract_requirement "$file_path" "$req_name") || continue
      ((extracted_count++)) || true
      requirements_content="$requirements_content"$'\n\n'"$block"
    fi
  done < "$action_file"

  # Write compiled action files (requirements only; instructions come from WORKFLOW.md at runtime).
  claude_outfile="$CLAUDE_SKILL_DIR/actions/$action.md"
  codex_outfile="$CODEX_SKILL_DIR/actions/$action.md"
  write_requirements_file "$claude_outfile" "$requirements_content"
  cp "$claude_outfile" "$codex_outfile"
  case "$action" in
    init|propose|review)
      rewrite_codex_file "$codex_outfile"
      ;;
    apply|finalize)
      rewrite_codex_requirements_file "$codex_outfile"
      ;;
  esac

  # Validate count.
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
echo "Claude plugin root: $CLAUDE_PLUGIN_ROOT/"
echo "Codex plugin root: ./"
echo ""

if [[ "$warnings" -gt 0 ]]; then
  echo "Done with $warnings warning(s)."
  exit 1
else
  echo "Done."
fi

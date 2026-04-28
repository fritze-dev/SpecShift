#!/usr/bin/env bash
set -euo pipefail

# AOT Skill Compiler for SpecShift (multi-target, agnostic).
# Plugin root = ./ (repo root). Per-target plugin manifests AND marketplace files
# are hand-edited at the root (`.claude-plugin/plugin.json`,
# `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`,
# `.agents/plugins/marketplace.json`). The compiled skill tree lives at
# ./skills/specshift/. Codex also gets a generated marketplace payload at
# ./plugins/specshift/ because Codex marketplace entries must point at a
# non-empty plugin-root path under the marketplace root.
#
# Version source of truth: src/VERSION (plain text, single line, SemVer).
# This script reads that value and stamps it into the three version-bearing
# root files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
# `.codex-plugin/plugin.json`) via `jq` (preserving all non-version fields and
# values; JSON formatting may be normalized by jq's pretty-printer). After
# stamping, it re-reads each file and verifies the stamped value matches
# src/VERSION. The Codex marketplace catalog (`.agents/plugins/marketplace.json`)
# does NOT carry a `plugins[].version` field per the documented Codex schema,
# so it is presence-and-shape-checked instead of version-stamped. Any drift
# fails the build.
#
# Run from the repository root: bash scripts/compile-skills.sh

SKILL_SRC="src/skills/specshift/SKILL.md"
ACTIONS_SRC="src/actions"
VERSION_FILE="src/VERSION"

PLUGIN_ROOT="."
SKILL_DIR="$PLUGIN_ROOT/skills/specshift"
CODEX_DISTRIBUTION_DIR="$PLUGIN_ROOT/plugins/specshift"
CLAUDE_MANIFEST="$PLUGIN_ROOT/.claude-plugin/plugin.json"
CLAUDE_MARKETPLACE="$PLUGIN_ROOT/.claude-plugin/marketplace.json"
CODEX_MANIFEST="$PLUGIN_ROOT/.codex-plugin/plugin.json"
CODEX_MARKETPLACE="$PLUGIN_ROOT/.agents/plugins/marketplace.json"
LEGACY_SKILL_DIR=".claude/skills/specshift"
LEGACY_CLAUDE_MANIFEST_DIR=".claude/.claude-plugin"

warnings=0

# --- Preflight ---

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required (used to read/stamp manifest versions)." >&2
  exit 1
fi

if [[ ! -f "$SKILL_SRC" ]]; then
  echo "Error: $SKILL_SRC not found. Run this script from the repository root." >&2
  exit 1
fi

if [[ ! -d "$ACTIONS_SRC" ]]; then
  echo "Error: $ACTIONS_SRC/ not found." >&2
  exit 1
fi

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: $VERSION_FILE not found (the agnostic version source of truth must exist at this path)." >&2
  exit 1
fi

# Required: each per-target manifest / marketplace must be hand-edited at the root.
for f in "$CLAUDE_MANIFEST" "$CLAUDE_MARKETPLACE" "$CODEX_MANIFEST" "$CODEX_MARKETPLACE"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: $f not found (per-target manifest / marketplace files are hand-edited at the repository root)." >&2
    exit 1
  fi
done

# --- Read version source of truth ---

PLUGIN_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
if [[ -z "$PLUGIN_VERSION" ]]; then
  echo "Error: $VERSION_FILE is empty (the version source of truth must contain one SemVer string)." >&2
  exit 1
fi

# Sanity check: src/VERSION should be exactly one logical line. Multi-line
# files indicate the maintainer accidentally added content beyond the version.
line_count="$(grep -c '' "$VERSION_FILE" || true)"
if [[ "$line_count" -gt 1 ]]; then
  echo "Error: $VERSION_FILE contains $line_count lines (must contain exactly one line — the SemVer version string)." >&2
  exit 1
fi

# SemVer 2.0 validation: catch typos before they get stamped into JSON.
# Pattern: MAJOR.MINOR.PATCH with optional pre-release (-foo.bar) and build (+meta).
if ! [[ "$PLUGIN_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
  echo "Error: $VERSION_FILE value '$PLUGIN_VERSION' is not a valid SemVer 2.0 string." >&2
  echo "Expected format: MAJOR.MINOR.PATCH[-pre-release][+build] (e.g. 0.2.5-beta, 1.0.0)." >&2
  exit 1
fi

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

# --- Clean previous build outputs ---
# Per-target manifests and marketplace files are hand-edited at the root and
# SHALL NOT be removed. Only generated outputs are cleaned: the shared skill
# tree, the generated Codex marketplace payload, and any legacy compiled tree
# from the pre-multi-target layout.

echo "Building release at $PLUGIN_ROOT/ (version: $PLUGIN_VERSION) ..."
rm -rf "$SKILL_DIR"
rm -rf "$CODEX_DISTRIBUTION_DIR"
rm -rf "$LEGACY_SKILL_DIR"
rm -rf "$LEGACY_CLAUDE_MANIFEST_DIR"

# --- Copy shared skill tree (one tree, served to both targets) ---

mkdir -p "$SKILL_DIR/actions"
cp "$SKILL_SRC" "$SKILL_DIR/SKILL.md"
cp -r src/templates/ "$SKILL_DIR/templates/"

# --- Stamp plugin-version into compiled workflow template ---

sed -i "s/^plugin-version: \"\"$/plugin-version: $PLUGIN_VERSION/" "$SKILL_DIR/templates/workflow.md"
echo "Stamped plugin-version: $PLUGIN_VERSION into compiled workflow template"

# --- Stamp version into all four root manifest / marketplace files ---
# Each file uses jq with the appropriate path expression. After stamping we
# re-read and cross-check that the stamped value equals PLUGIN_VERSION.

stamp_version() {
  local file="$1"
  local jq_set="$2"   # jq expression that sets the version field (uses $v)
  local jq_get="$3"   # jq expression that reads the version field
  local label="$4"

  local current
  current="$(jq -r "$jq_get" "$file")"

  if [[ "$current" != "$PLUGIN_VERSION" ]]; then
    jq --arg v "$PLUGIN_VERSION" "$jq_set" "$file" > "$file.tmp" \
      && mv "$file.tmp" "$file"
    echo "Stamped $label version: $current → $PLUGIN_VERSION ($file)"
  else
    echo "$label version already at $PLUGIN_VERSION ($file)"
  fi

  local stamped
  stamped="$(jq -r "$jq_get" "$file")"
  if [[ "$stamped" != "$PLUGIN_VERSION" ]]; then
    echo "Error: $label version ($stamped) does not match src/VERSION ($PLUGIN_VERSION) after stamping ($file)." >&2
    exit 1
  fi
}

stamp_version "$CLAUDE_MANIFEST"     '.version = $v'                  '.version // empty'              "Claude manifest"
stamp_version "$CLAUDE_MARKETPLACE"  '(.plugins[] | .version) = $v'   '.plugins[0].version // empty'   "Claude marketplace"
stamp_version "$CODEX_MANIFEST"      '.version = $v'                  '.version // empty'              "Codex manifest"

# Codex marketplace catalog (.agents/plugins/marketplace.json) is the fourth root
# file but does NOT carry a plugins[].version field per the documented Codex
# schema — version is sourced from .codex-plugin/plugin.json referenced by
# plugins[0].source.path. The catalog is shape-checked instead of stamped.

verify_catalog_shape() {
  local file="$1"
  if ! jq -e \
    '.name == "specshift"
     and (.interface.displayName | type == "string")
     and ((.plugins | type) == "array")
     and ((.plugins | length) == 1)
     and (.plugins[0].source | type == "object")
     and (.plugins[0].source.source == "local")
     and (.plugins[0].source.path == "./plugins/specshift")
     and (.plugins[0].policy.installation == "AVAILABLE")
     and (.plugins[0].policy.authentication == "ON_INSTALL")
     and (.plugins[0].category == "Coding")
     and ((.plugins[0] | has("version")) | not)' \
    "$file" >/dev/null 2>&1; then
    echo "Error: Codex marketplace catalog at $file does not match the documented schema." >&2
    echo "       Expected source.path=\"./plugins/specshift\", policy AVAILABLE/ON_INSTALL, category Coding, and no plugins[].version." >&2
    exit 1
  fi
  echo "Codex marketplace catalog shape verified ($file)"
}

verify_catalog_shape "$CODEX_MARKETPLACE"

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

# --- Build Codex marketplace payload ---

mkdir -p "$CODEX_DISTRIBUTION_DIR/.codex-plugin"
mkdir -p "$CODEX_DISTRIBUTION_DIR/skills"
cp "$CODEX_MANIFEST" "$CODEX_DISTRIBUTION_DIR/.codex-plugin/plugin.json"
cp -r "$SKILL_DIR" "$CODEX_DISTRIBUTION_DIR/skills/specshift"

if [[ ! -f "$CODEX_DISTRIBUTION_DIR/.codex-plugin/plugin.json" ]]; then
  echo "Error: generated Codex payload is missing .codex-plugin/plugin.json" >&2
  exit 1
fi

if [[ ! -f "$CODEX_DISTRIBUTION_DIR/skills/specshift/SKILL.md" ]]; then
  echo "Error: generated Codex payload is missing skills/specshift/SKILL.md" >&2
  exit 1
fi

payload_version="$(jq -r '.version // empty' "$CODEX_DISTRIBUTION_DIR/.codex-plugin/plugin.json")"
if [[ "$payload_version" != "$PLUGIN_VERSION" ]]; then
  echo "Error: generated Codex payload version ($payload_version) does not match src/VERSION ($PLUGIN_VERSION)." >&2
  exit 1
fi

echo "Generated Codex marketplace payload: $CODEX_DISTRIBUTION_DIR/"

# --- Summary ---

echo ""
echo "=== Compilation Summary ==="
echo "Actions compiled: $total_actions"
echo "Total requirements: $total_requirements"
echo "Warnings: $warnings"
echo "Plugin version: $PLUGIN_VERSION (source: $VERSION_FILE)"
echo "Outputs:"
echo "  - $CLAUDE_MANIFEST (Claude manifest, hand-edited + version-stamped)"
echo "  - $CLAUDE_MARKETPLACE (Claude marketplace, hand-edited + version-stamped)"
echo "  - $CODEX_MANIFEST (Codex manifest, hand-edited + version-stamped)"
echo "  - $CODEX_MARKETPLACE (Codex marketplace catalog, hand-edited + shape-checked)"
echo "  - $SKILL_DIR/ (shared skill tree)"
echo "  - $CODEX_DISTRIBUTION_DIR/ (generated Codex marketplace payload)"
echo ""

if [[ "$warnings" -gt 0 ]]; then
  echo "Done with $warnings warning(s)."
  exit 1
else
  echo "Done."
fi

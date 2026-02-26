---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization with /opsx:init including CLI installation and validation"
order: 2
lastUpdated: "2026-03-02"
---

# Project Setup

Run `/opsx:init` once to set up everything needed for spec-driven development. The command installs the OpenSpec CLI, copies the schema, creates configuration, and validates the result.

## Features

- Single command sets up the entire project for spec-driven development
- Automatically installs the OpenSpec CLI if not present
- Idempotent: running it again skips already-completed steps
- Validates the setup after installation to confirm everything works

## Behavior

### First-Time Initialization

When you run `/opsx:init` on a fresh project, the system installs the OpenSpec CLI globally via npm, copies the `opsx-enhanced` schema into your project, creates `openspec/config.yaml` with workflow rules, and registers the plugin.

### Re-Initialization

Running `/opsx:init` on an already-initialized project skips completed steps and reports what was already in place. Existing configuration is not overwritten.

### CLI Version Management

The system checks for the OpenSpec CLI (`@fission-ai/openspec`) at version `^1.2.0`. If the CLI is missing, it auto-installs. If an incompatible version is found, it upgrades. If npm is unavailable, you get a clear error with installation guidance.

### Post-Setup Validation

After installation, the system verifies CLI accessibility, schema validity, and config presence. You see a summary of all validation results so you can trust the environment is ready.

## Edge Cases

- If you lack write permissions to the global npm prefix, the install fails with a clear error suggesting `sudo` or npm prefix configuration.
- If the project directory is read-only, init fails before making any changes.
- If a `.claude-plugin/plugin.json` already exists with a different plugin name, init warns about the conflict rather than silently overwriting.
- If network connectivity is unavailable during npm install, you get a network error with a retry suggestion.

---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization with CLI installation, schema setup, and validation"
order: 1
lastUpdated: "2026-03-04"
---

# Project Setup

Set up a project for the spec-driven workflow with a single `/opsx:init` command. This handles CLI installation, schema registration, config creation, and validation.

## Why This Exists

The init skill previously copied the plugin's own config.yaml into consumer projects, leaking project-specific rules. This was fixed so init generates a minimal config template, giving consumer projects a clean starting point without inherited rules.

## Background

Research into OpenSpec config.yaml structure confirmed that the init skill should generate config from a hardcoded template rather than copying the plugin's own config. This prevents project-specific content from leaking into consumer environments.

## Features

- Single command (`/opsx:init`) for complete project setup
- Automatic OpenSpec CLI installation via npm
- Schema registration and custom schema file setup
- Minimal config.yaml generation (schema reference + constitution pointer only)
- Constitution placeholder creation
- Post-setup validation
- Idempotent — safe to run again on already-initialized projects

## Behavior

### First-Time Initialization

Run `/opsx:init` to set up everything. The system installs the OpenSpec CLI globally, registers the schema, copies custom schema files from the plugin, creates a minimal config.yaml, creates a constitution placeholder, and validates the setup.

### Idempotent Re-Initialization

Running `/opsx:init` on an already-initialized project skips completed steps, preserves the existing constitution, and reports which components were already in place.

### Config Generation

Config.yaml is generated from a template containing only a schema reference and a constitution pointer. It does not contain workflow rules or content copied from the plugin's own config.

### CLI Prerequisite Check

The system checks whether the OpenSpec CLI is installed and compatible with `^1.2.0`. If not installed, it auto-installs via npm. If npm is not available, it reports a clear error.

### Validation

After setup, the system validates CLI accessibility, schema validity, and config presence. Any failures are reported with specific details about which check failed.

## Known Limitations

- The init config template is hardcoded in the skill, not read from the plugin's config.yaml — even if the plugin maintainer changes their config, consumer projects get the clean template.
- Requires Node.js and npm to be available for OpenSpec CLI installation.

## Edge Cases

- If you lack write permissions to the global npm prefix, the install fails with a clear error suggesting `sudo` or an npm prefix configuration change.
- If the project directory is read-only, init fails before making any changes and reports the permission issue.
- If network connectivity is unavailable during npm install, the system reports a network error with a suggestion to retry.
- No duplicate skill creation — init does not create `.claude/skills/openspec-*` files that would duplicate the plugin's `/opsx:*` skills.

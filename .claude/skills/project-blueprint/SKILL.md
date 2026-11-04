---
name: project-blueprint
description: >
  Thai triggers: "วางโครงสร้างโปรเจกต์", "จัดระเบียบโปรเจกต์", "project structure", "blueprint", "dashboard architecture".
  Use this skill when scaffolding, reviewing, or refactoring a project's structure.
  Role-based and stack-agnostic: UI, feature flow, pure logic, integration, config/tokens, types, data, tests;
  expressed by size (filename suffix, folders, or modules). Repos with their own enforced layout keep it.
version: 1.2.0
---

# Project Blueprint: Structure Standard

Full rule: `rules/coding/project-blueprint.md` (roles, root layout, size trees, dependency direction, checklist). Read it first.

## Scaffold (new project)
1. Pick size (§3) and keep the framework's `<source-root>` name.
2. Create §2 root files, then only the role dirs the project actually needs.
3. Config/tokens first (§1 Config), then logic, then UI — dependency direction §4.

## Bend a rule
Record `- §<rule> — <why> — <revisit when>` (MUST needs an external constraint; STRONG needs a revisit date) under `## Structure deviations` in the project's ARCHITECTURE.md. Never silently skip.

## Review (existing project)
Run the §7 checklist; report PASS/FAIL/WARN/ACCEPTED per line with file evidence (MUST = fail, STRONG = fail unless fixed or recorded with a revisit date, SHOULD = warn, recorded deviation = accepted). Do not refactor without the user's approval;
list violations with the smallest fix. Repo with its own enforced layout, or a read-only clone? Stop.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a structure rule that did not fit a real project, or a missing role/alias.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.

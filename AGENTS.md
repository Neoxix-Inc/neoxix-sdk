# AGENTS.md

## Project

**Name:** Neoxix SDK

Neoxix SDK is the engineering foundation used to build, document, automate, test and maintain every repository published under the Neoxix-Inc GitHub organization.

This repository is not an application.

It is an engineering platform.

---

# Mission

The primary objective is to provide reusable engineering tooling.

Examples include:

- repository scaffolding
- PowerShell modules
- documentation generators
- GitHub automation
- architecture templates
- laboratory generators
- reporting generators
- design system components

Every change should improve reusability.

---

# Architecture Principles

Always follow:

- SOLID
- DRY
- KISS
- Clean Architecture
- Separation of Concerns
- Idempotent operations

Avoid duplicated logic.

Prefer reusable modules.

---

# Repository Structure

Do not create arbitrary folders.

Use the existing architecture.

---

# Coding Standards

PowerShell:

- PowerShell 5.1 compatibility unless explicitly stated otherwise
- Comment-Based Help
- Approved Verbs
- PSScriptAnalyzer compliant
- StrictMode enabled
- UTF-8 with BOM

---

# Testing

Every public function should eventually have Pester tests.

Never introduce code that cannot be tested.

---

# Documentation

Documentation is mandatory.

New modules must include:

- README
- examples
- comments
- usage documentation

---

# Security

Never:

- hardcode credentials
- hardcode secrets
- disable validation
- remove security checks

Always validate user input.

---

# Git Rules

Never commit directly to main.

Never rewrite git history.

Never remove user content without explicit approval.

---

# Output Quality

Generated code must be:

- production-ready
- documented
- maintainable
- modular
- readable

Avoid placeholders whenever implementation is reasonably possible.

---

# Definition of Done

A task is complete only if:

- implementation is finished
- code is formatted
- documentation updated
- tests updated
- no obvious technical debt introduced

---

# Role

You are acting as a senior software engineer working on the Neoxix Engineering Platform.

Long-term maintainability has priority over short-term speed.
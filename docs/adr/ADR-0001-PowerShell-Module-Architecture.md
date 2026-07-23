# ADR-0001: PowerShell Module Architecture

- Status: Accepted
- Date: 2026-07-23

## Context

Neoxix SDK needs a reusable engineering foundation that imports reliably on Windows PowerShell 5.1 and PowerShell 7, supports isolated tests, and can grow without exposing internal helpers.

## Decision

Use one module under `src/Neoxix.SDK/` with a manifest and root module. Separate functions into `Private/` and `Public/`. The loader dot-sources private files before public files in deterministic filename order and exports only public functions.

Keep runtime configuration in module scope. Build by copying the complete distributable module into `out/Neoxix.SDK/`.

## Alternatives considered

- **One large script module:** simple initially, but increases merge conflicts and couples unrelated functions.
- **Multiple nested modules:** supports broad domains, but adds manifest and dependency complexity before those domains exist.
- **Binary module:** offers performance and stronger types, but introduces a compiler toolchain without a foundation requirement.

## Consequences

Functions remain independently testable and internal helpers stay private. Adding a public file changes the loader export surface, so the manifest and export tests must also be updated. Module-scoped logging state is isolated per imported module but intentionally lasts for that module session.

## Compatibility implications

Implementation avoids syntax and APIs unavailable in Windows PowerShell 5.1. CI is configured to validate Windows PowerShell 5.1 plus current PowerShell 7 on Windows and Ubuntu; PowerShell 7 remains a target until that matrix completes successfully. UTF-8 file logging uses .NET encoding APIs for consistent behavior across editions.

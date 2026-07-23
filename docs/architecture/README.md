# Architecture

Neoxix SDK is a single source module under `src/Neoxix.SDK/`. Its loader imports private implementation functions first, then public commands, and exports only the public command set declared by the manifest.

Runtime state is confined to module scope. Paths are resolved from `$PSScriptRoot` or explicit caller input, keeping the module portable and testable.

See [ADR-0001](../adr/ADR-0001-PowerShell-Module-Architecture.md) for the decision record.

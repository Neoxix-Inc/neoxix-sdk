# NSDK-001 — Neoxix SDK Foundation

## Status

Ready for implementation

## Priority

Critical

## Target release

`v0.1.0`

## Repository

`Neoxix-Inc/neoxix-sdk`

---

## 1. Mission

Transform the current `neoxix-sdk` repository into a clean, testable and maintainable PowerShell module project.

This mission establishes the engineering foundation only. Do not implement repository generators, lab generators, documentation generators or other advanced product features.

---

## 2. Required preliminary inspection

Before modifying anything:

1. Read `AGENTS.md`.
2. Read `docs/SPEC.md`.
3. Inspect the complete repository tree.
4. Inspect the current Git status and active branch.
5. Preserve all valid existing work.
6. Identify duplicate, misplaced or empty files.
7. Summarize the planned changes before implementation.

Do not assume that the repository is empty.

---

## 3. Git workflow

Create and work on this branch:

```text
feat/nsdk-001-foundation
```

Rules:

- Do not commit directly to `main`.
- Do not rewrite Git history.
- Do not force-push.
- Do not merge the branch.
- Do not create a release.
- Do not publish to PowerShell Gallery.
- Do not change repository visibility or GitHub permissions.

Prepare a clean implementation that can later be reviewed through a pull request.

---

## 4. Target repository structure

Create or normalize the following structure:

```text
neoxix-sdk/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   ├── documentation.yml
│   │   └── config.yml
│   ├── workflows/
│   │   └── ci.yml
│   ├── CODEOWNERS
│   └── PULL_REQUEST_TEMPLATE.md
├── build/
│   └── build.ps1
├── docs/
│   ├── adr/
│   │   ├── README.md
│   │   └── ADR-0001-PowerShell-Module-Architecture.md
│   ├── architecture/
│   │   └── README.md
│   ├── missions/
│   │   └── NSDK-001-Foundation.md
│   ├── SPEC.md
│   └── README.md
├── examples/
│   └── README.md
├── src/
│   └── Neoxix.SDK/
│       ├── Classes/
│       │   └── .gitkeep
│       ├── Private/
│       │   └── Write-NeoxixLog.ps1
│       ├── Public/
│       │   ├── Get-NeoxixSdkInfo.ps1
│       │   ├── Start-NeoxixLog.ps1
│       │   ├── Stop-NeoxixLog.ps1
│       │   ├── Write-NeoxixDebug.ps1
│       │   ├── Write-NeoxixError.ps1
│       │   ├── Write-NeoxixInfo.ps1
│       │   ├── Write-NeoxixSuccess.ps1
│       │   └── Write-NeoxixWarning.ps1
│       ├── Resources/
│       │   └── .gitkeep
│       ├── Neoxix.SDK.psd1
│       └── Neoxix.SDK.psm1
├── templates/
│   └── README.md
├── tests/
│   ├── Unit/
│   │   ├── Logging.Tests.ps1
│   │   └── Module.Tests.ps1
│   ├── Integration/
│   │   └── ModuleImport.Tests.ps1
│   └── TestHelpers.ps1
├── tools/
│   └── Install-Dependencies.ps1
├── .editorconfig
├── .gitattributes
├── .gitignore
├── .markdownlint.json
├── PSScriptAnalyzerSettings.psd1
├── AGENTS.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── ROADMAP.md
├── SECURITY.md
└── VERSION
```

You may make small structural improvements when technically justified, but document them in the implementation summary.

---

## 5. PowerShell module requirements

### 5.1 Compatibility

The module must support:

- Windows PowerShell 5.1
- PowerShell 7+

### 5.2 Module loader

`Neoxix.SDK.psm1` must:

1. enable `Set-StrictMode -Version Latest`;
2. load private functions before public functions;
3. dot-source all valid `.ps1` files deterministically;
4. export only public functions;
5. avoid silently swallowing import errors;
6. use paths relative to `$PSScriptRoot`;
7. remain compatible with PowerShell 5.1.

### 5.3 Module manifest

`Neoxix.SDK.psd1` must define at least:

- `RootModule`
- `ModuleVersion`
- `GUID`
- `Author`
- `CompanyName`
- `Copyright`
- `Description`
- `PowerShellVersion`
- `FunctionsToExport`
- `CmdletsToExport`
- `VariablesToExport`
- `AliasesToExport`
- `PrivateData.PSData`
- project URL
- license URL
- release notes

Initial module version:

```text
0.1.0
```

### 5.4 Public foundation functions

Implement:

```powershell
Get-NeoxixSdkInfo
Start-NeoxixLog
Stop-NeoxixLog
Write-NeoxixInfo
Write-NeoxixSuccess
Write-NeoxixWarning
Write-NeoxixError
Write-NeoxixDebug
```

All public functions must:

- use approved PowerShell verbs;
- use `[CmdletBinding()]`;
- include comment-based help;
- validate parameters;
- avoid hardcoded repository paths;
- avoid global mutable state;
- be testable;
- use terminating errors when execution cannot safely continue.

### 5.5 SDK information

`Get-NeoxixSdkInfo` must return a structured `PSCustomObject` containing at least:

- module name;
- module version;
- PowerShell version;
- operating system;
- module path;
- current timestamp.

Do not return formatted text from this function.

### 5.6 Logging

The logging implementation must support:

- `INFO`
- `SUCCESS`
- `WARNING`
- `ERROR`
- `DEBUG`
- timestamps;
- optional file logging;
- UTF-8 output;
- debug enablement;
- no plaintext secrets;
- no dependency on a specific repository location.

Console formatting must not prevent pipeline use or automated testing.

---

## 6. Code quality

Apply these rules:

- PowerShell approved verbs;
- PascalCase function names;
- four-space indentation;
- meaningful parameter names;
- no aliases in production scripts;
- no `Write-Host` outside explicitly presentation-oriented code;
- no empty `catch` blocks;
- no hardcoded credentials or tokens;
- no disabling TLS or certificate validation;
- no destructive operation without explicit confirmation;
- no unnecessary duplication;
- no placeholder implementation presented as complete.

Use UTF-8 consistently. Preserve Windows PowerShell 5.1 compatibility when choosing encoding APIs.

---

## 7. PSScriptAnalyzer

Create `PSScriptAnalyzerSettings.psd1`.

The configuration must:

- enable the standard recommended rules;
- detect unapproved verbs;
- detect unused variables;
- detect use of aliases;
- detect plaintext credentials;
- detect insecure command patterns where supported;
- avoid broad exclusions without documented justification.

The following command must succeed without error-level findings:

```powershell
Invoke-ScriptAnalyzer `
    -Path .\src\Neoxix.SDK `
    -Recurse `
    -Settings .\PSScriptAnalyzerSettings.psd1
```

Warnings must either be corrected or explicitly justified in the implementation report.

---

## 8. Pester tests

Use Pester 5.

Tests must cover at least:

### Module tests

- manifest validity;
- successful module import;
- expected exported functions;
- absence of unintended exported functions;
- version consistency between `VERSION` and the manifest.

### Logging tests

- each logging function exists;
- messages contain the expected level;
- debug output is suppressed when debug mode is disabled;
- debug output is produced when debug mode is enabled;
- log file creation;
- log file content;
- stopping the log resets logging state;
- invalid paths or parameters fail predictably.

### SDK information tests

- returns a `PSCustomObject`;
- returns all mandatory properties;
- reports the manifest version correctly.

Test command:

```powershell
Invoke-Pester -Path .\tests -CI
```

All tests must pass.

Do not create tests that merely assert that `$true` is `$true`.

---

## 9. Build script

Create `build/build.ps1` with support for:

```powershell
.\build\build.ps1 -Task Clean
.\build\build.ps1 -Task Analyze
.\build\build.ps1 -Task Test
.\build\build.ps1 -Task Build
.\build\build.ps1 -Task Validate
```

Required behavior:

- `Clean`: removes generated build output only;
- `Analyze`: runs PSScriptAnalyzer;
- `Test`: runs Pester;
- `Build`: copies the distributable module to a build output directory;
- `Validate`: runs manifest validation, analysis and tests.

The script must:

- use `[CmdletBinding()]`;
- validate the task value;
- stop on failures;
- return a non-zero exit code when validation fails;
- avoid deleting source files;
- work from any current working directory.

Generated output must be placed under:

```text
out/
```

Add `out/` to `.gitignore`.

---

## 10. Dependency bootstrap

Create `tools/Install-Dependencies.ps1`.

It must:

- detect whether Pester 5 is available;
- detect whether PSScriptAnalyzer is available;
- install missing modules only after explicit user approval, unless a non-interactive switch is supplied;
- support a CI/non-interactive mode;
- install modules for `CurrentUser`;
- avoid changing execution policy;
- provide clear error messages.

Do not embed API keys or external package credentials.

---

## 11. GitHub Actions CI

Create `.github/workflows/ci.yml`.

The pipeline must run on:

- pull requests targeting `main`;
- pushes to `main`;
- manual dispatch.

Use a matrix containing at least:

- Windows with Windows PowerShell 5.1 where technically possible;
- Windows with current PowerShell 7;
- Ubuntu with current PowerShell 7.

Pipeline stages:

1. checkout;
2. install required PowerShell modules;
3. validate the module manifest;
4. run PSScriptAnalyzer;
5. run Pester;
6. run the build validation task;
7. upload test results or useful artifacts when available.

Security requirements:

- pin GitHub Actions to stable major versions or commit SHAs;
- use minimum required permissions;
- do not expose repository secrets;
- do not execute untrusted scripts from arbitrary URLs.

---

## 12. Repository governance files

Create production-quality versions of:

- `README.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `LICENSE`
- `.gitignore`
- `.gitattributes`
- `.editorconfig`
- `.markdownlint.json`
- GitHub issue templates;
- pull request template;
- `CODEOWNERS`.

### README requirements

The README must include:

- project purpose;
- status warning indicating early development;
- supported PowerShell versions;
- installation from source;
- quick-start example;
- available foundation commands;
- development setup;
- test commands;
- repository structure;
- security statement;
- contribution link;
- license link.

Do not claim that the SDK supports features not yet implemented.

### License

Use the MIT license with:

```text
Copyright (c) 2026 Neoxix Inc.
```

### Security policy

`SECURITY.md` must:

- instruct users not to disclose vulnerabilities in public issues;
- define the currently supported version policy;
- explain how to report a vulnerability without inventing an unverified email address;
- direct users to GitHub private vulnerability reporting when enabled.

---

## 13. Architecture documentation

Create:

```text
docs/adr/ADR-0001-PowerShell-Module-Architecture.md
```

The ADR must document:

- context;
- decision;
- alternatives considered;
- consequences;
- status;
- compatibility implications.

The selected decision is a single PowerShell module under:

```text
src/Neoxix.SDK/
```

with public and private function separation.

Also create concise navigation README files for:

- `docs/`
- `docs/architecture/`
- `docs/adr/`
- `examples/`
- `templates/`

---

## 14. Versioning

Create:

```text
VERSION
```

with:

```text
0.1.0
```

The version must match `ModuleVersion` in `Neoxix.SDK.psd1`.

Use Semantic Versioning.

Initialize `CHANGELOG.md` with:

```text
## [Unreleased]
```

and a foundation entry for `0.1.0` only when the implementation is complete.

Do not create a GitHub release or tag.

---

## 15. Security constraints

Do not:

- add credentials;
- add certificates;
- add private keys;
- add environment secrets;
- weaken Git security controls;
- disable SSL/TLS validation;
- download and execute unverified remote scripts;
- collect telemetry;
- transmit repository data externally;
- include production data;
- modify GitHub organization settings;
- enable automatic publishing.

Run a repository search before completion for patterns resembling:

- passwords;
- tokens;
- private keys;
- connection strings;
- API keys.

Report the result without exposing any discovered secret value.

---

## 16. Scope exclusions

This mission must not implement:

- `New-NeoxixRepository`;
- `New-NeoxixLab`;
- README generation engines;
- banner generators;
- design-system generation;
- GitHub release publishing;
- PowerShell Gallery publishing;
- AI integrations;
- external APIs;
- SOC-specific features;
- CCNA or Fortinet laboratory logic.

These belong to later missions.

---

## 17. Acceptance criteria

The mission is accepted only when all conditions below are satisfied.

### Structure

- [ ] Target structure exists.
- [ ] No unjustified duplicate folder exists.
- [ ] Existing valid user content is preserved.

### Module

- [ ] `Test-ModuleManifest` succeeds.
- [ ] Module imports in Windows PowerShell 5.1.
- [ ] Module imports in PowerShell 7+.
- [ ] Only intended public functions are exported.
- [ ] All public functions include help.

### Quality

- [ ] PSScriptAnalyzer has no error-level finding.
- [ ] All Pester tests pass.
- [ ] Build validation succeeds.
- [ ] No secret is committed.
- [ ] Files use consistent encoding and line endings.

### CI

- [ ] Workflow YAML is valid.
- [ ] CI runs analysis and tests.
- [ ] Workflow uses minimal permissions.

### Documentation

- [ ] README accurately reflects implemented features.
- [ ] Contribution and security policies exist.
- [ ] ADR-0001 exists.
- [ ] CHANGELOG and ROADMAP are initialized.
- [ ] Commands shown in documentation are executable.

---

## 18. Required validation commands

Run and report the results of:

```powershell
git status --short
```

```powershell
Test-ModuleManifest ".\src\Neoxix.SDK\Neoxix.SDK.psd1"
```

```powershell
Import-Module ".\src\Neoxix.SDK\Neoxix.SDK.psd1" -Force
Get-Command -Module Neoxix.SDK
```

```powershell
Invoke-ScriptAnalyzer `
    -Path ".\src\Neoxix.SDK" `
    -Recurse `
    -Settings ".\PSScriptAnalyzerSettings.psd1"
```

```powershell
Invoke-Pester -Path ".\tests" -CI
```

```powershell
& ".\build\build.ps1" -Task Validate
```

When a command cannot run because a required dependency is missing, install it through the repository bootstrap process and document the action.

---

## 19. Final Codex report

At completion, provide a structured report containing:

### Summary

What was implemented.

### Files

Files created, modified, moved or removed.

### Architecture

Important structural decisions and their rationale.

### Validation

Commands executed and exact results.

### Tests

Number of tests passed, failed and skipped.

### Static analysis

PSScriptAnalyzer results.

### Security

Secret-scan summary and security-relevant decisions.

### Risks

Known limitations or remaining risks.

### Deferred work

Items intentionally excluded from this mission.

### Review instructions

The most important files and diffs the human reviewer should inspect.

Do not state that the mission is complete when required validation is failing.

---

## 20. Definition of Done

NSDK-001 is complete only when:

- the foundation is fully implemented;
- the repository is coherent;
- the module is importable;
- tests pass;
- static analysis passes at the required level;
- CI configuration is present;
- documentation is accurate;
- no secret or sensitive information is included;
- the implementation is ready for human review;
- no direct merge to `main` has occurred.
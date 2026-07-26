# NSDK-002.1 — Environment Detection

## Status

Ready for implementation

## Priority

High

## Target release

`v0.2.0`

## Repository

`Neoxix-Inc/neoxix-sdk`

---

## 1. Mission

Implement a reliable, testable and cross-platform environment detection capability for Neoxix SDK.

This mission must provide structured information about the host operating system, PowerShell runtime and selected development tools without modifying the machine.

---

## 2. Preliminary inspection

Before modifying the repository:

1. Read `AGENTS.md`.
2. Read `docs/SPEC.md`.
3. Read this mission completely.
4. Inspect the current branch and Git status.
5. Inspect the existing module loader, manifest, tests and public functions.
6. Preserve all valid existing work.
7. Present a concise implementation plan before editing files.

Do not create another branch. Work only on:

```text
feat/nsdk-002-1-environment
```

---

## 3. Scope

Implement the public function:

```powershell
Get-NeoxixEnvironment
```

It must detect and return information about:

- operating system;
- operating-system version;
- platform family;
- CPU architecture;
- PowerShell edition;
- PowerShell version;
- process architecture;
- whether the session is elevated;
- whether the session is interactive;
- current user;
- computer or host name;
- current culture;
- current time zone;
- Git availability and version;
- GitHub CLI availability and version;
- Visual Studio Code availability and version;
- Docker CLI availability and version;
- WSL availability on Windows;
- Pester availability and highest installed version;
- PSScriptAnalyzer availability and highest installed version;
- CI environment detection;
- supported Neoxix SDK status.

This mission is read-only. It must not install, configure or modify any software.

---

## 4. Target files

Create:

```text
src/Neoxix.SDK/Public/Get-NeoxixEnvironment.ps1
tests/Unit/Environment.Tests.ps1
docs/api/Get-NeoxixEnvironment.md
examples/environment-detection.ps1
```

Update when required:

```text
src/Neoxix.SDK/Neoxix.SDK.psd1
README.md
CHANGELOG.md
ROADMAP.md
docs/README.md
examples/README.md
```

Do not create arbitrary directories outside the existing architecture.

---

## 5. Public function contract

### Syntax

```powershell
Get-NeoxixEnvironment
```

The function must require no mandatory parameter.

Optional parameters may be introduced only when technically justified.

### Output

Return exactly one structured `PSCustomObject`.

Do not return formatted text.

The object must contain at least these properties:

```text
OperatingSystem
OperatingSystemVersion
Platform
ComputerName
CurrentUser
IsAdministrator
IsInteractive
Culture
TimeZone
PowerShellEdition
PowerShellVersion
ProcessArchitecture
OperatingSystemArchitecture
GitAvailable
GitVersion
GitHubCliAvailable
GitHubCliVersion
VisualStudioCodeAvailable
VisualStudioCodeVersion
DockerAvailable
DockerVersion
WslAvailable
PesterAvailable
PesterVersion
PSScriptAnalyzerAvailable
PSScriptAnalyzerVersion
IsCI
CIProvider
SdkSupported
DetectionTimestamp
```

### Required property types

- Boolean properties must return `[bool]`.
- Version properties should return `[version]` when safely parseable.
- `DetectionTimestamp` must return `[datetime]`.
- Missing optional software must return:
  - `Available = $false`;
  - corresponding version property as `$null`.

Do not use empty strings to represent missing software versions.

---

## 6. Platform detection requirements

### Windows

Detect Windows without relying exclusively on PowerShell 7 automatic variables.

The implementation must remain compatible with Windows PowerShell 5.1.

Detect:

- Windows platform;
- Windows version;
- administrator status;
- WSL availability;
- OS architecture.

Avoid WMI when a lightweight and reliable .NET API is sufficient.

CIM/WMI failures must not make the entire function fail unless core OS detection becomes impossible.

### Linux

Detect:

- Linux platform;
- OS description or distribution when available;
- elevation through effective user or equivalent reliable mechanism;
- architecture.

Do not assume `/etc/os-release` always exists.

### macOS

Detect:

- macOS platform;
- operating-system version;
- elevation;
- architecture.

### Unknown platform

Return:

```text
Platform = Unknown
```

Do not throw merely because the operating system is unsupported.

---

## 7. Tool detection

Use safe command discovery:

```powershell
Get-Command
```

Do not execute a tool merely to determine availability.

Version retrieval may execute only these commands when available:

```text
git --version
gh --version
code --version
docker --version
```

Requirements:

- use no shell aliases;
- apply timeouts when technically possible;
- capture errors safely;
- do not expose command stderr as normal function output;
- parse versions defensively;
- return `$null` when parsing fails;
- do not throw because an optional tool is broken or unavailable.

Do not download or install tools.

---

## 8. CI detection

Detect common CI environments using environment variables.

Support at least:

- GitHub Actions;
- Azure DevOps;
- GitLab CI;
- Jenkins;
- generic `CI=true`.

Return:

```text
IsCI
CIProvider
```

Example provider values:

```text
GitHubActions
AzureDevOps
GitLabCI
Jenkins
Generic
None
```

Do not expose secret environment-variable values.

---

## 9. SDK support evaluation

`SdkSupported` must indicate whether the current runtime meets the SDK baseline:

- Windows PowerShell 5.1; or
- PowerShell 7 or later;
- supported platform: Windows, Linux or macOS.

The property must be deterministic and documented.

Do not block execution on unsupported systems. Return the result in the object.

---

## 10. Security requirements

The function must:

- remain read-only;
- not enumerate arbitrary environment variables;
- not return tokens, passwords, secrets or credentials;
- not transmit telemetry;
- not access external networks;
- not modify execution policy;
- not invoke elevated processes;
- not read private user files;
- not write files;
- not persist detected information.

Tool version commands must be invoked without user-controlled arguments.

---

## 11. Reliability requirements

The function must:

- use `[CmdletBinding()]`;
- use comment-based help;
- enable no global state;
- avoid terminating because an optional tool is missing;
- avoid writing progress or host messages;
- produce no unintended pipeline output;
- work from any current directory;
- work when the module is imported from another path;
- execute repeatedly with consistent property structure.

Optional detection failures may be represented through `$false` and `$null`.

Core runtime detection failures must produce a clear terminating error.

---

## 12. PowerShell quality rules

Follow:

- PowerShell 5.1 compatibility;
- approved verbs;
- PascalCase naming;
- four-space indentation;
- no aliases;
- no `Write-Host`;
- no empty catch blocks;
- no global variables;
- no hardcoded repository path;
- PSScriptAnalyzer compliance;
- UTF-8 encoding consistent with repository policy.

Any private helper must be placed under:

```text
src/Neoxix.SDK/Private/
```

Only create helpers when they reduce duplication or improve testability.

---

## 13. Tests

Use Pester 5.

Tests must cover at least:

### Contract

- function is exported;
- command imports successfully;
- returns exactly one object;
- returns a `PSCustomObject`;
- contains all required properties;
- Boolean properties use Boolean values;
- timestamp uses DateTime;
- PowerShell version matches the active runtime;
- process architecture is not empty;
- platform is one of:
  - `Windows`;
  - `Linux`;
  - `macOS`;
  - `Unknown`.

### Tool detection

Use mocks where appropriate.

Verify:

- unavailable Git returns false and null version;
- available Git returns true;
- malformed version output does not throw;
- unavailable `gh`, `code` and `docker` do not throw;
- optional tool stderr does not leak into pipeline output;
- Pester version selection uses the highest compatible installed version;
- PSScriptAnalyzer version selection is correct.

### CI detection

Test:

- GitHub Actions;
- Azure DevOps;
- GitLab CI;
- Jenkins;
- generic CI;
- no CI environment.

Restore environment variables after each test.

### Security and behavior

Verify:

- no files are created;
- no secret environment-variable value appears in output;
- no network command is invoked;
- no installation command is invoked;
- repeated calls preserve the same property schema;
- output is pipeline-safe.

### Compatibility

Tests must avoid syntax unavailable in Windows PowerShell 5.1.

---

## 14. Documentation

Create:

```text
docs/api/Get-NeoxixEnvironment.md
```

Document:

- purpose;
- syntax;
- output properties;
- examples;
- missing-tool behavior;
- CI detection;
- support calculation;
- security and privacy behavior;
- cross-platform limitations.

Add a concise example:

```powershell
$Environment = Get-NeoxixEnvironment

$Environment.Platform
$Environment.PowerShellVersion
$Environment.GitAvailable
$Environment.IsCI
```

Update the main README only with features actually implemented.

---

## 15. Example script

Create:

```text
examples/environment-detection.ps1
```

It must:

- import the module from the repository source;
- call `Get-NeoxixEnvironment`;
- show safe structured-property selection;
- avoid `Format-Table` inside reusable functions;
- contain no machine-specific path;
- work from its own location through `$PSScriptRoot`.

---

## 16. Manifest and versioning

Add:

```text
Get-NeoxixEnvironment
```

to `FunctionsToExport`.

Do not change the module version unless the repository versioning policy explicitly requires it for this mission.

Update `CHANGELOG.md` under:

```text
## [Unreleased]
```

Add a concise entry describing environment detection.

Update `ROADMAP.md` to reflect progress without marking the entire Core Framework complete.

---

## 17. Scope exclusions

Do not implement:

- environment configuration;
- dependency installation;
- repository creation;
- path management;
- configuration files;
- validation framework;
- telemetry;
- remote inventory;
- hardware inventory beyond architecture;
- network-interface enumeration;
- installed-application inventory;
- Active Directory discovery;
- cloud-provider discovery;
- WSL distribution inventory;
- Docker daemon inspection;
- GitHub authentication inspection.

These belong to later missions.

---

## 18. Acceptance criteria

### Functionality

- [ ] `Get-NeoxixEnvironment` is exported.
- [ ] It returns one structured object.
- [ ] All mandatory properties exist.
- [ ] Missing optional tools do not cause failure.
- [ ] Windows PowerShell 5.1 compatibility is preserved.
- [ ] PowerShell 7 compatibility is covered by tests and CI.
- [ ] CI-provider detection works.
- [ ] No secret is returned.
- [ ] No system modification occurs.

### Quality

- [ ] PSScriptAnalyzer returns no error-level findings.
- [ ] All Pester tests pass.
- [ ] Build validation passes.
- [ ] Documentation is accurate.
- [ ] No unsupported feature is claimed.
- [ ] No unrelated file is modified.

---

## 19. Required validation commands

Run and report:

```powershell
git status --short
```

```powershell
Test-ModuleManifest ".\src\Neoxix.SDK\Neoxix.SDK.psd1"
```

```powershell
Import-Module ".\src\Neoxix.SDK\Neoxix.SDK.psd1" -Force
Get-Command Get-NeoxixEnvironment
```

```powershell
Get-NeoxixEnvironment |
    Select-Object Platform, PowerShellVersion, GitAvailable, IsCI
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

Also verify that no unexpected file is created by calling the function.

---

## 20. Git workflow

Rules:

- remain on `feat/nsdk-002-1-environment`;
- do not commit directly to `main`;
- do not merge;
- do not tag;
- do not publish;
- do not push without explicit approval;
- do not rewrite shared history;
- leave changes ready for human review.

---

## 21. Final Codex report

Provide:

### Summary

What was implemented.

### Files

Files created and modified.

### Function contract

Final output schema and behavior.

### Platform handling

Windows, Linux, macOS and unknown-platform behavior.

### Tool detection

Tools detected and failure behavior.

### Tests

Passed, failed and skipped counts.

### Static analysis

PSScriptAnalyzer results.

### Validation

Exact validation commands and exit results.

### Security

Confirmation that no secrets, telemetry or modifications were introduced.

### Risks

Remaining limitations.

### Deferred work

Explicitly excluded items.

### Review instructions

Files and logic requiring priority human review.

Do not declare completion while any mandatory validation is failing.

---

## 22. Definition of Done

NSDK-002.1 is complete only when:

- implementation is finished;
- function contract is stable;
- tests pass;
- static analysis passes;
- build validation succeeds;
- documentation is updated;
- no secret or sensitive value is exposed;
- no system modification is performed;
- changes are ready for human review;
- no push or merge occurred without approval.
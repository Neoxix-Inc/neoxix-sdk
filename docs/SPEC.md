# Neoxix SDK Specification

## Purpose

Neoxix SDK provides reusable, testable engineering tooling for Neoxix repositories. It is a platform module, not an application.

## Foundation scope

Version 0.1.0 defines:

- one PowerShell module under `src/Neoxix.SDK/`;
- deterministic private-then-public function loading;
- structured runtime metadata;
- structured console-friendly logging with optional UTF-8 file output;
- validated Windows PowerShell 5.1 behavior and targeted PowerShell 7 compatibility, confirmed only after a successful CI matrix run;
- Pester, PSScriptAnalyzer, build, and CI validation.

Generators, publishing, AI integrations, external APIs, and domain-specific lab logic are outside this foundation specification.

## Engineering constraints

Public functions use approved verbs, advanced function binding, validation, comment-based help, and terminating errors when safe continuation is impossible. No credentials, telemetry, or repository-specific runtime path is embedded.

Logging normalizes control characters to one physical line and masks recognizable named secrets, bearer credentials, common token formats, and private-key blocks before producing any output.

The manifest and `VERSION` use Semantic Versioning and must remain consistent. Generated artifacts belong only under `out/`.

## Quality gates

A change is reviewable only after manifest validation, static analysis, Pester tests, build validation, and a repository secret-pattern scan.

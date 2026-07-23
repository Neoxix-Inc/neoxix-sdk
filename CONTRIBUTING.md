# Contributing

Thank you for improving the Neoxix engineering platform.

## Workflow

1. Open or reference an issue that describes the reusable engineering need.
2. Create a focused branch; never commit directly to `main`.
3. Follow `AGENTS.md`, PowerShell 5.1 compatibility, and existing architecture.
4. Add comment-based help, documentation, and meaningful Pester tests.
5. Run `.\build\build.ps1 -Task Validate`.
6. Open a pull request using the repository template.

Keep changes modular, idempotent, validated, and free of credentials or production data. Report vulnerabilities privately according to [SECURITY.md](SECURITY.md).

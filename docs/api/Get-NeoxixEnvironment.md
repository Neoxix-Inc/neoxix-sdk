# Get-NeoxixEnvironment

## Purpose

`Get-NeoxixEnvironment` returns one structured snapshot of the local operating system, PowerShell runtime, CI context, and selected development tools. Detection is read-only and does not use a network.

## Syntax

```powershell
Get-NeoxixEnvironment
```

The command has no mandatory or optional parameters.

## Example

```powershell
$Environment = Get-NeoxixEnvironment

$Environment.Platform
$Environment.PowerShellVersion
$Environment.GitAvailable
$Environment.IsCI
```

## Output properties

| Property | Type and behavior |
| --- | --- |
| `OperatingSystem` | OS description or distribution name when available |
| `OperatingSystemVersion` | OS version |
| `Platform` | `Windows`, `Linux`, `macOS`, or `Unknown` |
| `ComputerName` | Local host name |
| `CurrentUser` | Current Windows identity or local user name |
| `IsAdministrator` | Boolean elevation status |
| `IsInteractive` | Boolean console-interaction status, false in detected CI |
| `Culture` | Current culture name |
| `TimeZone` | Local time-zone identifier |
| `PowerShellEdition` | Active PowerShell edition |
| `PowerShellVersion` | Active runtime as `[version]` |
| `ProcessArchitecture` | Current process architecture |
| `OperatingSystemArchitecture` | Host OS architecture |
| `GitAvailable`, `GitVersion` | Git discovery and parsed version |
| `GitHubCliAvailable`, `GitHubCliVersion` | GitHub CLI discovery and parsed version |
| `VisualStudioCodeAvailable`, `VisualStudioCodeVersion` | VS Code CLI discovery and parsed version |
| `DockerAvailable`, `DockerVersion` | Docker CLI discovery and parsed version |
| `WslAvailable` | Whether `wsl.exe` is discoverable on Windows |
| `PesterAvailable`, `PesterVersion` | Highest compatible installed Pester 5.x version |
| `PSScriptAnalyzerAvailable`, `PSScriptAnalyzerVersion` | Highest compatible installed analyzer 1.20–1.x version |
| `IsCI`, `CIProvider` | CI state and provider |
| `SdkSupported` | Whether the platform and PowerShell runtime meet the SDK baseline |
| `DetectionTimestamp` | Local detection time as `[datetime]` |

## Missing and broken tools

Availability uses `Get-Command`. Missing tools return `$false` and a `$null` version. A discovered tool with an unreadable, malformed, or timed-out version remains available but returns a `$null` version. Tool stderr is captured and is never returned as normal output.

Only the following fixed commands may be executed, with a five-second timeout:

- `git --version`
- `gh --version`
- `code --version`
- `docker --version`

No Docker daemon or authentication state is inspected.

## CI detection

The command checks only named, non-secret markers for GitHub Actions, Azure DevOps, GitLab CI, Jenkins, and generic `CI=true`. Provider precedence follows that order. It does not enumerate or return environment-variable values.

## SDK support calculation

`SdkSupported` is true only when both conditions hold:

1. the platform is Windows, Linux, or macOS;
2. the runtime is Windows PowerShell 5.1 or later in the Desktop edition, or PowerShell 7 or later in the Core edition.

Unsupported environments are reported and do not cause the command to terminate.

## Security and privacy

Detection installs nothing, writes no persistent file, changes no policy, starts no elevated process, accesses no network, and sends no telemetry. Linux distribution naming may read the public system file `/etc/os-release`.

For `gh --version`, the child process receives a unique, non-existent `GH_CONFIG_DIR` path under the operating-system temporary directory. This prevents GitHub CLI from consulting the user's normal configuration. `GH_TOKEN`, `GITHUB_TOKEN`, `GH_ENTERPRISE_TOKEN`, and `GITHUB_ENTERPRISE_TOKEN` are removed from that child environment. Version detection does not create the temporary directory; if a future CLI version were to create it unexpectedly, that behavior is treated as a defect and covered by the non-writing tests.

## Cross-platform limitations

- On Unix, elevation is inferred from the effective user name being `root`.
- OS descriptions depend on .NET and may vary between hosts.
- When .NET runtime platform information is unavailable, only Windows can be identified reliably from `PlatformID`. An ambiguous Unix value is reported as `Unknown`, never guessed as Linux or macOS.
- Architecture names come from .NET runtime information when available. The compatibility fallback distinguishes a 32-bit process from a 64-bit operating system, but cannot identify ARM variants and reports X86/X64 only.
- `WslAvailable` reports command availability on Windows; it does not enumerate distributions.
- Tool versions are best-effort and remain `$null` when output cannot be parsed safely.

<#
.SYNOPSIS
    Demonstrates safe structured environment detection from the repository source.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
$manifestPath = Join-Path `
    -Path $repositoryRoot `
    -ChildPath 'src\Neoxix.SDK\Neoxix.SDK.psd1'

Import-Module -Name $manifestPath -Force -ErrorAction Stop

$environment = Get-NeoxixEnvironment
$environment |
    Select-Object `
        Platform,
        PowerShellVersion,
        ProcessArchitecture,
        GitAvailable,
        IsCI,
        CIProvider,
        SdkSupported

<#
.SYNOPSIS
    Installs the development dependencies required by Neoxix SDK.
.DESCRIPTION
    Detects compatible Pester 5 and PSScriptAnalyzer versions and installs only
    missing modules after explicit approval.
.PARAMETER NonInteractive
    Installs missing dependencies without confirmation, suitable for CI.
.EXAMPLE
    .\tools\Install-Dependencies.ps1
.EXAMPLE
    .\tools\Install-Dependencies.ps1 -NonInteractive
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter()]
    [switch] $NonInteractive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requirements = @(
    @{
        Name             = 'Pester'
        MinimumVersion   = [Version] '5.0.0'
        MaximumVersion   = [Version] '5.999.999'
        MaximumExclusive = [Version] '6.0.0'
    }
    @{
        Name             = 'PSScriptAnalyzer'
        MinimumVersion   = [Version] '1.20.0'
        MaximumVersion   = [Version] '1.999.999'
        MaximumExclusive = [Version] '2.0.0'
    }
)

$script:InstallerCmdlet = $PSCmdlet
$script:NonInteractiveInstall = $NonInteractive.IsPresent

function Test-DependencyInstallationApproval {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Target,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Action
    )

    if ($WhatIfPreference) {
        $null = $script:InstallerCmdlet.ShouldProcess($Target, $Action)
        return $false
    }

    if ($script:NonInteractiveInstall) {
        return $true
    }

    return $script:InstallerCmdlet.ShouldContinue(
        "$Action`nTarget: $Target",
        'Neoxix SDK dependency installation'
    )
}

$missingRequirements = @(
    foreach ($requirement in $requirements) {
        $available = Get-Module -ListAvailable -Name $requirement.Name |
            Where-Object {
                $_.Version -ge $requirement.MinimumVersion -and
                $_.Version -lt $requirement.MaximumExclusive
            } |
            Sort-Object -Property Version -Descending |
            Select-Object -First 1
        if (-not $available) {
            $requirement
        }
    }
)

if ($missingRequirements.Count -gt 0) {
    $nuGetProvider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue |
        Where-Object Version -ge ([Version] '2.8.5.201') |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1
    if (-not $nuGetProvider) {
        $nuGetAction = 'Install NuGet package provider 2.8.5.201 or later for CurrentUser'
        if (-not (Test-DependencyInstallationApproval -Target 'NuGet' -Action $nuGetAction)) {
            Write-Warning 'Dependency installation stopped because NuGet installation was not approved.'
            return
        }

        Install-PackageProvider `
            -Name NuGet `
            -MinimumVersion '2.8.5.201' `
            -Scope CurrentUser `
            -Force `
            -Confirm:$false |
            Out-Null
    }
}

foreach ($requirement in $requirements) {
    $available = Get-Module -ListAvailable -Name $requirement.Name |
        Where-Object {
            $_.Version -ge $requirement.MinimumVersion -and
            $_.Version -lt $requirement.MaximumExclusive
        } |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1

    if ($available) {
        Write-Output ('{0} {1} is available.' -f $available.Name, $available.Version)
        continue
    }

    $installParameters = @{
        Name           = $requirement.Name
        MinimumVersion = $requirement.MinimumVersion
        MaximumVersion = $requirement.MaximumVersion
        Repository     = 'PSGallery'
        Scope          = 'CurrentUser'
        Force          = $true
        ErrorAction    = 'Stop'
    }

    $legacyPester = Get-Module -ListAvailable -Name Pester |
        Where-Object Version -lt ([Version] '5.0.0') |
        Select-Object -First 1
    if (
        $requirement.Name -eq 'Pester' -and
        $PSVersionTable.PSEdition -eq 'Desktop' -and
        $legacyPester
    ) {
        # Windows PowerShell 5.1 ships Microsoft-signed Pester 3.4. The legacy
        # PowerShellGet client rejects the gallery-signed 5.x package as a
        # publisher mismatch. Limit this compatibility exception to that case.
        $installParameters.SkipPublisherCheck = $true
    }

    $moduleAction = 'Install compatible module for CurrentUser from PSGallery'
    if (-not (
            Test-DependencyInstallationApproval `
                -Target $requirement.Name `
                -Action $moduleAction
        )) {
        Write-Warning ('Installation of {0} was not approved.' -f $requirement.Name)
        continue
    }

    Install-Module @installParameters -Confirm:$false
    Write-Output ('Installed {0}.' -f $requirement.Name)
}

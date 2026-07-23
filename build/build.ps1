<#
.SYNOPSIS
    Runs Neoxix SDK build and validation tasks.
.PARAMETER Task
    One of Clean, Analyze, Test, Build or Validate.
.EXAMPLE
    .\build\build.ps1 -Task Validate
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Clean', 'Analyze', 'Test', 'Build', 'Validate')]
    [string] $Task
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
$modulePath = Join-Path -Path $repositoryRoot -ChildPath 'src\Neoxix.SDK'
$manifestPath = Join-Path -Path $modulePath -ChildPath 'Neoxix.SDK.psd1'
$settingsPath = Join-Path -Path $repositoryRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'
$testsPath = Join-Path -Path $repositoryRoot -ChildPath 'tests'
$outputRoot = Join-Path -Path $repositoryRoot -ChildPath 'out'
$moduleOutput = Join-Path -Path $outputRoot -ChildPath 'Neoxix.SDK'

function Invoke-Clean {
    if (Test-Path -LiteralPath $outputRoot) {
        Remove-Item -LiteralPath $outputRoot -Recurse -Force
    }
}

function Invoke-ManifestValidation {
    $null = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
}

function Invoke-Analysis {
    if (-not (Get-Command -Name Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue)) {
        throw 'PSScriptAnalyzer is required. Run tools/Install-Dependencies.ps1 first.'
    }

    $findings = Invoke-ScriptAnalyzer -Path $modulePath -Recurse -Settings $settingsPath
    $findings | Format-Table -AutoSize
    if ($findings | Where-Object Severity -eq 'Error') {
        throw 'PSScriptAnalyzer reported error-level findings.'
    }
}

function Invoke-Test {
    $pester = Get-Module -ListAvailable -Name Pester |
        Where-Object {
            $_.Version.Major -eq 5 -and
            $_.Version -ge ([Version] '5.0.0')
        } |
        Sort-Object Version -Descending |
        Select-Object -First 1
    if (-not $pester) {
        throw 'Pester 5 is required. Run tools/Install-Dependencies.ps1 first.'
    }

    Import-Module -Name $pester.Path -Force
    $configuration = New-PesterConfiguration
    $configuration.Run.Path = $testsPath
    $configuration.Run.Exit = $false
    $configuration.Run.PassThru = $true
    $configuration.Output.Verbosity = 'Detailed'
    $configuration.TestResult.Enabled = $false
    $result = Invoke-Pester -Configuration $configuration
    if (-not $result) {
        throw 'Pester did not return a test result.'
    }
    if ($result.FailedCount -gt 0) {
        throw ('Pester reported {0} failed test(s).' -f $result.FailedCount)
    }
}

function Invoke-Build {
    Invoke-ManifestValidation
    $null = New-Item -Path $moduleOutput -ItemType Directory -Force
    Copy-Item -Path (Join-Path -Path $modulePath -ChildPath '*') -Destination $moduleOutput -Recurse -Force
}

switch ($Task) {
    'Clean' {
        Invoke-Clean
    }
    'Analyze' {
        Invoke-Analysis
    }
    'Test' {
        Invoke-Test
    }
    'Build' {
        Invoke-Clean
        Invoke-Build
    }
    'Validate' {
        Invoke-Clean
        Invoke-ManifestValidation
        Invoke-Analysis
        Invoke-Test
        Invoke-Build
    }
}

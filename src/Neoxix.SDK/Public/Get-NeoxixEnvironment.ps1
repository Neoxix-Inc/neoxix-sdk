function Get-NeoxixEnvironment {
    <#
    .SYNOPSIS
        Returns structured information about the current Neoxix SDK environment.
    .DESCRIPTION
        Detects the host platform, PowerShell runtime, CI provider and selected
        local development tools without modifying the machine or using a network.
    .EXAMPLE
        Get-NeoxixEnvironment
    .EXAMPLE
        Get-NeoxixEnvironment | Select-Object Platform, PowerShellVersion, IsCI
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $platformInfo = Get-NeoxixPlatformInfo
    $ciInfo = Get-NeoxixCIInfo
    $gitInfo = Get-NeoxixToolInfo -Name git
    $githubCliInfo = Get-NeoxixToolInfo -Name gh
    $visualStudioCodeInfo = Get-NeoxixToolInfo -Name code
    $dockerInfo = Get-NeoxixToolInfo -Name docker
    $pesterInfo = Get-NeoxixInstalledModuleInfo -Name Pester
    $scriptAnalyzerInfo = Get-NeoxixInstalledModuleInfo -Name PSScriptAnalyzer

    $powerShellVersion = [version] $PSVersionTable.PSVersion
    $powerShellEdition = [string] $PSVersionTable.PSEdition
    $supportedRuntime = (
        $powerShellEdition -eq 'Desktop' -and
        $powerShellVersion -ge ([version] '5.1')
    ) -or (
        $powerShellEdition -eq 'Core' -and
        $powerShellVersion -ge ([version] '7.0')
    )
    $supportedPlatform = $platformInfo.Platform -in @('Windows', 'Linux', 'macOS')

    $isInteractive = Test-NeoxixInteractiveSession -IsCI $ciInfo.IsCI

    $wslAvailable = $false
    if ($platformInfo.Platform -eq 'Windows') {
        $wslAvailable = $null -ne (
            Get-Command `
                -Name 'wsl.exe' `
                -CommandType Application `
                -ErrorAction SilentlyContinue
        )
    }

    return [PSCustomObject] @{
        OperatingSystem             = $platformInfo.OperatingSystem
        OperatingSystemVersion      = $platformInfo.OperatingSystemVersion
        Platform                    = $platformInfo.Platform
        ComputerName                = [Environment]::MachineName
        CurrentUser                 = $platformInfo.CurrentUser
        IsAdministrator             = [bool] $platformInfo.IsAdministrator
        IsInteractive               = [bool] $isInteractive
        Culture                    = [Globalization.CultureInfo]::CurrentCulture.Name
        TimeZone                   = [TimeZoneInfo]::Local.Id
        PowerShellEdition          = $powerShellEdition
        PowerShellVersion          = $powerShellVersion
        ProcessArchitecture        = $platformInfo.ProcessArchitecture
        OperatingSystemArchitecture = $platformInfo.OperatingSystemArchitecture
        GitAvailable               = [bool] $gitInfo.Available
        GitVersion                 = $gitInfo.Version
        GitHubCliAvailable         = [bool] $githubCliInfo.Available
        GitHubCliVersion           = $githubCliInfo.Version
        VisualStudioCodeAvailable  = [bool] $visualStudioCodeInfo.Available
        VisualStudioCodeVersion    = $visualStudioCodeInfo.Version
        DockerAvailable            = [bool] $dockerInfo.Available
        DockerVersion              = $dockerInfo.Version
        WslAvailable               = [bool] $wslAvailable
        PesterAvailable            = [bool] $pesterInfo.Available
        PesterVersion              = $pesterInfo.Version
        PSScriptAnalyzerAvailable  = [bool] $scriptAnalyzerInfo.Available
        PSScriptAnalyzerVersion    = $scriptAnalyzerInfo.Version
        IsCI                       = [bool] $ciInfo.IsCI
        CIProvider                 = $ciInfo.CIProvider
        SdkSupported               = [bool] ($supportedRuntime -and $supportedPlatform)
        DetectionTimestamp         = [datetime]::Now
    }
}

function Get-NeoxixSdkInfo {
    <#
    .SYNOPSIS
        Returns metadata about the loaded Neoxix SDK module.
    .DESCRIPTION
        Returns structured module, runtime, operating system, path and timestamp data.
    .EXAMPLE
        Get-NeoxixSdkInfo
    #>
    [CmdletBinding()]
    param()

    $module = $MyInvocation.MyCommand.Module
    $operatingSystem = [Environment]::OSVersion.VersionString
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $operatingSystem = $PSVersionTable.OS
    }

    [PSCustomObject] @{
        ModuleName        = $module.Name
        ModuleVersion     = $module.Version.ToString()
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        OperatingSystem   = $operatingSystem
        ModulePath        = $module.Path
        Timestamp         = [DateTimeOffset]::Now
    }
}

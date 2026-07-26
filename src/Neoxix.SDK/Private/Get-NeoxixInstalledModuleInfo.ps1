function Get-NeoxixInstalledModuleInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Pester', 'PSScriptAnalyzer')]
        [string] $Name
    )

    try {
        $modules = Get-Module `
            -ListAvailable `
            -Name $Name `
            -ErrorAction Stop
    }
    catch {
        Write-Debug -Message ('Unable to discover {0}: {1}' -f $Name, $_.Exception.Message)
        return [PSCustomObject] @{
            Available = $false
            Version   = $null
        }
    }
    if ($Name -eq 'Pester') {
        $modules = $modules | Where-Object {
            $_.Version -ge ([version] '5.0.0') -and
            $_.Version -lt ([version] '6.0.0')
        }
    }
    else {
        $modules = $modules | Where-Object {
            $_.Version -ge ([version] '1.20.0') -and
            $_.Version -lt ([version] '2.0.0')
        }
    }

    $module = $modules |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1

    return [PSCustomObject] @{
        Available = [bool] ($null -ne $module)
        Version   = if ($module) { [version] $module.Version } else { $null }
    }
}

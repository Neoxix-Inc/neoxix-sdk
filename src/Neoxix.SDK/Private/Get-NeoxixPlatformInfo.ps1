function Get-NeoxixPlatformInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $platform = 'Unknown'
    $operatingSystem = [Environment]::OSVersion.VersionString
    $operatingSystemVersion = [Environment]::OSVersion.Version
    $architectureInfo = Resolve-NeoxixArchitecture `
        -Is64BitProcess ([Environment]::Is64BitProcess) `
        -Is64BitOperatingSystem ([Environment]::Is64BitOperatingSystem)
    $processArchitecture = $architectureInfo.ProcessArchitecture
    $operatingSystemArchitecture = $architectureInfo.OperatingSystemArchitecture

    try {
        $runtimeInformation = [System.Runtime.InteropServices.RuntimeInformation]
        $runtimePlatform = 'Unknown'
        if ($runtimeInformation::IsOSPlatform(
                [System.Runtime.InteropServices.OSPlatform]::Windows
            )) {
            $runtimePlatform = 'Windows'
        }
        elseif ($runtimeInformation::IsOSPlatform(
                [System.Runtime.InteropServices.OSPlatform]::Linux
            )) {
            $runtimePlatform = 'Linux'
        }
        elseif ($runtimeInformation::IsOSPlatform(
                [System.Runtime.InteropServices.OSPlatform]::OSX
            )) {
            $runtimePlatform = 'macOS'
        }

        $platform = Resolve-NeoxixPlatform `
            -RuntimePlatform $runtimePlatform `
            -EnvironmentPlatform ([Environment]::OSVersion.Platform.ToString())
        $operatingSystem = $runtimeInformation::OSDescription
        $architectureInfo = Resolve-NeoxixArchitecture `
            -RuntimeProcessArchitecture $runtimeInformation::ProcessArchitecture.ToString() `
            -RuntimeOperatingSystemArchitecture $runtimeInformation::OSArchitecture.ToString() `
            -Is64BitProcess ([Environment]::Is64BitProcess) `
            -Is64BitOperatingSystem ([Environment]::Is64BitOperatingSystem)
        $processArchitecture = $architectureInfo.ProcessArchitecture
        $operatingSystemArchitecture = $architectureInfo.OperatingSystemArchitecture
    }
    catch {
        $platform = Resolve-NeoxixPlatform `
            -RuntimePlatform 'Unavailable' `
            -EnvironmentPlatform ([Environment]::OSVersion.Platform.ToString())
    }

    if ($platform -eq 'Linux' -and (Test-Path -LiteralPath '/etc/os-release' -PathType Leaf)) {
        try {
            $prettyNameLine = Get-Content -LiteralPath '/etc/os-release' -ErrorAction Stop |
                Where-Object { $_ -match '^PRETTY_NAME=' } |
                Select-Object -First 1
            if ($prettyNameLine) {
                $operatingSystem = ConvertFrom-NeoxixOsReleaseValue `
                    -Value $prettyNameLine.Substring(12)
            }
        }
        catch {
            Write-Debug -Message ('Unable to read Linux OS description: {0}' -f $_.Exception.Message)
        }
    }

    $currentUser = [Environment]::UserName
    $isAdministrator = $false
    if ($platform -eq 'Windows') {
        $identity = $null
        try {
            $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object Security.Principal.WindowsPrincipal($identity)
            $administratorRole = [Security.Principal.WindowsBuiltInRole]::Administrator
            $isAdministrator = $principal.IsInRole($administratorRole)
            $currentUser = $identity.Name
        }
        catch {
            Write-Debug -Message ('Unable to determine Windows elevation: {0}' -f $_.Exception.Message)
        }
        finally {
            if ($identity) {
                $identity.Dispose()
            }
        }
    }
    elseif ($platform -in @('Linux', 'macOS')) {
        $isAdministrator = $currentUser -eq 'root'
    }

    return [PSCustomObject] @{
        OperatingSystem             = $operatingSystem
        OperatingSystemVersion      = $operatingSystemVersion
        Platform                    = $platform
        CurrentUser                 = $currentUser
        IsAdministrator             = [bool] $isAdministrator
        ProcessArchitecture         = $processArchitecture
        OperatingSystemArchitecture = $operatingSystemArchitecture
    }
}

function Resolve-NeoxixArchitecture {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [AllowNull()]
        [string] $RuntimeProcessArchitecture,

        [Parameter()]
        [AllowNull()]
        [string] $RuntimeOperatingSystemArchitecture,

        [Parameter(Mandatory)]
        [bool] $Is64BitProcess,

        [Parameter(Mandatory)]
        [bool] $Is64BitOperatingSystem
    )

    if ($RuntimeProcessArchitecture -and $RuntimeOperatingSystemArchitecture) {
        return [PSCustomObject] @{
            ProcessArchitecture         = $RuntimeProcessArchitecture
            OperatingSystemArchitecture = $RuntimeOperatingSystemArchitecture
        }
    }

    return [PSCustomObject] @{
        ProcessArchitecture = if ($Is64BitProcess) { 'X64' } else { 'X86' }
        OperatingSystemArchitecture = if ($Is64BitOperatingSystem) {
            'X64'
        }
        else {
            'X86'
        }
    }
}

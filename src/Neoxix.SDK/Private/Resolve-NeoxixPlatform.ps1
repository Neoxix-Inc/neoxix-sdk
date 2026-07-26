function Resolve-NeoxixPlatform {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Windows', 'Linux', 'macOS', 'Unknown', 'Unavailable')]
        [string] $RuntimePlatform,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $EnvironmentPlatform
    )

    if ($RuntimePlatform -in @('Windows', 'Linux', 'macOS')) {
        return $RuntimePlatform
    }
    if ($EnvironmentPlatform -eq [PlatformID]::Win32NT.ToString()) {
        return 'Windows'
    }

    # PlatformID.Unix is shared by Linux and macOS. Without RuntimeInformation,
    # selecting either one would be an unreliable deduction.
    return 'Unknown'
}

function Test-NeoxixInteractiveSession {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [bool] $IsCI,

        [Parameter()]
        [AllowNull()]
        [Nullable[bool]] $UserInteractive,

        [Parameter()]
        [AllowNull()]
        [Nullable[bool]] $InputRedirected,

        [Parameter()]
        [AllowNull()]
        [Nullable[bool]] $RemoteSession,

        [Parameter()]
        [AllowNull()]
        [string] $HostName
    )

    if ($null -eq $UserInteractive) {
        $UserInteractive = [Environment]::UserInteractive
    }
    if ($null -eq $InputRedirected) {
        try {
            $InputRedirected = [Console]::IsInputRedirected
        }
        catch {
            Write-Debug -Message (
                'Unable to determine console redirection: {0}' -f $_.Exception.Message
            )
            $InputRedirected = $true
        }
    }
    if ($null -eq $RemoteSession) {
        $RemoteSession = $false
        try {
            $defaultRunspace = [runspace]::DefaultRunspace
            if ($defaultRunspace -and $defaultRunspace.ConnectionInfo) {
                $RemoteSession = $true
            }
        }
        catch {
            Write-Debug -Message (
                'Unable to determine remoting state: {0}' -f $_.Exception.Message
            )
            $RemoteSession = $true
        }
    }
    if (-not $PSBoundParameters.ContainsKey('HostName')) {
        $HostName = $Host.Name
    }

    return [bool] (
        $UserInteractive -and
        -not $InputRedirected -and
        -not $RemoteSession -and
        $HostName -ne 'ServerRemoteHost' -and
        -not $IsCI
    )
}

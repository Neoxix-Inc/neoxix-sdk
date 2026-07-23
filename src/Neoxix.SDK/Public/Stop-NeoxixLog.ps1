function Stop-NeoxixLog {
    <#
    .SYNOPSIS
        Resets logging for the current Neoxix SDK module session.
    .DESCRIPTION
        Disables file and debug logging and returns the previous configuration.
    .EXAMPLE
        Stop-NeoxixLog
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param()

    if (-not $PSCmdlet.ShouldProcess(
            'current Neoxix SDK module session',
            'Reset Neoxix SDK logging'
        )) {
        return
    }

    $previousState = [PSCustomObject] @{
        FilePath     = $script:NeoxixLogState.FilePath
        DebugEnabled = $script:NeoxixLogState.DebugEnabled
    }

    $script:NeoxixLogState.FilePath = $null
    $script:NeoxixLogState.DebugEnabled = $false
    return $previousState
}

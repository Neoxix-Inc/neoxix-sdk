function Write-NeoxixDebug {
    <#
    .SYNOPSIS
        Writes a debug entry when Neoxix debug logging is enabled.
    .PARAMETER Message
        The non-empty message to log.
    .EXAMPLE
        Write-NeoxixDebug -Message 'Resolved configuration.'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    process {
        if (-not $script:NeoxixLogState.DebugEnabled) {
            return
        }

        $entry = Write-NeoxixLog -Level DEBUG -Message $Message
        return $entry
    }
}

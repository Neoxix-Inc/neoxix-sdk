function Write-NeoxixInfo {
    <#
    .SYNOPSIS
        Writes a structured informational log entry.
    .PARAMETER Message
        The non-empty message to log.
    .EXAMPLE
        Write-NeoxixInfo -Message 'Validation started.'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    process {
        Write-NeoxixLog -Level INFO -Message $Message
    }
}

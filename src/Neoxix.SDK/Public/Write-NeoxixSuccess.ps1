function Write-NeoxixSuccess {
    <#
    .SYNOPSIS
        Writes a structured success log entry.
    .PARAMETER Message
        The non-empty message to log.
    .EXAMPLE
        Write-NeoxixSuccess -Message 'Validation passed.'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    process {
        Write-NeoxixLog -Level SUCCESS -Message $Message
    }
}

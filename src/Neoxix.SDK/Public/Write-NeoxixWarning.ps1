function Write-NeoxixWarning {
    <#
    .SYNOPSIS
        Writes a warning and returns its structured log entry.
    .PARAMETER Message
        The non-empty message to log.
    .EXAMPLE
        Write-NeoxixWarning -Message 'Configuration is incomplete.'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    process {
        $entry = Write-NeoxixLog -Level WARNING -Message $Message
        Write-Warning -Message ('[WARNING] {0}' -f $Message)
        return $entry
    }
}

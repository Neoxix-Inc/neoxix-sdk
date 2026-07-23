function Write-NeoxixError {
    <#
    .SYNOPSIS
        Writes a non-terminating error and returns its structured log entry.
    .PARAMETER Message
        The non-empty message to log.
    .EXAMPLE
        Write-NeoxixError -Message 'A recoverable operation failed.'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    process {
        $entry = Write-NeoxixLog -Level ERROR -Message $Message
        Write-Error -Message ('[ERROR] {0}' -f $Message)
        return $entry
    }
}

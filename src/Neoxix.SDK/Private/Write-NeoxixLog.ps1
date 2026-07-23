function Write-NeoxixLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR', 'DEBUG')]
        [string] $Level,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    $protectedMessage = Protect-NeoxixLogMessage -Message $Message

    $entry = [PSCustomObject] @{
        Timestamp = [DateTimeOffset]::Now
        Level     = $Level
        Message   = $protectedMessage
    }

    if ($script:NeoxixLogState.FilePath) {
        $line = '{0} [{1}] {2}' -f $entry.Timestamp.ToString('o'), $Level, $protectedMessage
        try {
            [System.IO.File]::AppendAllText(
                $script:NeoxixLogState.FilePath,
                $line + [Environment]::NewLine,
                (New-Object System.Text.UTF8Encoding($false))
            )
        }
        catch {
            throw "Unable to write to log file '$($script:NeoxixLogState.FilePath)': $($_.Exception.Message)"
        }
    }

    return $entry
}

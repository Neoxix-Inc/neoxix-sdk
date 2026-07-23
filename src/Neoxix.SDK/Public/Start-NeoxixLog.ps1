function Start-NeoxixLog {
    <#
    .SYNOPSIS
        Configures logging for the current Neoxix SDK module session.
    .DESCRIPTION
        Enables optional UTF-8 file logging and optional debug output.
    .PARAMETER Path
        Optional log file path. The parent directory must already exist.
    .PARAMETER EnableDebug
        Enables Write-NeoxixDebug output for this module session.
    .EXAMPLE
        Start-NeoxixLog -Path '.\neoxix.log' -EnableDebug
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter()]
        [switch] $EnableDebug
    )

    $target = 'current Neoxix SDK module session'
    if ($PSBoundParameters.ContainsKey('Path')) {
        $target = $Path
    }
    if (-not $PSCmdlet.ShouldProcess($target, 'Configure Neoxix SDK logging')) {
        return
    }

    $resolvedPath = $null
    if ($PSBoundParameters.ContainsKey('Path')) {
        $parentPath = Split-Path -Path $Path -Parent
        if ([string]::IsNullOrWhiteSpace($parentPath)) {
            $parentPath = (Get-Location).ProviderPath
        }

        if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
            throw "The log directory does not exist: $parentPath"
        }

        $resolvedParent = (Resolve-Path -LiteralPath $parentPath -ErrorAction Stop).ProviderPath
        $resolvedPath = Join-Path -Path $resolvedParent -ChildPath (Split-Path -Path $Path -Leaf)
        try {
            [System.IO.File]::AppendAllText(
                $resolvedPath,
                [string]::Empty,
                (New-Object System.Text.UTF8Encoding($false))
            )
        }
        catch {
            throw "Unable to initialize log file '$resolvedPath': $($_.Exception.Message)"
        }
    }

    $script:NeoxixLogState.FilePath = $resolvedPath
    $script:NeoxixLogState.DebugEnabled = $EnableDebug.IsPresent

    [PSCustomObject] @{
        FilePath     = $resolvedPath
        DebugEnabled = $EnableDebug.IsPresent
    }
}

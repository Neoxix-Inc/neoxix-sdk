function Get-NeoxixToolInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('git', 'gh', 'code', 'docker')]
        [string] $Name
    )

    $command = Get-Command `
        -Name $Name `
        -CommandType Application `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $command) {
        return [PSCustomObject] @{
            Available = $false
            Version   = $null
        }
    }

    $version = $null
    try {
        $versionOutput = Invoke-NeoxixVersionCommand `
            -FilePath $command.Path `
            -Argument '--version' `
            -ToolName $Name
        $version = ConvertTo-NeoxixVersion `
            -InputText $versionOutput `
            -ToolName $Name
    }
    catch {
        Write-Debug -Message ('Unable to read {0} version: {1}' -f $Name, $_.Exception.Message)
    }

    return [PSCustomObject] @{
        Available = $true
        Version   = $version
    }
}

function Invoke-NeoxixVersionCommand {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter(Mandatory)]
        [ValidateSet('--version')]
        [string] $Argument,

        [Parameter()]
        [ValidateRange(100, 30000)]
        [int] $TimeoutMilliseconds = 5000,

        [Parameter(Mandatory)]
        [ValidateSet('git', 'gh', 'code', 'docker')]
        [string] $ToolName
    )

    $environmentVariables = @{}
    $removeEnvironmentVariables = @()
    if ($ToolName -eq 'gh') {
        $environmentVariables.GH_CONFIG_DIR = Join-Path `
            -Path ([IO.Path]::GetTempPath()) `
            -ChildPath ('neoxix-gh-{0}' -f [guid]::NewGuid().ToString('N'))
        $removeEnvironmentVariables = @(
            'GH_TOKEN'
            'GITHUB_TOKEN'
            'GH_ENTERPRISE_TOKEN'
            'GITHUB_ENTERPRISE_TOKEN'
        )
    }

    return Invoke-NeoxixChildProcess `
        -FilePath $FilePath `
        -Argument $Argument `
        -TimeoutMilliseconds $TimeoutMilliseconds `
        -EnvironmentVariables $environmentVariables `
        -RemoveEnvironmentVariables $removeEnvironmentVariables
}

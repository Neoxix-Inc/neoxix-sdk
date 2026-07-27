function Get-NeoxixCIInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $provider = 'None'
    if ($env:GITHUB_ACTIONS -eq 'true') {
        $provider = 'GitHubActions'
    }
    elseif ($env:TF_BUILD -eq 'True') {
        $provider = 'AzureDevOps'
    }
    elseif ($env:GITLAB_CI -eq 'true') {
        $provider = 'GitLabCI'
    }
    elseif (
        -not [string]::IsNullOrWhiteSpace($env:JENKINS_URL) -or
        -not [string]::IsNullOrWhiteSpace($env:JENKINS_HOME)
    ) {
        $provider = 'Jenkins'
    }
    elseif ($env:CI -match '^(?i:true|1|yes)$') {
        $provider = 'Generic'
    }

    return [PSCustomObject] @{
        IsCI       = [bool] ($provider -ne 'None')
        CIProvider = $provider
    }
}

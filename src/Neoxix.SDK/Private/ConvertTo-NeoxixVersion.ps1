function ConvertTo-NeoxixVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $InputText,

        [Parameter(Mandatory)]
        [ValidateSet('git', 'gh', 'code', 'docker')]
        [string] $ToolName
    )

    $patterns = @{
        git    = '\Agit version (?<Version>\d+\.\d+\.\d+)(?:\.[0-9A-Za-z.-]+)?\s*\z'
        gh     = '\Agh version (?<Version>\d+\.\d+\.\d+)(?:\s+\([^\r\n]+\))?(?:\r?\nhttps://github\.com/cli/cli/releases/tag/v\d+\.\d+\.\d+)?\s*\z'
        code   = '\A(?<Version>\d+\.\d+\.\d+)(?:\r?\n[0-9A-Za-z.-]+)?(?:\r?\n(?:x64|x86|arm64|armhf))?\s*\z'
        docker = '\ADocker version (?<Version>\d+\.\d+\.\d+)(?:[-+][0-9A-Za-z.-]+)?, build [0-9A-Za-z.-]+\s*\z'
    }
    $versionMatch = [regex]::Match(
        $InputText.Trim(),
        $patterns[$ToolName],
        [Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
    if (-not $versionMatch.Success) {
        return $null
    }

    $parsedVersion = $null
    if ([version]::TryParse($versionMatch.Groups['Version'].Value, [ref] $parsedVersion)) {
        return $parsedVersion
    }

    return $null
}

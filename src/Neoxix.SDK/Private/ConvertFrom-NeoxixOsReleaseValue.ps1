function ConvertFrom-NeoxixOsReleaseValue {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Value
    )

    $normalizedValue = $Value.Trim()
    if (
        $normalizedValue.Length -ge 2 -and
        $normalizedValue[0] -eq '"' -and
        $normalizedValue[$normalizedValue.Length - 1] -eq '"'
    ) {
        return $normalizedValue.Substring(1, $normalizedValue.Length - 2).
            Replace('\"', '"').
            Replace('\\', '\')
    }
    if (
        $normalizedValue.Length -ge 2 -and
        $normalizedValue[0] -eq "'" -and
        $normalizedValue[$normalizedValue.Length - 1] -eq "'"
    ) {
        return $normalizedValue.Substring(1, $normalizedValue.Length - 2)
    }

    return $normalizedValue
}

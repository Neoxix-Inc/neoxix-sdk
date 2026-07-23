Set-StrictMode -Version Latest

$script:NeoxixLogState = @{
    FilePath     = $null
    DebugEnabled = $false
}

$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

foreach ($path in @($privatePath, $publicPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Required module directory was not found: $path"
    }

    $scripts = Get-ChildItem -LiteralPath $path -Filter '*.ps1' -File |
        Sort-Object -Property Name

    foreach ($scriptFile in $scripts) {
        . $scriptFile.FullName
    }
}

$publicFunctions = Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File |
    Sort-Object -Property Name |
    ForEach-Object { $_.BaseName }

Export-ModuleMember -Function $publicFunctions

Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Path $PSScriptRoot -Parent
$script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src\Neoxix.SDK\Neoxix.SDK.psd1'

function Import-TestModule {
    Remove-Module -Name Neoxix.SDK -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop
}

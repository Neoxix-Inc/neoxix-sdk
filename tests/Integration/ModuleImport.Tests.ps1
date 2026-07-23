BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
}

Describe 'Module integration' {
    It 'imports from the manifest and exposes usable commands' {
        Import-TestModule
        Get-NeoxixSdkInfo | Should -Not -BeNullOrEmpty
        (Get-Command -Module Neoxix.SDK).Count | Should -Be 8
    }
}

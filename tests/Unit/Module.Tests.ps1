BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
    Import-TestModule
    $expectedFunctions = @(
        'Get-NeoxixSdkInfo'
        'Start-NeoxixLog'
        'Stop-NeoxixLog'
        'Write-NeoxixDebug'
        'Write-NeoxixError'
        'Write-NeoxixInfo'
        'Write-NeoxixSuccess'
        'Write-NeoxixWarning'
    )
}

Describe 'Neoxix.SDK module' {
    It 'has a valid manifest' {
        { Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop } | Should -Not -Throw
    }

    It 'imports successfully' {
        { Import-TestModule } | Should -Not -Throw
    }

    It 'exports exactly the intended functions' {
        $actual = @(Get-Command -Module Neoxix.SDK -CommandType Function).Name | Sort-Object
        $actual | Should -Be ($expectedFunctions | Sort-Object)
    }

    It 'matches the repository version' {
        $version = (Get-Content -LiteralPath (Join-Path $script:RepositoryRoot 'VERSION') -Raw).Trim()
        (Test-ModuleManifest -Path $script:ManifestPath).Version.ToString() | Should -Be $version
    }

    It 'provides help for every public function' {
        foreach ($functionName in $expectedFunctions) {
            $functionPath = Join-Path `
                -Path $script:RepositoryRoot `
                -ChildPath ('src\Neoxix.SDK\Public\{0}.ps1' -f $functionName)
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $functionPath,
                [ref] $tokens,
                [ref] $parseErrors
            )
            $parseErrors.Count | Should -Be 0
            $functionAst = $ast.Find(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
                },
                $false
            )
            $help = $functionAst.GetHelpContent()
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Examples.Count | Should -BeGreaterThan 0
        }
    }
}

Describe 'Get-NeoxixSdkInfo' {
    It 'returns all mandatory structured properties and the manifest version' {
        $result = Get-NeoxixSdkInfo
        $result.GetType().Name | Should -Be 'PSCustomObject'
        foreach ($property in @(
                'ModuleName',
                'ModuleVersion',
                'PowerShellVersion',
                'OperatingSystem',
                'ModulePath',
                'Timestamp'
            )) {
            $result.PSObject.Properties.Name | Should -Contain $property
        }
        $result.ModuleVersion | Should -Be '0.1.0'
        $result.ModuleName | Should -Be 'Neoxix.SDK'
        $result.PowerShellVersion | Should -Be $PSVersionTable.PSVersion.ToString()
        $result.OperatingSystem | Should -Not -BeNullOrEmpty
        $result.ModulePath | Should -Not -BeNullOrEmpty
        Test-Path -LiteralPath $result.ModulePath -PathType Leaf | Should -BeTrue
        $result.Timestamp | Should -BeOfType ([DateTimeOffset])
    }
}

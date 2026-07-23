BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
    $script:AnalyzerSettingsPath = Join-Path `
        -Path $script:RepositoryRoot `
        -ChildPath 'PSScriptAnalyzerSettings.psd1'
    $script:DependencyInstallerPath = Join-Path `
        -Path $script:RepositoryRoot `
        -ChildPath 'tools\Install-Dependencies.ps1'
}

Describe 'Static analysis configuration' {
    It 'retains recommended rules and enables additional safety rules' {
        $writeHostFindings = @(
            Invoke-ScriptAnalyzer `
                -ScriptDefinition 'Write-Host "presentation"' `
                -Settings $script:AnalyzerSettingsPath
        )
        $writeHostFindings.RuleName | Should -Contain 'PSAvoidUsingWriteHost'

        $stateChangeFindings = @(
            Invoke-ScriptAnalyzer `
                -ScriptDefinition 'function Remove-Demo { Remove-Item -Path "demo" }' `
                -Settings $script:AnalyzerSettingsPath
        )
        $stateChangeFindings.RuleName |
            Should -Contain 'PSUseShouldProcessForStateChangingFunctions'
    }
}

Describe 'Dependency bootstrap safeguards' {
    BeforeAll {
        $installerContent = Get-Content -LiteralPath $script:DependencyInstallerPath -Raw
    }

    It 'requires high-impact confirmation and preserves WhatIf' {
        $installerContent | Should -Match "ConfirmImpact\s*=\s*'High'"
        $installerContent | Should -Match '\$WhatIfPreference'
        $installerContent | Should -Match 'ShouldContinue'
    }

    It 'uses compatible major-version ranges without clobbering commands' {
        $installerContent | Should -Match "MaximumExclusive\s*=\s*\[Version\]\s*'6\.0\.0'"
        $installerContent | Should -Match "MaximumExclusive\s*=\s*\[Version\]\s*'2\.0\.0'"
        $installerContent | Should -Not -Match 'AllowClobber'
    }

    It 'limits the Pester publisher exception to legacy Windows PowerShell' {
        $installerContent |
            Should -Match '\$PSVersionTable\.PSEdition\s+-eq\s+''Desktop'''
        $installerContent | Should -Match '\$legacyPester'
        $installerContent | Should -Match 'SkipPublisherCheck'
    }
}

BeforeDiscovery {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
    Import-TestModule
}

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
    Import-TestModule
    $requiredProperties = @(
        'OperatingSystem'
        'OperatingSystemVersion'
        'Platform'
        'ComputerName'
        'CurrentUser'
        'IsAdministrator'
        'IsInteractive'
        'Culture'
        'TimeZone'
        'PowerShellEdition'
        'PowerShellVersion'
        'ProcessArchitecture'
        'OperatingSystemArchitecture'
        'GitAvailable'
        'GitVersion'
        'GitHubCliAvailable'
        'GitHubCliVersion'
        'VisualStudioCodeAvailable'
        'VisualStudioCodeVersion'
        'DockerAvailable'
        'DockerVersion'
        'WslAvailable'
        'PesterAvailable'
        'PesterVersion'
        'PSScriptAnalyzerAvailable'
        'PSScriptAnalyzerVersion'
        'IsCI'
        'CIProvider'
        'SdkSupported'
        'DetectionTimestamp'
    )
    $booleanProperties = @(
        'IsAdministrator'
        'IsInteractive'
        'GitAvailable'
        'GitHubCliAvailable'
        'VisualStudioCodeAvailable'
        'DockerAvailable'
        'WslAvailable'
        'PesterAvailable'
        'PSScriptAnalyzerAvailable'
        'IsCI'
        'SdkSupported'
    )
}

Describe 'Get-NeoxixEnvironment contract' {
    It 'is exported and returns exactly one PSCustomObject' {
        Get-Command -Name Get-NeoxixEnvironment -Module Neoxix.SDK |
            Should -Not -BeNullOrEmpty
        $result = @(Get-NeoxixEnvironment)
        $result.Count | Should -Be 1
        $result[0].GetType().Name | Should -Be 'PSCustomObject'
    }

    It 'contains the complete stable schema and correct property types' {
        $result = Get-NeoxixEnvironment
        $result.PSObject.Properties.Name | Should -Be $requiredProperties
        foreach ($property in $booleanProperties) {
            $result.$property | Should -BeOfType ([bool])
        }
        $result.DetectionTimestamp | Should -BeOfType ([datetime])
        $result.PowerShellVersion | Should -BeOfType ([version])
    }

    It 'reports the active runtime and a supported platform value' {
        $result = Get-NeoxixEnvironment
        $result.PowerShellVersion | Should -Be ([version] $PSVersionTable.PSVersion)
        $result.PowerShellEdition | Should -Be $PSVersionTable.PSEdition
        $result.ProcessArchitecture | Should -Not -BeNullOrEmpty
        $result.OperatingSystemArchitecture | Should -Not -BeNullOrEmpty
        $result.Platform | Should -BeIn @('Windows', 'Linux', 'macOS', 'Unknown')
        $expectedSupport = (
            $result.Platform -in @('Windows', 'Linux', 'macOS')
        ) -and (
            (
                $PSVersionTable.PSEdition -eq 'Desktop' -and
                $PSVersionTable.PSVersion -ge ([version] '5.1')
            ) -or (
                $PSVersionTable.PSEdition -eq 'Core' -and
                $PSVersionTable.PSVersion -ge ([version] '7.0')
            )
        )
        $result.SdkSupported | Should -Be $expectedSupport
    }

    It 'preserves the same schema across repeated calls' {
        $first = Get-NeoxixEnvironment
        $second = Get-NeoxixEnvironment
        $first.PSObject.Properties.Name | Should -Be $second.PSObject.Properties.Name
    }

    It 'does not create files and does not expose unrelated secret variables' {
        $secretVariableName = 'NEOXIX_TEST_' + 'SECRET'
        $secretValue = 'fixture-value-that-must-not-appear'
        [Environment]::SetEnvironmentVariable($secretVariableName, $secretValue, 'Process')
        try {
            $beforeRepositoryFiles = @(
                Get-ChildItem -LiteralPath $script:RepositoryRoot -Force -Recurse -File |
                    Select-Object -ExpandProperty FullName
            )
            $beforeGhDirectories = @(
                Get-ChildItem `
                    -LiteralPath ([IO.Path]::GetTempPath()) `
                    -Directory `
                    -Filter 'neoxix-gh-*' `
                    -ErrorAction SilentlyContinue |
                    Select-Object -ExpandProperty FullName
            )
            $result = Get-NeoxixEnvironment
            $afterRepositoryFiles = @(
                Get-ChildItem -LiteralPath $script:RepositoryRoot -Force -Recurse -File |
                    Select-Object -ExpandProperty FullName
            )
            $afterGhDirectories = @(
                Get-ChildItem `
                    -LiteralPath ([IO.Path]::GetTempPath()) `
                    -Directory `
                    -Filter 'neoxix-gh-*' `
                    -ErrorAction SilentlyContinue |
                    Select-Object -ExpandProperty FullName
            )
            $afterRepositoryFiles | Should -Be $beforeRepositoryFiles
            $afterGhDirectories | Should -Be $beforeGhDirectories
            ($result | ConvertTo-Json -Depth 4) | Should -Not -Match $secretValue
        }
        finally {
            [Environment]::SetEnvironmentVariable($secretVariableName, $null, 'Process')
        }
    }
}

Describe 'Optional tool detection' {
    InModuleScope Neoxix.SDK {
        It 'returns false and null when Git is unavailable' {
            Mock Get-Command { return $null } -ParameterFilter { $Name -eq 'git' }
            $result = Get-NeoxixToolInfo -Name git
            $result.Available | Should -BeFalse
            $result.Version | Should -BeNullOrEmpty
        }

        It 'returns true and parses an available Git version' {
            Mock Get-Command {
                [PSCustomObject] @{ Path = 'git-fixture' }
            } -ParameterFilter { $Name -eq 'git' }
            Mock Invoke-NeoxixVersionCommand { 'git version 2.45.1.windows.1' }
            $result = Get-NeoxixToolInfo -Name git
            $result.Available | Should -BeTrue
            $result.Version | Should -Be ([version] '2.45.1')
        }

        It 'does not throw or leak output when version text is malformed' {
            Mock Get-Command {
                [PSCustomObject] @{ Path = 'git-fixture' }
            } -ParameterFilter { $Name -eq 'git' }
            Mock Invoke-NeoxixVersionCommand {
                'fatal: protocol 2.0 is unsupported; server version 3.4.5'
            }
            { Get-NeoxixToolInfo -Name git } | Should -Not -Throw
            $result = @(Get-NeoxixToolInfo -Name git)
            $result.Count | Should -Be 1
            $result[0].Available | Should -BeTrue
            $result[0].Version | Should -BeNullOrEmpty
        }

        It 'does not expose optional tool failures as pipeline output' {
            Mock Get-Command {
                [PSCustomObject] @{ Path = 'tool-fixture' }
            }
            Mock Invoke-NeoxixVersionCommand { throw 'fixture stderr value' }
            foreach ($toolName in @('gh', 'code', 'docker')) {
                $result = @(Get-NeoxixToolInfo -Name $toolName)
                $result.Count | Should -Be 1
                $result[0].Available | Should -BeTrue
                $result[0].Version | Should -BeNullOrEmpty
                ($result | Out-String) | Should -Not -Match 'fixture stderr value'
            }
        }

        It 'does not throw when gh, code, or docker is unavailable' -TestCases @(
            @{ ToolName = 'gh' }
            @{ ToolName = 'code' }
            @{ ToolName = 'docker' }
        ) {
            param($ToolName)
            Mock Get-Command { return $null } -ParameterFilter { $Name -eq $ToolName }
            { Get-NeoxixToolInfo -Name $ToolName } | Should -Not -Throw
            $result = Get-NeoxixToolInfo -Name $ToolName
            $result.Available | Should -BeFalse
            $result.Version | Should -BeNullOrEmpty
        }

        It 'selects the highest installed Pester version' {
            Mock Get-Module {
                @(
                    [PSCustomObject] @{ Version = [version] '5.4.0' }
                    [PSCustomObject] @{ Version = [version] '5.7.1' }
                    [PSCustomObject] @{ Version = [version] '5.5.0' }
                    [PSCustomObject] @{ Version = [version] '6.0.0' }
                )
            } -ParameterFilter { $Name -eq 'Pester' }
            $result = Get-NeoxixInstalledModuleInfo -Name Pester
            $result.Available | Should -BeTrue
            $result.Version | Should -Be ([version] '5.7.1')
        }

        It 'selects the highest installed PSScriptAnalyzer version' {
            Mock Get-Module {
                @(
                    [PSCustomObject] @{ Version = [version] '1.20.0' }
                    [PSCustomObject] @{ Version = [version] '1.24.0' }
                    [PSCustomObject] @{ Version = [version] '2.0.0' }
                )
            } -ParameterFilter { $Name -eq 'PSScriptAnalyzer' }
            $result = Get-NeoxixInstalledModuleInfo -Name PSScriptAnalyzer
            $result.Available | Should -BeTrue
            $result.Version | Should -Be ([version] '1.24.0')
        }

        It 'returns unavailable module information without leaking discovery errors' {
            Mock Get-Module { throw 'private module path denied' }
            $pipelineOutput = @(
                Get-NeoxixInstalledModuleInfo -Name Pester 2>&1
            )
            $pipelineOutput.Count | Should -Be 1
            $pipelineOutput[0].Available | Should -BeFalse
            $pipelineOutput[0].Version | Should -BeNullOrEmpty
            ($pipelineOutput | Out-String) | Should -Not -Match 'private module path denied'
        }
    }
}

Describe 'CI environment detection' {
    BeforeEach {
        $script:CiVariableNames = @(
            'GITHUB_ACTIONS'
            'TF_BUILD'
            'GITLAB_CI'
            'JENKINS_URL'
            'JENKINS_HOME'
            'CI'
        )
        $script:OriginalCiValues = @{}
        foreach ($variableName in $script:CiVariableNames) {
            $script:OriginalCiValues[$variableName] = [Environment]::GetEnvironmentVariable(
                $variableName,
                'Process'
            )
            [Environment]::SetEnvironmentVariable($variableName, $null, 'Process')
        }
    }

    AfterEach {
        foreach ($variableName in $script:CiVariableNames) {
            [Environment]::SetEnvironmentVariable(
                $variableName,
                $script:OriginalCiValues[$variableName],
                'Process'
            )
        }
    }

    It 'detects GitHub Actions' {
        $env:GITHUB_ACTIONS = 'true'
        InModuleScope Neoxix.SDK {
            $result = Get-NeoxixCIInfo
            $result.IsCI | Should -BeTrue
            $result.CIProvider | Should -Be 'GitHubActions'
        }
    }

    It 'detects Azure DevOps' {
        $env:TF_BUILD = 'True'
        InModuleScope Neoxix.SDK {
            (Get-NeoxixCIInfo).CIProvider | Should -Be 'AzureDevOps'
        }
    }

    It 'detects GitLab CI' {
        $env:GITLAB_CI = 'true'
        InModuleScope Neoxix.SDK {
            (Get-NeoxixCIInfo).CIProvider | Should -Be 'GitLabCI'
        }
    }

    It 'detects Jenkins' {
        $env:JENKINS_URL = 'https://jenkins.invalid/'
        InModuleScope Neoxix.SDK {
            (Get-NeoxixCIInfo).CIProvider | Should -Be 'Jenkins'
        }
    }

    It 'detects a generic CI environment' {
        $env:CI = 'true'
        InModuleScope Neoxix.SDK {
            (Get-NeoxixCIInfo).CIProvider | Should -Be 'Generic'
        }
    }

    It 'returns None when no CI marker exists' {
        InModuleScope Neoxix.SDK {
            $result = Get-NeoxixCIInfo
            $result.IsCI | Should -BeFalse
            $result.CIProvider | Should -Be 'None'
        }
    }
}

Describe 'Read-only behavior' {
    InModuleScope Neoxix.SDK {
        It 'does not invoke network or installation commands' {
            Mock Get-NeoxixPlatformInfo {
                [PSCustomObject] @{
                    OperatingSystem             = 'Fixture OS'
                    OperatingSystemVersion      = [version] '1.0'
                    Platform                    = 'Unknown'
                    CurrentUser                 = 'fixture'
                    IsAdministrator             = $false
                    ProcessArchitecture         = 'X64'
                    OperatingSystemArchitecture = 'X64'
                }
            }
            Mock Get-NeoxixCIInfo {
                [PSCustomObject] @{ IsCI = $false; CIProvider = 'None' }
            }
            Mock Get-NeoxixToolInfo {
                [PSCustomObject] @{ Available = $false; Version = $null }
            }
            Mock Get-NeoxixInstalledModuleInfo {
                [PSCustomObject] @{ Available = $false; Version = $null }
            }
            { Get-NeoxixEnvironment } | Should -Not -Throw
            (Get-NeoxixEnvironment).SdkSupported | Should -BeFalse
        }
    }
}

Describe 'Environment detection source security boundary' {
    It 'contains no network or installation command invocation' {
        $environmentFiles = @(
            Get-ChildItem `
                -LiteralPath (Join-Path $script:RepositoryRoot 'src\Neoxix.SDK\Private') `
                -Filter '*Neoxix*.ps1' `
                -File
            Get-Item `
                -LiteralPath (
                    Join-Path `
                        $script:RepositoryRoot `
                        'src\Neoxix.SDK\Public\Get-NeoxixEnvironment.ps1'
                )
        )
        $forbiddenCommands = @(
            'Invoke-WebRequest'
            'Invoke-RestMethod'
            'Install-Module'
            'Install-Package'
            'Start-BitsTransfer'
            'Start-Process'
            'Set-ExecutionPolicy'
            'New-PSSession'
            'Invoke-Command'
        )
        $invokedCommands = New-Object System.Collections.Generic.List[string]

        foreach ($file in $environmentFiles) {
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $file.FullName,
                [ref] $tokens,
                [ref] $parseErrors
            )
            $parseErrors.Count | Should -Be 0
            $commandAsts = $ast.FindAll(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                },
                $true
            )
            foreach ($commandAst in $commandAsts) {
                $commandName = $commandAst.GetCommandName()
                if ($commandName) {
                    $invokedCommands.Add($commandName)
                }
            }
        }

        foreach ($forbiddenCommand in $forbiddenCommands) {
            $invokedCommands | Should -Not -Contain $forbiddenCommand
        }

        $sourceText = ($environmentFiles | Get-Content -Raw) -join [Environment]::NewLine
        foreach ($forbiddenType in @(
                'System.Net.WebClient',
                'System.Net.Http.HttpClient',
                'System.Net.WebRequest'
            )) {
            $sourceText | Should -Not -Match ([regex]::Escape($forbiddenType))
        }
    }
}

Describe 'Tool-specific version parsing' {
    InModuleScope Neoxix.SDK {
        It 'parses the documented output for <ToolName>' -TestCases @(
            @{ ToolName = 'git'; Text = 'git version 2.45.1.windows.1'; Expected = '2.45.1' }
            @{ ToolName = 'gh'; Text = "gh version 2.52.0 (2024-06-10)`nhttps://github.com/cli/cli/releases/tag/v2.52.0"; Expected = '2.52.0' }
            @{ ToolName = 'code'; Text = "1.90.2`n5437499feb04f7a586f677b155b039bc2b3669eb`nx64"; Expected = '1.90.2' }
            @{ ToolName = 'docker'; Text = 'Docker version 26.1.4, build 5650f9b'; Expected = '26.1.4' }
        ) {
            param($ToolName, $Text, $Expected)
            ConvertTo-NeoxixVersion -ToolName $ToolName -InputText $Text |
                Should -Be ([version] $Expected)
        }

        It 'rejects ambiguous or erroneous <ToolName> output containing plausible versions' -TestCases @(
            @{ ToolName = 'git'; Text = 'fatal: protocol 2.0 is unsupported; git version 2.45.1' }
            @{ ToolName = 'gh'; Text = 'warning: config 2.0 invalid; gh 2.52.0 unavailable' }
            @{ ToolName = 'code'; Text = 'error 1.90.2: startup failed' }
            @{ ToolName = 'docker'; Text = 'Cannot connect to Docker 26.1.4, API 1.45' }
        ) {
            param($ToolName, $Text)
            ConvertTo-NeoxixVersion -ToolName $ToolName -InputText $Text |
                Should -BeNullOrEmpty
        }
    }
}

Describe 'Version command process boundary' {
    InModuleScope Neoxix.SDK {
        It 'isolates GitHub CLI configuration and authentication variables' {
            Mock Invoke-NeoxixChildProcess { return 'gh version 2.52.0' } -Verifiable
            $null = Invoke-NeoxixVersionCommand `
                -FilePath 'gh-fixture' `
                -Argument '--version' `
                -ToolName gh

            Should -Invoke Invoke-NeoxixChildProcess -Exactly 1 -ParameterFilter {
                $EnvironmentVariables.ContainsKey('GH_CONFIG_DIR') -and
                $EnvironmentVariables.GH_CONFIG_DIR -like (
                    [IO.Path]::Combine([IO.Path]::GetTempPath(), 'neoxix-gh-*')
                ) -and
                $RemoveEnvironmentVariables.Count -eq 4 -and
                $RemoveEnvironmentVariables -contains 'GH_TOKEN' -and
                $RemoveEnvironmentVariables -contains 'GITHUB_TOKEN' -and
                $RemoveEnvironmentVariables -contains 'GH_ENTERPRISE_TOKEN' -and
                $RemoveEnvironmentVariables -contains 'GITHUB_ENTERPRISE_TOKEN'
            }
        }

        It 'does not isolate non-GitHub tools unnecessarily' {
            Mock Invoke-NeoxixChildProcess { return 'git version 2.45.1' }
            $null = Invoke-NeoxixVersionCommand `
                -FilePath 'git-fixture' `
                -Argument '--version' `
                -ToolName git
            Should -Invoke Invoke-NeoxixChildProcess -Exactly 1 -ParameterFilter {
                $EnvironmentVariables.Count -eq 0 -and
                $RemoveEnvironmentVariables.Count -eq 0
            }
        }

        It 'can apply an isolated environment to a real child process' {
            $shellPath = (Get-Process -Id $PID).Path
            $environmentName = 'NEOXIX_CHILD_PROCESS_TEST'
            $output = Invoke-NeoxixChildProcess `
                -FilePath $shellPath `
                -Argument '-NoProfile -NonInteractive -Command "$env:NEOXIX_CHILD_PROCESS_TEST"' `
                -EnvironmentVariables @{ $environmentName = 'isolated-value' }
            $output.Trim() | Should -Be 'isolated-value'
            [Environment]::GetEnvironmentVariable($environmentName) | Should -BeNullOrEmpty
        }

        It 'removes an inherited variable without leaking collection results' {
            $shellPath = (Get-Process -Id $PID).Path
            $environmentName = 'NEOXIX_CHILD_PROCESS_REMOVE_TEST'
            [Environment]::SetEnvironmentVariable($environmentName, 'sensitive-value', 'Process')
            try {
                $output = @(
                    Invoke-NeoxixChildProcess `
                        -FilePath $shellPath `
                        -Argument (
                            '-NoProfile -NonInteractive -Command ' +
                            '"if ($null -eq $env:NEOXIX_CHILD_PROCESS_REMOVE_TEST) { ''removed'' }"'
                        ) `
                        -RemoveEnvironmentVariables $environmentName
                )
                $output.Count | Should -Be 1
                $output[0].Trim() | Should -Be 'removed'
            }
            finally {
                [Environment]::SetEnvironmentVariable($environmentName, $null, 'Process')
            }
        }

        It 'captures a large stdout stream without deadlocking' {
            $shellPath = (Get-Process -Id $PID).Path
            $output = Invoke-NeoxixChildProcess `
                -FilePath $shellPath `
                -Argument '-NoProfile -NonInteractive -Command "[Console]::Out.Write(''x'' * 200000)"' `
                -TimeoutMilliseconds 10000
            $output.Length | Should -Be 200000
        }

        It 'terminates a child process after a real timeout' {
            $shellPath = (Get-Process -Id $PID).Path
            $stopwatch = [Diagnostics.Stopwatch]::StartNew()
            {
                Invoke-NeoxixChildProcess `
                    -FilePath $shellPath `
                    -Argument '-NoProfile -NonInteractive -Command "Start-Sleep -Seconds 10"' `
                    -TimeoutMilliseconds 250
            } | Should -Throw '*timed out*'
            $stopwatch.Stop()
            $stopwatch.Elapsed.TotalSeconds | Should -BeLessThan 5
        }
    }
}

Describe 'Platform resolution and interaction' {
    InModuleScope Neoxix.SDK {
        It 'resolves explicit runtime platform <Expected>' -TestCases @(
            @{ Runtime = 'Windows'; Expected = 'Windows' }
            @{ Runtime = 'Linux'; Expected = 'Linux' }
            @{ Runtime = 'macOS'; Expected = 'macOS' }
            @{ Runtime = 'Unknown'; Expected = 'Unknown' }
        ) {
            param($Runtime, $Expected)
            Resolve-NeoxixPlatform `
                -RuntimePlatform $Runtime `
                -EnvironmentPlatform Unix |
                Should -Be $Expected
        }

        It 'uses the reliable Windows fallback' {
            Resolve-NeoxixPlatform `
                -RuntimePlatform Unavailable `
                -EnvironmentPlatform Win32NT |
                Should -Be 'Windows'
        }

        It 'returns Unknown for an ambiguous Unix fallback' {
            Resolve-NeoxixPlatform `
                -RuntimePlatform Unavailable `
                -EnvironmentPlatform Unix |
                Should -Be 'Unknown'
        }

        It 'distinguishes 32-bit process and 64-bit operating-system architecture' {
            $result = Resolve-NeoxixArchitecture `
                -Is64BitProcess $false `
                -Is64BitOperatingSystem $true
            $result.ProcessArchitecture | Should -Be 'X86'
            $result.OperatingSystemArchitecture | Should -Be 'X64'
        }

        It 'preserves runtime ARM architecture values' {
            $result = Resolve-NeoxixArchitecture `
                -RuntimeProcessArchitecture Arm64 `
                -RuntimeOperatingSystemArchitecture Arm64 `
                -Is64BitProcess $true `
                -Is64BitOperatingSystem $true
            $result.ProcessArchitecture | Should -Be 'Arm64'
            $result.OperatingSystemArchitecture | Should -Be 'Arm64'
        }

        It 'rejects interactivity in CI, redirected, remote, and remote-host sessions' {
            Test-NeoxixInteractiveSession -IsCI $true -UserInteractive $true `
                -InputRedirected $false -RemoteSession $false -HostName ConsoleHost |
                Should -BeFalse
            Test-NeoxixInteractiveSession -IsCI $false -UserInteractive $true `
                -InputRedirected $true -RemoteSession $false -HostName ConsoleHost |
                Should -BeFalse
            Test-NeoxixInteractiveSession -IsCI $false -UserInteractive $true `
                -InputRedirected $false -RemoteSession $true -HostName ConsoleHost |
                Should -BeFalse
            Test-NeoxixInteractiveSession -IsCI $false -UserInteractive $true `
                -InputRedirected $false -RemoteSession $false -HostName ServerRemoteHost |
                Should -BeFalse
        }

        It 'accepts a local interactive console' {
            Test-NeoxixInteractiveSession -IsCI $false -UserInteractive $true `
                -InputRedirected $false -RemoteSession $false -HostName ConsoleHost |
                Should -BeTrue
        }

        It 'normalizes quoted Linux os-release values' {
            ConvertFrom-NeoxixOsReleaseValue -Value '"Example \"Linux\" 1.0"' |
                Should -Be 'Example "Linux" 1.0'
            ConvertFrom-NeoxixOsReleaseValue -Value "'Example Linux 1.0'" |
                Should -Be 'Example Linux 1.0'
        }
    }
}

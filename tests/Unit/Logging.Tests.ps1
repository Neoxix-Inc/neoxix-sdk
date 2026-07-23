BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers.ps1')
    Import-TestModule
}

Describe 'Neoxix SDK logging' {
    AfterEach {
        Stop-NeoxixLog | Out-Null
    }

    It 'exports every logging function' {
        foreach ($name in @(
                'Start-NeoxixLog',
                'Stop-NeoxixLog',
                'Write-NeoxixInfo',
                'Write-NeoxixSuccess',
                'Write-NeoxixWarning',
                'Write-NeoxixError',
                'Write-NeoxixDebug'
            )) {
            Get-Command -Name $name -Module Neoxix.SDK | Should -Not -BeNullOrEmpty
        }
    }

    It 'returns the expected structured level for every logging command' {
        (Write-NeoxixInfo -Message 'info').Level | Should -Be 'INFO'
        (Write-NeoxixSuccess -Message 'success').Level | Should -Be 'SUCCESS'
        $warningResult = Write-NeoxixWarning -Message 'warning' -WarningAction SilentlyContinue
        $warningResult.Level | Should -Be 'WARNING'
        $errorResult = Write-NeoxixError -Message 'error' -ErrorAction SilentlyContinue
        $errorResult.Level | Should -Be 'ERROR'
        Start-NeoxixLog -EnableDebug | Out-Null
        (Write-NeoxixDebug -Message 'debug').Level | Should -Be 'DEBUG'
    }

    It 'suppresses debug output when disabled' {
        Start-NeoxixLog | Out-Null
        Write-NeoxixDebug -Message 'hidden' | Should -BeNullOrEmpty
    }

    It 'produces debug output when enabled' {
        Start-NeoxixLog -EnableDebug | Out-Null
        $result = Write-NeoxixDebug -Message 'visible'
        $result.Level | Should -Be 'DEBUG'
        $result.Message | Should -Be 'visible'
    }

    It 'writes every level, debug entries, and ISO timestamps to the log file' {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'sdk.log'
        Start-NeoxixLog -Path $logPath -EnableDebug | Out-Null
        Write-NeoxixInfo -Message 'info file message' | Out-Null
        Write-NeoxixSuccess -Message 'success file message' | Out-Null
        Write-NeoxixWarning `
            -Message 'warning file message' `
            -WarningAction SilentlyContinue |
            Out-Null
        Write-NeoxixError `
            -Message 'error file message' `
            -ErrorAction SilentlyContinue |
            Out-Null
        Write-NeoxixDebug -Message 'debug file message' | Out-Null

        Test-Path -LiteralPath $logPath | Should -BeTrue
        $lines = [System.IO.File]::ReadAllLines($logPath)
        $lines.Count | Should -Be 5
        foreach ($level in @('INFO', 'SUCCESS', 'WARNING', 'ERROR', 'DEBUG')) {
            @($lines | Where-Object { $_ -match ('\[{0}\]' -f $level) }).Count |
                Should -Be 1
        }
        foreach ($line in $lines) {
            $line | Should -Match '^\d{4}-\d{2}-\d{2}T.*[+-]\d{2}:\d{2} \[[A-Z]+\] '
        }
    }

    It 'writes valid UTF-8 bytes without data loss' {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'utf8.log'
        $message = 'café - 日本語'
        Start-NeoxixLog -Path $logPath | Out-Null
        Write-NeoxixInfo -Message $message | Out-Null

        $bytes = [System.IO.File]::ReadAllBytes($logPath)
        $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
        { $strictUtf8.GetString($bytes) } | Should -Not -Throw
        $strictUtf8.GetString($bytes) | Should -Match ([regex]::Escape($message))
    }

    It 'masks identifiable secrets in objects and files' {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'redacted.log'
        $secretName = 'pass' + 'word'
        $secretValue = 'not-a-real-secret-fixture'
        $bearerValue = 'fixtureBearerValue0123456789'
        $privateKeyStart = '-----BEGIN ' + 'PRIVATE KEY-----'
        $privateKeyEnd = '-----END ' + 'PRIVATE KEY-----'
        $message = '{0}={1} Bearer {2} {3} key-material {4}' -f `
            $secretName,
            $secretValue,
            $bearerValue,
            $privateKeyStart,
            $privateKeyEnd

        Start-NeoxixLog -Path $logPath | Out-Null
        $entry = Write-NeoxixInfo -Message $message
        $content = Get-Content -LiteralPath $logPath -Raw

        $entry.Message | Should -Not -Match ([regex]::Escape($secretValue))
        $entry.Message | Should -Not -Match ([regex]::Escape($bearerValue))
        $entry.Message | Should -Not -Match 'key-material'
        $content | Should -Not -Match ([regex]::Escape($secretValue))
        $content | Should -Not -Match ([regex]::Escape($bearerValue))
        $content | Should -Not -Match 'key-material'
        $content | Should -Match '\[REDACTED\]'
        $content | Should -Match '\[REDACTED PRIVATE KEY\]'
    }

    It 'encodes CR and LF so one call produces one physical log line' {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'single-line.log'
        Start-NeoxixLog -Path $logPath | Out-Null
        $entry = Write-NeoxixInfo -Message "legitimate`r`n[ERROR] forged"

        $lines = [System.IO.File]::ReadAllLines($logPath)
        $lines.Count | Should -Be 1
        $lines[0] | Should -Match 'legitimate\\n\[ERROR\] forged'
        $entry.Message | Should -Be 'legitimate\n[ERROR] forged'
    }

    It 'stops and resets logging state' {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'stopped.log'
        Start-NeoxixLog -Path $logPath -EnableDebug | Out-Null
        $previous = Stop-NeoxixLog
        $previous.FilePath | Should -Be $logPath
        $previous.DebugEnabled | Should -BeTrue
        Write-NeoxixInfo -Message 'not persisted' | Out-Null
        (Get-Content -LiteralPath $logPath -Raw) | Should -Not -Match 'not persisted'
        Write-NeoxixDebug -Message 'hidden' | Should -BeNullOrEmpty
    }

    It 'respects WhatIf when starting and stopping logging' {
        $unusedPath = Join-Path -Path $TestDrive -ChildPath 'whatif-unused.log'
        Start-NeoxixLog -Path $unusedPath -WhatIf
        Test-Path -LiteralPath $unusedPath | Should -BeFalse

        $activePath = Join-Path -Path $TestDrive -ChildPath 'whatif-active.log'
        Start-NeoxixLog -Path $activePath | Out-Null
        Stop-NeoxixLog -WhatIf
        Write-NeoxixInfo -Message 'still active' | Out-Null
        Get-Content -LiteralPath $activePath -Raw | Should -Match 'still active'
    }

    It 'rejects empty messages and missing directories predictably' {
        { Write-NeoxixInfo -Message '' } | Should -Throw
        $invalidPath = Join-Path -Path $TestDrive -ChildPath 'missing\sdk.log'
        { Start-NeoxixLog -Path $invalidPath } | Should -Throw '*does not exist*'
    }
}

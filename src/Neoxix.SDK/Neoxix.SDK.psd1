@{
    RootModule        = 'Neoxix.SDK.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '49eb55ee-97b2-4b7c-84d5-b740efad0d40'
    Author            = 'Neoxix Inc.'
    CompanyName       = 'Neoxix Inc.'
    Copyright         = 'Copyright (c) 2026 Neoxix Inc.'
    Description       = 'Reusable engineering foundation for Neoxix PowerShell automation.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-NeoxixSdkInfo'
        'Start-NeoxixLog'
        'Stop-NeoxixLog'
        'Write-NeoxixDebug'
        'Write-NeoxixError'
        'Write-NeoxixInfo'
        'Write-NeoxixSuccess'
        'Write-NeoxixWarning'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('Neoxix', 'SDK', 'Engineering', 'PowerShell')
            LicenseUri   = 'https://github.com/Neoxix-Inc/neoxix-sdk/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/Neoxix-Inc/neoxix-sdk'
            ReleaseNotes = 'Initial engineering foundation with module metadata and structured logging.'
        }
    }
}

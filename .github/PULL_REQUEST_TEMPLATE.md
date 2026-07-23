## Summary

Describe the reusable engineering change and its motivation.

## Validation

- [ ] `Test-ModuleManifest .\src\Neoxix.SDK\Neoxix.SDK.psd1`
- [ ] `Invoke-ScriptAnalyzer -Path .\src\Neoxix.SDK -Recurse -Settings .\PSScriptAnalyzerSettings.psd1`
- [ ] `Invoke-Pester -Path .\tests -CI`
- [ ] `.\build\build.ps1 -Task Validate`

## Quality and security

- [ ] Documentation and tests are updated.
- [ ] No credentials, secrets, or production data are included.
- [ ] The change remains compatible with Windows PowerShell 5.1 and PowerShell 7+.
- [ ] No out-of-scope feature or breaking change is introduced.

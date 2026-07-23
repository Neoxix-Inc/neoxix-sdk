# Examples

## Inspect the SDK

```powershell
Import-Module ..\src\Neoxix.SDK\Neoxix.SDK.psd1 -Force
Get-NeoxixSdkInfo
```

## Log to a file

```powershell
$logPath = Join-Path $PWD 'neoxix.log'
Start-NeoxixLog -Path $logPath -EnableDebug
Write-NeoxixInfo -Message 'Example started.'
Write-NeoxixDebug -Message 'Debug detail.'
Write-NeoxixSuccess -Message 'Example completed.'
Stop-NeoxixLog
```

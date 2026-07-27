function Invoke-NeoxixChildProcess {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Argument,

        [Parameter()]
        [ValidateRange(100, 30000)]
        [int] $TimeoutMilliseconds = 5000,

        [Parameter()]
        [hashtable] $EnvironmentVariables = @{},

        [Parameter()]
        [string[]] $RemoveEnvironmentVariables = @()
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.Arguments = $Argument
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $processEnvironment = $startInfo.EnvironmentVariables
    if ($null -eq $processEnvironment -and $startInfo.PSObject.Properties['Environment']) {
        $processEnvironment = $startInfo.Environment
    }
    if ($null -eq $processEnvironment) {
        throw 'Unable to isolate the child process environment.'
    }

    foreach ($variableName in $EnvironmentVariables.Keys) {
        $processEnvironment[$variableName] = $EnvironmentVariables[$variableName]
    }
    foreach ($variableName in $RemoveEnvironmentVariables) {
        $null = $processEnvironment.Remove($variableName)
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Unable to start child process: $FilePath"
        }

        $standardOutputTask = $process.StandardOutput.ReadToEndAsync()
        $standardErrorTask = $process.StandardError.ReadToEndAsync()

        if (-not $process.WaitForExit($TimeoutMilliseconds)) {
            try {
                $process.Kill()
                if (-not $process.WaitForExit($TimeoutMilliseconds)) {
                    throw "Timed-out child process did not terminate: $FilePath"
                }
            }
            catch {
                throw "Unable to stop timed-out child process: $FilePath"
            }
            throw "Child process timed out: $FilePath"
        }

        $standardOutput = $standardOutputTask.GetAwaiter().GetResult()
        $null = $standardErrorTask.GetAwaiter().GetResult()
        return $standardOutput
    }
    finally {
        $process.Dispose()
    }
}

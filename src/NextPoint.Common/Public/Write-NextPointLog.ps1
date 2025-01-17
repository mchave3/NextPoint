function Write-NextPointLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Information', 'Warning', 'Error', 'Debug')]
        [string]$Level
    )

    try {
        $logPath = Get-NextPointLogPath
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Ensure log directory exists
        $logDir = Split-Path $logPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        # Write log entry
        Add-Content -Path $logPath -Value $logEntry -Encoding UTF8
    }
    catch {
        $errorMessage = "Failed to write to log: $_"
        Write-Error $errorMessage
        throw $errorMessage
    }
}

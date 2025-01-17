function Write-NextPointError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [System.Exception]$Exception,
        
        [Parameter()]
        [switch]$IncludeCallStack
    )

    try {
        $errorMessage = $Message

        if ($Exception) {
            $errorMessage += "`nException: $($Exception.Message)"
            if ($Exception.StackTrace) {
                $errorMessage += "`nStack Trace: $($Exception.StackTrace)"
            }
        }

        if ($IncludeCallStack) {
            $callStack = Get-PSCallStack | Select-Object -Skip 1 | ForEach-Object {
                "  at $($_.Command) in $($_.Location)"
            }
            $errorMessage += "`nCall Stack:`n$($callStack -join "`n")"
        }

        # Log the error
        Write-NextPointLog -Message $errorMessage -Level Error

        # Write to error stream as well
        Write-Error $errorMessage
    }
    catch {
        # If logging fails, at least write to error stream
        Write-Error "Failed to log error: $_"
        Write-Error $Message
    }
}

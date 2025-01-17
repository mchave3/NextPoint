function Get-NextPointLogPath {
    [CmdletBinding()]
    param()

    # Get the application data path
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $nextPointPath = Join-Path $appDataPath "NextPoint"
    
    # Return the log file path
    return Join-Path $nextPointPath "NextPoint.log"
}

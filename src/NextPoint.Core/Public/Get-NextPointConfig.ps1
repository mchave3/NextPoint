function Get-NextPointConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigPath = "$env:APPDATA\NextPoint\config.json"
    )

    try {
        if (-not (Test-Path $ConfigPath)) {
            Write-NextPointError -Message "Configuration file not found at: $ConfigPath"
            return $null
        }

        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        return $config
    }
    catch {
        Write-NextPointError -Message "Failed to read configuration" -Exception $_
        throw
    }
}

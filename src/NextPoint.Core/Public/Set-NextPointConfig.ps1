function Set-NextPointConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Configuration,
        
        [Parameter()]
        [string]$ConfigPath = "$env:APPDATA\NextPoint\config.json"
    )

    try {
        # Ensure config directory exists
        $configDir = Split-Path $ConfigPath -Parent
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }

        # Validate configuration schema
        if (-not ($Configuration.PSObject.Properties.Name -contains 'ServerName')) {
            throw "Invalid configuration: Missing required property 'ServerName'"
        }

        # Convert and save configuration
        $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Force
        Write-NextPointLog -Message "Configuration updated successfully" -Level Information
    }
    catch {
        Write-NextPointError -Message "Failed to save configuration" -Exception $_
        throw
    }
}

function Connect-NextPointService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,
        
        [Parameter()]
        [int]$Port = 443,
        
        [Parameter()]
        [switch]$UseSSL = $true
    )

    try {
        # Log connection attempt
        Write-NextPointLog -Message "Attempting to connect to $ServerName" -Level Information
        
        # Validate server availability
        $testConnection = Test-NetConnection -ComputerName $ServerName -Port $Port -WarningAction SilentlyContinue
        if (-not $testConnection.TcpTestSucceeded) {
            throw "Failed to connect to server $ServerName on port $Port"
        }

        # Create connection object
        $connection = [PSCustomObject]@{
            ServerName = $ServerName
            Port = $Port
            UseSSL = $UseSSL
            Connected = $true
            LastConnected = Get-Date
        }

        # Store connection in session state
        $Script:NextPointConnection = $connection

        Write-NextPointLog -Message "Successfully connected to $ServerName" -Level Information
        return $connection
    }
    catch {
        Write-NextPointError -Message "Failed to connect to NextPoint service" -Exception $_
        throw
    }
}

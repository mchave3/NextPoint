function Test-NextPointCredential {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [string]$Domain = $env:USERDOMAIN
    )

    try {
        # Add assembly for directory services
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create principal context
        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain, 
            $Domain
        )

        # Validate credentials
        $isValid = $principalContext.ValidateCredentials(
            $Credential.UserName, 
            $Credential.GetNetworkCredential().Password
        )

        if ($isValid) {
            Write-NextPointLog -Message "Credentials validated successfully for user: $($Credential.UserName)" -Level Information
        }
        else {
            Write-NextPointLog -Message "Invalid credentials for user: $($Credential.UserName)" -Level Warning
        }

        return $isValid
    }
    catch {
        Write-NextPointError -Message "Failed to validate credentials" -Exception $_
        throw
    }
    finally {
        if ($principalContext) {
            $principalContext.Dispose()
        }
    }
}

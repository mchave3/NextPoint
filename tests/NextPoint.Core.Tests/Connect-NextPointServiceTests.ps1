BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Core\NextPoint.Core.psm1"
    Import-Module $ModulePath -Force
}

Describe "Connect-NextPointService" {
    BeforeEach {
        # Mock dependencies
        Mock Test-NetConnection { 
            return [PSCustomObject]@{
                TcpTestSucceeded = $true
            }
        }
        Mock Write-NextPointLog
        Mock Write-NextPointError
    }

    Context "When connecting to the service" {
        It "Should successfully connect with valid credentials" {
            # Arrange
            $serverName = "testserver.local"
            $securePassword = ConvertTo-SecureString "TestPass123" -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ("testuser", $securePassword)

            # Act
            $result = Connect-NextPointService -ServerName $serverName -Credential $credential

            # Assert
            $result | Should -Not -BeNull
            $result.ServerName | Should -Be $serverName
            $result.Connected | Should -Be $true
            Should -Invoke Write-NextPointLog -Times 2
        }

        It "Should throw when server is not available" {
            # Arrange
            Mock Test-NetConnection { 
                return [PSCustomObject]@{
                    TcpTestSucceeded = $false
                }
            }
            $securePassword = ConvertTo-SecureString "TestPass123" -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ("testuser", $securePassword)

            # Act & Assert
            { Connect-NextPointService -ServerName "invalid.server" -Credential $credential } | 
                Should -Throw "Failed to connect to server*"
            Should -Invoke Write-NextPointError -Times 1
        }

        It "Should use custom port when specified" {
            # Arrange
            $serverName = "testserver.local"
            $customPort = 8443
            $securePassword = ConvertTo-SecureString "TestPass123" -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ("testuser", $securePassword)

            # Act
            $result = Connect-NextPointService -ServerName $serverName -Credential $credential -Port $customPort

            # Assert
            $result.Port | Should -Be $customPort
            Should -Invoke Test-NetConnection -Times 1 -ParameterFilter {
                $Port -eq $customPort
            }
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Core -ErrorAction SilentlyContinue
}

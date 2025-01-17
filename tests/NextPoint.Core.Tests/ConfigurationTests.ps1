BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Core\NextPoint.Core.psm1"
    Import-Module $ModulePath -Force
}

Describe "NextPoint Configuration Management" {
    BeforeEach {
        # Set up test config path
        $script:TestConfigPath = Join-Path $TestDrive "config.json"
        Mock Write-NextPointLog
        Mock Write-NextPointError
    }

    Context "Get-NextPointConfig" {
        It "Should return null when config file doesn't exist" {
            # Act
            $result = Get-NextPointConfig -ConfigPath $script:TestConfigPath

            # Assert
            $result | Should -BeNull
            Should -Invoke Write-NextPointError -Times 1
        }

        It "Should return configuration when file exists" {
            # Arrange
            $testConfig = @{
                ServerName = "testserver.local"
                Port = 443
            }
            $testConfig | ConvertTo-Json | Set-Content -Path $script:TestConfigPath

            # Act
            $result = Get-NextPointConfig -ConfigPath $script:TestConfigPath

            # Assert
            $result | Should -Not -BeNull
            $result.ServerName | Should -Be "testserver.local"
            $result.Port | Should -Be 443
        }
    }

    Context "Set-NextPointConfig" {
        It "Should create config file when it doesn't exist" {
            # Arrange
            $config = [PSCustomObject]@{
                ServerName = "testserver.local"
                Port = 443
            }

            # Act
            Set-NextPointConfig -Configuration $config -ConfigPath $script:TestConfigPath

            # Assert
            $script:TestConfigPath | Should -Exist
            Should -Invoke Write-NextPointLog -Times 1
        }

        It "Should throw on invalid configuration" {
            # Arrange
            $invalidConfig = [PSCustomObject]@{
                Port = 443
            }

            # Act & Assert
            { Set-NextPointConfig -Configuration $invalidConfig -ConfigPath $script:TestConfigPath } | 
                Should -Throw "*Missing required property 'ServerName'*"
            Should -Invoke Write-NextPointError -Times 1
        }

        It "Should update existing configuration" {
            # Arrange
            $initialConfig = [PSCustomObject]@{
                ServerName = "oldserver.local"
                Port = 443
            }
            Set-NextPointConfig -Configuration $initialConfig -ConfigPath $script:TestConfigPath

            $newConfig = [PSCustomObject]@{
                ServerName = "newserver.local"
                Port = 8443
            }

            # Act
            Set-NextPointConfig -Configuration $newConfig -ConfigPath $script:TestConfigPath

            # Assert
            $savedConfig = Get-Content $script:TestConfigPath | ConvertFrom-Json
            $savedConfig.ServerName | Should -Be "newserver.local"
            $savedConfig.Port | Should -Be 8443
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Core -ErrorAction SilentlyContinue
}

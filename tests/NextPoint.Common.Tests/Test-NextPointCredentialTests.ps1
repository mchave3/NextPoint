BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Common\NextPoint.Common.psm1"
    Import-Module $ModulePath -Force
}

Describe "Test-NextPointCredential" {
    BeforeEach {
        # Mock dependencies
        Mock Write-NextPointLog
        Mock Write-NextPointError
        Mock Add-Type
    }

    Context "When validating credentials" {
        BeforeEach {
            # Create test credential
            $securePassword = ConvertTo-SecureString "TestPass123" -AsPlainText -Force
            $script:testCredential = New-Object System.Management.Automation.PSCredential ("testuser", $securePassword)
        }

        It "Should return true for valid credentials" {
            # Arrange
            Mock New-Object {
                return [PSCustomObject]@{
                    ValidateCredentials = { param($username, $password) return $true }
                    Dispose = { }
                }
            } -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' }

            # Act
            $result = Test-NextPointCredential -Credential $script:testCredential

            # Assert
            $result | Should -Be $true
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Information' -and $Message -like "*validated successfully*"
            }
        }

        It "Should return false for invalid credentials" {
            # Arrange
            Mock New-Object {
                return [PSCustomObject]@{
                    ValidateCredentials = { param($username, $password) return $false }
                    Dispose = { }
                }
            } -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' }

            # Act
            $result = Test-NextPointCredential -Credential $script:testCredential

            # Assert
            $result | Should -Be $false
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Warning' -and $Message -like "*Invalid credentials*"
            }
        }

        It "Should handle validation errors gracefully" {
            # Arrange
            Mock New-Object {
                return [PSCustomObject]@{
                    ValidateCredentials = { throw "Network error" }
                    Dispose = { }
                }
            } -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' }

            # Act & Assert
            { Test-NextPointCredential -Credential $script:testCredential } | Should -Throw
            Should -Invoke Write-NextPointError -Times 1
        }

        It "Should use specified domain" {
            # Arrange
            $testDomain = "test.local"
            Mock New-Object {
                return [PSCustomObject]@{
                    ValidateCredentials = { return $true }
                    Dispose = { }
                }
            } -ParameterFilter { 
                $ArgumentList[1] -eq $testDomain
            }

            # Act
            $result = Test-NextPointCredential -Credential $script:testCredential -Domain $testDomain

            # Assert
            $result | Should -Be $true
            Should -Invoke New-Object -Times 1 -ParameterFilter {
                $ArgumentList[1] -eq $testDomain
            }
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Common -ErrorAction SilentlyContinue
}

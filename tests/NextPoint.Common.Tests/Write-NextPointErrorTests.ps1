BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Common\NextPoint.Common.psm1"
    Import-Module $ModulePath -Force
}

Describe "Write-NextPointError" {
    BeforeEach {
        # Mock Write-NextPointLog to prevent actual logging
        Mock Write-NextPointLog
    }

    Context "When handling errors" {
        It "Should log error message" {
            # Arrange
            $errorMessage = "Test error message"
            
            # Act
            Write-NextPointError -Message $errorMessage

            # Assert
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Message -eq $errorMessage -and $Level -eq "Error"
            }
        }

        It "Should include exception details when provided" {
            # Arrange
            $errorMessage = "Test error message"
            $exception = [System.Exception]::new("Test exception")
            
            # Act
            Write-NextPointError -Message $errorMessage -Exception $exception

            # Assert
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Message -like "*$errorMessage*" -and 
                $Message -like "*Test exception*" -and 
                $Level -eq "Error"
            }
        }

        It "Should include call stack when specified" {
            # Arrange
            $errorMessage = "Test error message"
            
            # Act
            Write-NextPointError -Message $errorMessage -IncludeCallStack

            # Assert
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Message -like "*$errorMessage*" -and 
                $Message -like "*Call Stack:*" -and 
                $Level -eq "Error"
            }
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Common -ErrorAction SilentlyContinue
}

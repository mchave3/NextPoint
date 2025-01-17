BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.UI\NextPoint.UI.psm1"
    Import-Module $ModulePath -Force
}

Describe "Set-NextPointView" {
    BeforeEach {
        # Mock dependencies
        Mock Write-NextPointLog
        Mock Write-NextPointError
        
        # Create mock window and UI elements
        $script:mockContentFrame = [PSCustomObject]@{
            Navigate = { param($content) }
        }
        
        $script:mockStatusMessage = [PSCustomObject]@{
            Content = $null
        }
        
        $script:mockWindow = [PSCustomObject]@{
            UIElements = @{
                ContentFrame = $script:mockContentFrame
                StatusMessage = $script:mockStatusMessage
            }
        }
    }

    Context "When setting views" {
        It "Should navigate to Dashboard view" {
            # Arrange
            Mock New-NextPointDashboardView { return "DashboardContent" }

            # Act
            Set-NextPointView -Window $script:mockWindow -View 'Dashboard'

            # Assert
            $script:mockStatusMessage.Content | Should -Be "Viewing: Dashboard"
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Information' -and $Message -like "*Navigated to Dashboard*"
            }
        }

        It "Should navigate to Devices view" {
            # Arrange
            Mock New-NextPointDevicesView { return "DevicesContent" }

            # Act
            Set-NextPointView -Window $script:mockWindow -View 'Devices'

            # Assert
            $script:mockStatusMessage.Content | Should -Be "Viewing: Devices"
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Information' -and $Message -like "*Navigated to Devices*"
            }
        }

        It "Should navigate to Reports view" {
            # Arrange
            Mock New-NextPointReportsView { return "ReportsContent" }

            # Act
            Set-NextPointView -Window $script:mockWindow -View 'Reports'

            # Assert
            $script:mockStatusMessage.Content | Should -Be "Viewing: Reports"
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Information' -and $Message -like "*Navigated to Reports*"
            }
        }

        It "Should handle navigation errors" {
            # Arrange
            Mock New-NextPointDashboardView { throw "View error" }

            # Act & Assert
            { Set-NextPointView -Window $script:mockWindow -View 'Dashboard' } | Should -Throw
            Should -Invoke Write-NextPointError -Times 1 -ParameterFilter {
                $Message -like "*Failed to set view to: Dashboard*"
            }
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.UI -ErrorAction SilentlyContinue
}

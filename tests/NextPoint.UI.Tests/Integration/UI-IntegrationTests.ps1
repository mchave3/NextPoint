BeforeAll {
    # Import required modules
    $CoreModulePath = Join-Path $PSScriptRoot "..\..\..\src\NextPoint.Core\NextPoint.Core.psm1"
    $CommonModulePath = Join-Path $PSScriptRoot "..\..\..\src\NextPoint.Common\NextPoint.Common.psm1"
    $UIModulePath = Join-Path $PSScriptRoot "..\..\..\src\NextPoint.UI\NextPoint.UI.psm1"
    
    Import-Module $CoreModulePath -Force
    Import-Module $CommonModulePath -Force
    Import-Module $UIModulePath -Force
}

Describe "UI Integration Tests" {
    BeforeEach {
        # Mock dependencies
        Mock Write-NextPointLog
        Mock Write-NextPointError
    }

    Context "When performing end-to-end UI operations" {
        It "Should create window and navigate through views" {
            # Arrange
            $window = New-NextPointWindow

            # Act & Assert - Window Creation
            $window | Should -Not -BeNull
            $window.UIElements | Should -Not -BeNull
            $window.UIElements.ContentFrame | Should -Not -BeNull

            # Act & Assert - Navigation
            { Set-NextPointView -Window $window -View 'Dashboard' } | Should -Not -Throw
            { Set-NextPointView -Window $window -View 'Devices' } | Should -Not -Throw
            { Set-NextPointView -Window $window -View 'Reports' } | Should -Not -Throw
        }

        It "Should handle connection status updates" {
            # Arrange
            $window = New-NextPointWindow
            $connectionStatus = $window.UIElements.StatusConnection

            # Act - Simulate connection
            $connectionStatus.Content = "Connected to Server"

            # Assert
            $connectionStatus.Content | Should -Be "Connected to Server"
        }

        It "Should update status messages" {
            # Arrange
            $window = New-NextPointWindow
            $statusMessage = $window.UIElements.StatusMessage

            # Act - Navigate to different views
            Set-NextPointView -Window $window -View 'Dashboard'
            $dashboardStatus = $statusMessage.Content

            Set-NextPointView -Window $window -View 'Devices'
            $devicesStatus = $statusMessage.Content

            # Assert
            $dashboardStatus | Should -Be "Viewing: Dashboard"
            $devicesStatus | Should -Be "Viewing: Devices"
        }

        It "Should maintain UI state across operations" {
            # Arrange
            $window = New-NextPointWindow

            # Act - Perform multiple operations
            Set-NextPointView -Window $window -View 'Dashboard'
            $window.UIElements.StatusConnection.Content = "Connected"
            Set-NextPointView -Window $window -View 'Devices'

            # Assert
            $window.UIElements.StatusConnection.Content | Should -Be "Connected"
            $window.UIElements.StatusMessage.Content | Should -Be "Viewing: Devices"
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Core -ErrorAction SilentlyContinue
    Remove-Module NextPoint.Common -ErrorAction SilentlyContinue
    Remove-Module NextPoint.UI -ErrorAction SilentlyContinue
}

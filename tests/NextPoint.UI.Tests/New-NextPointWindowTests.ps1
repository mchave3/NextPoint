BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.UI\NextPoint.UI.psm1"
    Import-Module $ModulePath -Force
}

Describe "New-NextPointWindow" {
    BeforeEach {
        # Mock dependencies
        Mock Write-NextPointLog
        Mock Write-NextPointError
        Mock Add-Type
    }

    Context "When creating main window" {
        BeforeAll {
            # Mock WPF types
            $script:mockWindow = [PSCustomObject]@{
                Title = "NextPoint"
                FindName = { param($name) return [PSCustomObject]@{ Name = $name } }
                Close = { }
            }
            
            Mock [System.Windows.Markup.XamlReader]::Load { 
                return $script:mockWindow 
            }
        }

        It "Should create window with all UI elements" {
            # Act
            $result = New-NextPointWindow

            # Assert
            $result | Should -Not -BeNull
            $result.Title | Should -Be "NextPoint"
            $result.UIElements | Should -Not -BeNull
            Should -Invoke Write-NextPointLog -Times 1 -ParameterFilter {
                $Level -eq 'Information' -and $Message -like "*created successfully*"
            }
        }

        It "Should handle XAML loading errors" {
            # Arrange
            Mock [System.Windows.Markup.XamlReader]::Load { 
                throw "XAML error" 
            }

            # Act & Assert
            { New-NextPointWindow } | Should -Throw
            Should -Invoke Write-NextPointError -Times 1 -ParameterFilter {
                $Message -like "*Failed to create main window*"
            }
        }

        It "Should add all required event handlers" {
            # Act
            $window = New-NextPointWindow

            # Assert
            $window.UIElements.MenuConnect | Should -Not -BeNull
            $window.UIElements.MenuSettings | Should -Not -BeNull
            $window.UIElements.MenuExit | Should -Not -BeNull
            $window.UIElements.NavDashboard | Should -Not -BeNull
            $window.UIElements.NavDevices | Should -Not -BeNull
            $window.UIElements.NavReports | Should -Not -BeNull
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.UI -ErrorAction SilentlyContinue
}

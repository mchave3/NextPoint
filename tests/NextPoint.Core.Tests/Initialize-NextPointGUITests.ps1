BeforeAll {
    # Import the module under test
    $ModulePath = Join-Path $PSScriptRoot "..\..\src\NextPoint.Core\NextPoint.Core.psm1"
    Import-Module $ModulePath -Force
}

Describe "Initialize-NextPointGUI" {
    Context "When initializing the GUI" {
        It "Should create the main window" {
            # Arrange
            Mock -CommandName New-Object -MockWith { 
                return [PSCustomObject]@{
                    Title = $null
                    Width = 0
                    Height = 0
                }
            }

            # Act
            $result = Initialize-NextPointGUI

            # Assert
            $result | Should -Not -BeNull
            $result.Title | Should -Be "NextPoint"
        }

        It "Should set default window dimensions" {
            # Act
            $result = Initialize-NextPointGUI

            # Assert
            $result.Width | Should -BeGreaterThan 0
            $result.Height | Should -BeGreaterThan 0
        }

        It "Should load required WPF assemblies" {
            # Act & Assert
            { Initialize-NextPointGUI } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module NextPoint.Core -ErrorAction SilentlyContinue
}

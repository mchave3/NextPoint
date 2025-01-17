BeforeAll {
    . $PSScriptRoot\..\..\src\NextPoint.Core\Public\Initialize-NextPointGUI.ps1
}

Describe "Initialize-NextPointGUI" {
    It "Should return a WPF window object" {
        $result = Initialize-NextPointGUI
        $result.GetType().Name | Should -Be 'Window'
    }

    It "Should have required UI elements" {
        $window = Initialize-NextPointGUI
        $window.FindName('MainMenu') | Should -Not -BeNullOrEmpty
        $window.FindName('StatusBar') | Should -Not -BeNullOrEmpty
    }
}

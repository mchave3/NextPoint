function New-NextPointWindow {
    [CmdletBinding()]
    param()

    try {
        # Load required assemblies
        Add-Type -AssemblyName PresentationFramework
        Add-Type -AssemblyName PresentationCore
        Add-Type -AssemblyName WindowsBase

        # Load XAML
        $xamlPath = Join-Path $PSScriptRoot "..\XAML\MainWindow.xaml"
        $xamlContent = Get-Content -Path $xamlPath -Raw
        $xamlContent = $xamlContent -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
        
        # Parse XAML
        $reader = New-Object System.Xml.XmlNodeReader ([xml]$xamlContent)
        $window = [System.Windows.Markup.XamlReader]::Load($reader)

        # Get UI elements
        $elements = @{}
        ([xml]$xamlContent).SelectNodes("//*[@Name]") | ForEach-Object {
            $elements[$_.Name] = $window.FindName($_.Name)
        }

        # Add event handlers
        $elements.MenuConnect.Add_Click({ Invoke-NextPointConnect -Window $window })
        $elements.MenuSettings.Add_Click({ Show-NextPointSettings -Window $window })
        $elements.MenuExit.Add_Click({ $window.Close() })
        $elements.MenuAbout.Add_Click({ Show-NextPointAbout -Window $window })

        # Navigation events
        $elements.NavDashboard.Add_Click({ Set-NextPointView -Window $window -View 'Dashboard' })
        $elements.NavDevices.Add_Click({ Set-NextPointView -Window $window -View 'Devices' })
        $elements.NavReports.Add_Click({ Set-NextPointView -Window $window -View 'Reports' })

        # Store elements in window for later access
        $window | Add-Member -NotePropertyName UIElements -NotePropertyValue $elements

        Write-NextPointLog -Message "Main window created successfully" -Level Information
        return $window
    }
    catch {
        Write-NextPointError -Message "Failed to create main window" -Exception $_
        throw
    }
}

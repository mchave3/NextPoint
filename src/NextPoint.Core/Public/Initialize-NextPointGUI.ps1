function Initialize-NextPointGUI {
    [CmdletBinding()]
    param()

    try {
        Add-Type -AssemblyName PresentationFramework
        $xamlFile = Join-Path $PSScriptRoot "..\XAML\MainWindow.xaml"
        $inputXML = Get-Content -Path $xamlFile -Raw
        $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
        [XML]$XAML = $inputXML

        $reader = New-Object System.Xml.XmlNodeReader $XAML
        $window = [System.Windows.Markup.XamlReader]::Load($reader)

        # Store XAML elements as PowerShell objects
        $XAML.SelectNodes("//*[@Name]") | ForEach-Object {
            Set-Variable -Name "WPF$($_.Name)" -Value $window.FindName($_.Name) -Scope Script
        }

        return $window
    }
    catch {
        Write-Error "Failed to initialize GUI: $_"
        throw
    }
}

function Set-NextPointView {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Windows.Window]$Window,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Dashboard', 'Devices', 'Reports')]
        [string]$View
    )

    try {
        $contentFrame = $Window.UIElements.ContentFrame

        # Create view content
        $viewContent = switch ($View) {
            'Dashboard' {
                New-NextPointDashboardView
            }
            'Devices' {
                New-NextPointDevicesView
            }
            'Reports' {
                New-NextPointReportsView
            }
        }

        # Navigate to the new view
        $contentFrame.Navigate($viewContent)
        Write-NextPointLog -Message "Navigated to $View view" -Level Information

        # Update status message
        $Window.UIElements.StatusMessage.Content = "Viewing: $View"
    }
    catch {
        Write-NextPointError -Message "Failed to set view to: $View" -Exception $_
        throw
    }
}

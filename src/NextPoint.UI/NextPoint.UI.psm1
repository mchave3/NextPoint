#Requires -Version 5.1
#Requires -Modules @{ ModuleName="NextPoint.Core"; ModuleVersion="1.0.0" }
#Requires -Modules @{ ModuleName="NextPoint.Common"; ModuleVersion="1.0.0" }

# Import functions
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName

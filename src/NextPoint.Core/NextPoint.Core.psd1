@{
    ModuleVersion = '0.1.0'
    GUID = 'nouveau-GUID-ici'  # Utiliser New-Guid pour générer
    Author = 'Votre Nom'
    Description = 'Core module for NextPoint management tool'
    PowerShellVersion = '5.1'
    RequiredModules = @()
    FunctionsToExport = @('*')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('MECM', 'Intune', 'Management')
            ProjectUri = 'https://github.com/votre-repo/NextPoint'
        }
    }
}

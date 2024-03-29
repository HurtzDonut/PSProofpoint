@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSCredMan.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.1.0'
    
    # Supported PSEditions
    # CompatiblePSEditions = @()
    
    # ID used to uniquely identify this module
    GUID = '2f5d9f13-7161-4b72-8afc-1cf0ea45fff6'
    
    # Author of this module
    Author = 'Jim Harrison (Original) ; HurtzDonut (Modified)'

    # Link to Original CredMan.ps1
    # https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Credentials-d44c3cde
    
    # Company or vendor of this module
    CompanyName = ''
    
    # Copyright statement for this module
    Copyright = ''
    
    # Description of the functionality provided by this module
    Description = 'Provides access to the Win32 Credential Manager API used for management of stored credentials.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '2.0'
    
    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Get-StoredCred','Remove-StoredCred','Save-Credential','ConvertTo-PSCredential')
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    # VariablesToExport = @()
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    FileList = @(
        # Root Files
            "$PSScriptRoot\PSCredMan.psm1",
            "$PSScriptRoot\PSCredMan.psd1",
            "$PSScriptRoot\PSUtils_CredMan.dll",
        # Public (Exported\Main Functions)
            "$PSScriptRoot\Public\Get-StoredCred.ps1",
            "$PSScriptRoot\Public\Remove-StoredCred.ps1",
            "$PSScriptRoot\Public\Save-Credential.ps1",
            "$PSScriptRoot\Public\ConvertTo-PSCredential.ps1",
        # Private (Non-Exported\Supporting Functions)
            "$PSScriptRoot\Private\Get-CredPersist.ps1",
            "$PSScriptRoot\Private\Get-CredType.ps1",
            "$PSScriptRoot\Private\Invoke-ErrRcd.ps1",
            "$PSScriptRoot\Private\PSUtils_CredMan.cs"
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            # ProjectUri = ''
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
        } # End of PSData hashtable
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''    
}
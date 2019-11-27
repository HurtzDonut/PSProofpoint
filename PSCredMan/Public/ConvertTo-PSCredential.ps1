<#
    .SYNOPSIS
        Converts a string username and password to a PS Credential Object
    .EXAMPLE
        PS C:\> $CredFromStore = Get-StoredCred -Target <UserName> | ConvertTo-PSCredential
        PS C:\> $CredFromStore

        UserName                       Password
        --------                       --------
        <UserName> System.Security.SecureString


        PS C:\> $CredFromStore.GetType()

        IsPublic IsSerial Name                                     BaseType
        -------- -------- ----                                     --------
        True     True     PSCredential                             System.Object
        

        Retrieves an entry from the Windows Credential manager using Get-StoredCred, then converts the credential into a PsCredential object.
    .INPUTS
        System.String
        System.String
    .OUTPUTS
        System.Management.Automation.PSCredential
    .NOTES
        Author:     HurtzDonut01
        Created:    03/04/2019
        Version:    1.0
#>
Function ConvertTo-PSCredential {
    [CmdLetBinding()]
    [Alias('ctcred')]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
            [String]$UserName,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('CredentialBlob')]
            [String]$Password
    )

    Process {
        [System.Management.Automation.PSCredential]::New($UserName,($Password | ConvertTo-SecureString -AsPlainText -Force))
    }
}
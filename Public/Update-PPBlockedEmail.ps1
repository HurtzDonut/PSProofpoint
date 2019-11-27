<#
    .SYNOPSIS
        Preforms specified action on a given message within Proofpoint.
    .DESCRIPTION
        Long description
    .PARAMETER Action
        Specifies the action to be taken on the specified message.
    .PARAMETER folder
        Name of the containment folder in which the message is contained
    .PARAMETER localguid
        Proofpoint's local uinque message identifier
    .EXAMPLE
        PS C:\> Get-PPBlockedEmail -Sender gmail.com -Recipient Hurtz.Donut -Subject '2017 Tax Information'| Update-PPBlockedEmail -Action release
        
        Finds a single blocked message with the following:
            Sender email contains 'gmail.com'
            Recpient email contains 'Hurtz.Donut'
            Email subject contains '2017 Tax Information'

        Then sends a release request to Proofpoint for the message.
    .INPUTS
        System.String
    .OUTPUTS
        PSCustomObject
    .NOTES
        Author:     Hurtz Donut
        Created:    01/10/2019
        Modified:   11/27/2019
#>
Function Update-PPBlockedEmail {
    [CmdLetBinding()]
    Param(
        [Parameter()]
        [ValidateSet('release','resubmit','forward','move','delete')]
            [String]$Action = 'release',

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
            [String]$folder,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
            [String]$localguid
    )

    Process {
        If ($Action -ne 'release') {
            Write-Warning 'Currently the only supported action is [release]. Other actions will be added in the future.'
            Break
        }

        # Base Uri
        $Uri = $Script:BaseUrl
        
        # Get API account credentials from local Credential Manager
        $ApiCredentials = Get-StoredCred -Target $Script:APIAccount

        # Request fields
        $PostBody = [ordered]@{
            localguid   = $localguid
            folder      = $folder
            action      = $Action.ToLower()
        }

        If ($PostBody.action -eq 'release') {
            Switch -Regex ($Folder) {
                '^FFB'      {[Void]$PostBody.Add('deletedfolder','Deleted')}
                '^(SSN|PCI)'{[Void]$PostBody.Add('deletedfolder','Deleted Incidents')}
                '^Deleted(|\sIncidents)$' {
                    Write-Warning 'Message has already been released!!'
                    Break
                }
            }
        }

        # Define web request headers
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ApiCredentials.UserName, $ApiCredentials.CredentialBlob)))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/json')
        
        # Send Request
        $data   = Invoke-WebRequest -Headers $headers -Method 'POST' -Uri $uri -Body ($PostBody | ConvertTo-Json) -ContentType 'application/json'
        
        # Display results
        [PSCustomObject][Ordered]@{
            StatusCode          = $Data.StatusCode
            StatusDescription   = $Data.StatusDescription
            Message             = $Data.Content
        }
    } # Process Block
} # Function Update-PPBlockedEmail
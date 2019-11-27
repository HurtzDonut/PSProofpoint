<#
    .SYNOPSIS
        Searches Proofpoint to identify any blocked emails identified by $MsgSender/$MsgRecipient/$MsgSubject & $DaysToSearch. 
    .DESCRIPTION
        Uses Proofpoint's Public API (Rev E) to locate any messages that have been blocked.
    .PARAMETER MsgSender
        Full/partial email address for the sender of the blocked message.
    .PARAMETER MsgRecipient
        Full/partial email address for the recipient of the blocked message.
    .PARAMETER MsgSubject
        Full/partial subject of the blocked message.
    .PARAMETER Folder
        Containment folder to search. Useful if looking for a specific message.
    .PARAMETER DaysToSearch
        Number of days back to search for a blocked message(s).
    .PARAMETER AllFolders
        Specifes to search for blocked messages in any of the possible containment folders.
    .PARAMETER LargeRequest
        Adjusts the Web request timeout from 60 seconds (Default) to 10 minutes, for requests that may have a large number of items returned.
    .EXAMPLE
        PS C:\> Get-PPBlockedEmail -Recipient Hurtz.Donut -DaysToSearch 14 -LargeRequest

        Looks through all possible containment folders for the following:
            Message recipient contains 'Hurtz.Donut'
            Message age is within the last 14 days (336 hours)

        Since there may be a large number of items returned, adjust the web request timeout to accomodate
    .EXAMPLE
        PS C:\> Get-PPBlockedEmail -Recipient Hurtz.Donut -Folder 'FFB Protected Files' -Subject '2017 Tax Documents'

        Looks through the containment folder [FFB Protected Files] for the following:
            Message recipient contains 'Hurtz.Donut'
            Message age is within the last 1 day (24 hours)
            Message subject contains '2017 Tax Documents'
    .EXAMPLE
        PS C:\> Get-PPBlockedEmail -Recipient bankatfirst.com

        Looks through all possible containment folders for the following:
            Message recipient contains 'bankatfirst.com'
            Message age is within the last 1 day (24 hours)
    .INPUTS
        System.String
    .OUTPUTS
        PSCustomObject
    .NOTES
        Author:     Hurtz Donut
        Created:    01/10/2019
        Modified:   11/27/2019
#>
Function Get-PPBlockedEmail {
    [CmdLetBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='All')]
        [Alias('Sender')]
        [ValidateNotNullOrEmpty()]
            [String]$MsgSender,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='All')]
        [Alias('Recipient')]
        [ValidateNotNullOrEmpty()]
            [String]$MsgRecipient,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='All')]
        [ValidateNotNullOrEmpty()]
        [Alias('Subject')]
            [String]$MsgSubject,

        [Parameter(ParameterSetName='One')]
        [ValidateSet(
            # Normal Quarantine Folders
            'Adult','Attachment Defense','Audit','Blocked','Bounce Management',
            'Bulk','Deleted','Impostor','Malware','Phish','Probable Virus','Quarantine',
            'Smart Send','Smart Send Released','Spoofed','Suspected Spam','Untrusted Senders',
            'Virus','Zerohour',
            # DLP Quarantine Folders
            'Asset','Deleted Incidents','EncryptionProxy','GLBA','HIPAA',
            'PCI','Regulation','Smart Send DLP','Smart Send DLP Released',
            'SSN High Probability','SSN Low Probability','SSN Med Probability',
            'SSN subject'
        )]
            [String]$Folder,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='All')]
        [ValidateRange(1,14)]
            [Int]$DaysToSearch = 1,

        [Parameter(ParameterSetName='All')]
            [Switch]$AllFolders,
         
        [Parameter(ParameterSetName='All')]
            [Switch]$ExcludeReleased,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='All')]
            [Switch]$LargeRequest
    )

    Process {
        # Verify that at least one of Sender/Recipient/Subject was specified
        If (!$PSBoundParameters['MsgSender'] -and !$PSBoundParameters['MsgRecipient'] -and !$PSBoundParameters['MsgSubject']) {
            Write-Warning "You MUST specify one of the following parameters: Sender, Recipient, Subject"
            Return
        }
        
        # Get 'apiaccount' credentials from local Credential Manager
        $ApiCredentials = Get-StoredCred -Target $Script:APIAccount
        If ($Null -eq $ApiCredentials.CredentialBlob) {
            Write-Warning "API Account Credentials are empty!"
            Write-Host "WARNING: Please run [" -ForegroundColor Yellow -NoNewline
                Write-Host "Save-Credential -UserName <String> -Password <String>" -ForegroundColor Cyan -NoNewline
                Write-Host "], then try again!" -ForegroundColor Yellow
            Break
        }

        # Define web request Headers
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ApiCredentials.UserName, $ApiCredentials.CredentialBlob)))
        $Headers        = [System.Collections.Generic.Dictionary[[String],[String]]]::New()
        $Headers.Add('Authorization',('Basic {0}' -F $Base64AuthInfo))
        $Headers.Add('Accept','application/json')

        # Define 'startdate' request field in the required format
        $StartDate = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-$DaysToSearch).ToString('yyyy-MM-dd HH:mm:ss')

        Switch ($PSCmdLet.ParameterSetName) {
            'All' { 
                $SearchFolder = [System.Collections.ArrayList]::New()
                # Return all the ValidateSet options for the parameter $Folder
                (Get-Variable -Name 'Folder').Attributes.ValidValues | ForEach-Object {[Void]$SearchFolder.Add($PSItem)}
            }
            'One' { $SearchFolder = $Folder }
        }

        If ($ExcludeReleased) {
            $SearchFolder.Remove('Deleted')
            $SearchFolder.Remove('Deleted Incidents')
        }

        # Build query
        $QueryInfo = [Ordered]@{ startdate = $StartDate }

        If ($PSBoundParameters['MsgSender'])   { [Void]$QueryInfo.Add('from',('*{0}*' -F $MsgSender)) }
        If ($PSBoundParameters['MsgRecipient']){ [Void]$QueryInfo.Add('rcpt',('{0}' -F $MsgRecipient)) }
        If ($PSBoundParameters['MsgSubject'])  { [Void]$QueryInfo.Add('subject',('*{0}*' -F $MsgSubject)) }
        
        ForEach ($Container in $SearchFolder) {
            # Base Uri
            $Uri = ('{0}?folder={1}' -F $Script:BaseUrl,$Container.ToLower())

            # Add Query fields to Uri
            ForEach ($Field in $QueryInfo.Keys) {
                $Uri = $Uri,"&$Field=$($QueryInfo.$Field)" -Join ''
            }
            
            $InvokeWebSplat = @{
                Headers     = $Headers
                Method      = 'GET'
                Uri         = $Uri
                TimeOutSec  = 60
            }

            If ($PSBoundParameters['LargeRequest']) {
                # 600000ms/600s == 10min
                # ^ Used to accommodate large volume requests
                [System.Net.ServicePointManager]::MaxServicePointIdleTime = 600000
                $InvokeWebSplat['TimeOutSec'] = 600
            } Else {
                # 60000ms == 1min
                [System.Net.ServicePointManager]::MaxServicePointIdleTime = 60000
            }

            # Retrieve Data
            $data   = Invoke-WebRequest @InvokeWebSplat
            $results= $data.Content | ConvertFrom-Json
            Write-Verbose ('[STATUS] : {0}' -F $Data.StatusCode)
            Write-Verbose ('[LIMIT]  : {0}' -f $Results.Meta.Limit)

            If ($results.count -gt 0) {
                ForEach ($r in $Results.records){
                    # Determine if message size should be displayed as KB or MB
                    Switch ([Decimal]::Round($r.size/1MB,2)) {
                        {$PSItem -lt 1.0} {$Size = [Decimal]::Round($r.size/1KB,2);$Unit = 'KB'}
                        {$PSItem -ge 1.0} {$Size = [Decimal]::Round($r.size/1MB,2);$Unit = 'MB'}
                    }

                    $rcptsString =  If ($r.rcpts.Count -gt 1) {
                        ($r | Select-Object -ExpandProperty rcpts) -Join ','
                    } Else {
                        $r | Select-Object -ExpandProperty rcpts
                    }

                    # Display results
                    [PSCustomObject][ordered]@{
                        size        = $Size
                        size_unit   = $Unit
                        from        = $r.from
                        rcpts       = $rcptsString
                        subject     = $r.subject
                        date_utc    = $r.date
                        date_est    = (Get-Date -Date $r.date).AddHours(-5)
                        localguid   = $r.localguid
                        folder      = $r.folder
                    }
                } # Results Loop
            } # Results > 0
        } # SearchFolder Loop
    } # Process Block
} # Function Get-PPBlockedEmail
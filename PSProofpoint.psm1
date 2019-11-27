#region Script scope variables
$Script:Public              = Join-Path -Path $PSScriptRoot -ChildPath Public
$Script:Private             = Join-Path -Path $PSScriptRoot -ChildPath Private
$Script:SettingsFile        = Join-Path -Path $Script:Private -ChildPath 'Settings.json'
$Script:Settings            = ConvertFrom-Json (Get-Content -Path $Script:SettingsFile -Raw)
$Script:BaseURL             = $Script:Settings.PSConfig.BaseUrl
$Script:APIAccount          = $Script:Settings.PSConfig.ApiAccount
#endregion Script scope variables

#region Dot Source Module Files
$PublicFil                  = @( Get-ChildItem -Path $Script:Public\*.ps1 -ErrorAction SilentlyContinue )
$PrivateFil                 = @( Get-ChildItem -Path $Script:Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
ForEach ($Import in @($PublicFil + $PrivateFil)) {
    Try {
        . $Import.FullName
    } Catch {
        Write-Warning -Message ('Failed to Import function {0}: {1}' -F $Import.FullName,$PSItem)
    }
}

Export-ModuleMember -Function $PublicFil.Basename
#endregion DotSource Module Files
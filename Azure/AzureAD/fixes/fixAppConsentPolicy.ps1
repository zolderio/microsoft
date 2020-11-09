#predefined permissions
$expectedPermissions = ('User.Read', 'email', 'openid','profile','offline_access')

#set user consent to the new policy
Set-AzureADMSAuthorizationPolicy -Id "authorizationPolicy"  -PermissionGrantPolicyIdsAssignedToDefaultUserRole @("managePermissionGrantsForSelf.microsoft-user-default-low")

#disable group-consent 
$consentSettingsTemplateId = "dffd5d46-495d-40a9-8e21-954ff55e198a" # Consent Policy Settings
$groupsettings = Get-AzureADDirectorySetting -All $true | Where-Object { $_.TemplateId -eq $consentSettingsTemplateId }

if (-not $groupsettings) {
    $template = Get-AzureADDirectorySettingTemplate -Id $consentSettingsTemplateId
    $settings = $template.CreateDirectorySetting()
}

$EnableGroupSpecificConsent = $groupsettings.Values | ? { $_.Name -eq "EnableGroupSpecificConsent" }
$EnableGroupSpecificConsent.Value = "false"
if ($groupsettings.Id) {
    Set-AzureADDirectorySetting -Id $groupsettings.Id -DirectorySetting $groupsettings
}

#set riskbased consent to True
$riskBasedConsentEnabledValue = $groupsettings.Values | ? { $_.Name -eq "BlockUserConsentForRiskyApps" }
$riskBasedConsentEnabledValue.Value = "True"
if ($groupsettings.Id) {
    Set-AzureADDirectorySetting -Id $groupsettings.Id -DirectorySetting $groupsettings
}

#set user permissions
$api = Get-AzureADServicePrincipal -Filter "servicePrincipalNames/any(n:n eq 'https://graph.microsoft.com')"
$classifications = Get-AzureADMSServicePrincipalDelegatedPermissionClassification -ServicePrincipalId $api.ObjectId
$actualPermissions = $classifications | select -ExpandProperty PermissionName 
$difference =  $expectedPermissions | where {$actualPermissions -notcontains $_}
foreach($permission in $difference){
    $delegatedPermission = $api.OAuth2Permissions | Where-Object { $_.Value -eq $permission }
    Add-AzureADMSServicePrincipalDelegatedPermissionClassification -ServicePrincipalId $api.ObjectId -PermissionId $delegatedPermission.Id -PermissionName $delegatedPermission.Value -Classification "low"
}
Write-Host "Modified App Consent Policy settings, run checkAppconsentPolicy.ps1 to verify"
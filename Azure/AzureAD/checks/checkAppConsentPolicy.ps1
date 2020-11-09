#predefined permissions
$expectedPermissions = ('User.Read', 'email', 'openid','profile','offline_access')

#get user-settings
$usersettings = Get-AzureADMSAuthorizationPolicy  -Id "authorizationPolicy"
$consentSettingsTemplateId = "dffd5d46-495d-40a9-8e21-954ff55e198a" # Consent Policy Settings

#get group-settings
$groupsettings = Get-AzureADDirectorySetting -All $true | Where-Object { $_.TemplateId -eq $consentSettingsTemplateId }
$EnableGroupSpecificConsent = $groupsettings.Values | ? { $_.Name -eq "EnableGroupSpecificConsent" }

#get BlockUserConsentRiskyApps
$riskBasedConsentEnabledValue = $groupsettings.Values | ? { $_.Name -eq "BlockUserConsentForRiskyApps" }

#get user-permissions
$expectedPermissions = ('User.Read', 'email', 'openid','profile','offline_access')
$api = Get-AzureADServicePrincipal  -Filter "servicePrincipalNames/any(n:n eq 'https://graph.microsoft.com')"
$classifications = Get-AzureADMSServicePrincipalDelegatedPermissionClassification -ServicePrincipalId $api.ObjectId
$actualPermissions = $classifications | select -ExpandProperty PermissionName 

#determine difference between set and gotten permissions.
$differenceL =  $expectedPermissions | where {$actualPermissions -notcontains $_}
$differenceR = $actualPermissions | where {$expectedPermissions -notcontains $_}

#combine results
$a =  @{
    PermissionGrantPolicyIdsAssignedToDefaultUserRole = $usersettings.PermissionGrantPolicyIdsAssignedToDefaultUserRole
    EnableGroupSpecificConsent = $EnableGroupSpecificConsent.Value
    UserPermissions = $actualPermissions
    riskBasedConsentEnabledValue = $riskBasedConsentEnabledValue.Value 
    MissingPermissions = $differenceL
    ExtraPermissions = $differenceR
}

if (($usersettings.PermissionGrantPolicyIdsAssignedToDefaultUserRole -ne "microsoft-user-default-low") -or ($EnableGroupSpecificConsent.Value -eq "true") -or ($differenceR) -or ($differenceL)) {

    Write-Host "Settings not matching our expectation"
}else{
    Write-Host "Settings correct."
}
$a
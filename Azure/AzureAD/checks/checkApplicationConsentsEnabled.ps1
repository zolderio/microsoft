$enabled = Get-MsolCompanyInformation | select UsersPermissionToUserConsentToAppEnabled

if ($enabled) {
    Write-Host "TRUE: Users are allowed to consent to applications."
} else {
    Write-Host "FALSE: Users are NOT allowed to consent to applications."
}
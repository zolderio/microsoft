$enabled = Get-MsolCompanyInformation | select UsersPermissionToCreateLOBAppsEnabled

if ($enabled) {
    Write-Host "TRUE: Users are allowed to register applications."
} else {
    Write-Host "FALSE: Users are NOT allowed to register applications."
}
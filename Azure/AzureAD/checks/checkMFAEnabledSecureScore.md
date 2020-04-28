# Creating the application to query SecureScore:

1) Log into your tenant with the required privileges
2) Navigate to https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps
3) New registration. Give it a name, set required properties
4) After creation go to API permissions and assign SecurityEvents.Read.All
5) Go to certificates & secrets and create secrets to logon into the app
6) Modify checkMFAEnabledSecureScore.py settings with the app id, secret and tenant ID
7) Run the script


$name = Read-Host -Prompt 'What is the keyvault supposed to be called?' 
az monitor log-analytics workspace list --query '[].{NAME:name, ResourceGroup:resourceGroup, ID:id}'
$analyticsworkspaceid = Read-Host -Prompt 'Paste the ID of the Sentinel Log analytics workspace we need to log to' 


$keyvault = $name + "KV"
$resourceGroup = $name + "RG"
$servicePrincipal = $name + "SP"
$diagnosticsettings = $name + "DIAG"

## Create resource group
az group create -l westus -n $resourceGroup


## create KeyVault 

$raw = az keyvault create --name $keyvault -g $resourceGroup
$kv = $raw | ConvertFrom-Json

## create service principal

$creds = az ad sp create-for-rbac --name http://$servicePrincipal --skip-assignment
$json = $creds | ConvertFrom-Json
$spn = $json.appId

#give service princple access to keyvault
az keyvault set-policy -n $keyvault --spn $spn --secret-permissions delete get list set --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey

## log all audit events to sentinel
$logSettings="[{'category': 'AuditEvent','enabled': true}]".Replace("'",'\"')
az monitor diagnostic-settings create --name  $diagnosticsettings --resource $kv.id --logs  $logSettings --workspace $analyticsworkspaceid

##  some secrets to spread around

Write-Host "################## So now we can spread our tokens: ##################"
Write-Host "ClientId: " + $json.appId
Write-Host "Secret: " + $json.password
Write-Host "tenant id " + $json.tenant
Write-Host "Vault URL: " + $kv.properties.vaultUri
Write-Host "#######################################################################################"


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

Write-Host "[*]Printing the tokens:" -ForeGroundColor yellow
Write-Host "ClientId: " -NoNewline
Write-Host  $json.appId -ForeGroundColor RED
Write-Host "Secret: " -NoNewline
Write-Host  $json.password -ForeGroundColor RED
Write-Host "TenantID:" -NoNewline
Write-Host $json.tenant -ForeGroundColor RED
Write-Host "Vault URL: " -NoNewline
Write-Host $kv.properties.vaultUri -ForeGroundColor RED
Write-Host ""

## What to look for:

Write-Host "[*]Generating the KQL queries to detect token usage" -ForeGroundColor yellow
Write-Host "Someone using our keyvault: "
Write-Host @"
AzureDiagnostics 
| where ResourceType  == "VAULTS"
| where Resource  == "$keyvault"
| where OperationName  in ("SecretGet","Authentication", "SecretList")
| order by TimeGenerated desc
"@ -ForeGroundColor blue
Write-Host ""
Write-Host "Someone logging into AzureAD with our Service Principal (make sure to enable service principal signins):"
Write-Host @"
AADServicePrincipalSignInLogs
| where ServicePrincipalName == "$servicePrincipal"
"@ -ForeGroundColor blue


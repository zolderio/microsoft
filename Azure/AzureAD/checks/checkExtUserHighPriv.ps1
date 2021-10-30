# Excerpt from our Attic check. 
# Gets assigned roles within the tenant. For each role we check if there are members that are guests.


try{
    $roles = Get-MsolRole
    $results = @{}

    foreach($role in $roles) {
        $conf=Get-MsolRoleMember -All -RoleObjectId $role.ObjectId -TenantId $tenantID | Where-Object EmailAddress -match "#EXT#"
        if($null -ne $conf) {
            $results[$role.Name] = @($conf | Select-Object DisplayName, EmailAddress)
        }
    }

    #check if the result is as expected and set the result state
    if($results.Count -ne 0){
      Write-Host "Found the following external users with admin roles assigned:"
      $results | ft 
    }else{
      Write-Host "No guest users with admin roles found."
    }
}catch{
  Write-Host "oops: "
  Write-Host $_
}

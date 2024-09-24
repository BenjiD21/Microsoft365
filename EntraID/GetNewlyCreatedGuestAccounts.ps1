# Connect to Graph

# Create the ArrayList that should later be exported
$exportTable = New-Object System.Collections.ArrayList

# Get a list of all Roles and the corresponding users
$roles = Get-MgRoleManagementDirectoryRoleDefinition

foreach ($role in $roles)
{
  $roleObjectGet = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"
  
  #Get Username from PrincipalID parameter
  if ($roleObjectGet -ne $null) {
    $userPrincipal = Get-MgUser -UserID roleObjectGet.principalID
    $userPrincipal.UserPrincipalName
  }

  #Get Rolename from roleDefinitionID parameter
  if ($roleObjectGet -ne $null) {
    $roleName = get-mgdirectoryrole -Filter "RoleTemplateId eq '$roleObjectGet.RoleDefinitionId'"
    $roleName.DisplayName
  }

  $exportTable.add($roleObjectGet)
}

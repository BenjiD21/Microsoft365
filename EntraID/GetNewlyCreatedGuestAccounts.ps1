# Connect to Graph
Connect-MgGraph -Scopes "Directory.Read.All"

# Create the ArrayList that should later be exported
$exportTable = New-Object System.Collections.ArrayList

# Get a list of all Roles and the corresponding users
$roles = Get-MgRoleManagementDirectoryRoleDefinition

foreach ($role in $roles)
{
  $roleObjectGet = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"
  
  #Get Username from PrincipalID parameter
  if ($roleObjectGet.PrincipalId) {
        
    #check if the variable contains more than one PrincipalId
    if($roleObjectGet.PrincipalId.Count) {
        
        #if it does - make it an array by splitting " "
        try {
            $roleObjectGetArray = $roleObjectGet.PrincipalId -split " "

            #Work through the array and get the corresponding user as well as role
            $roleObjectGetArray | ForEach-Object {

                #Check if the Object is a user or service principal <- creates Exception if there is a GDAP role group assignment FIX
                $directoryObject = Get-MgDirectoryObject -DirectoryObjectId $_

                if ($directoryObject.additionalproperties.("@odata.type") -eq "#microsoft.graph.servicePrincipal") {
                    $principal = $directoryObject.additionalproperties.displayName
                    $principal

                    $roleName = $role.DisplayName
                    $roleName
                } elseif ($directoryObject.additionalproperties.("@odata.type") -eq "#microsoft.graph.user") {
                    $userPrincipalName = $directoryObject.additionalproperties.userPrincipalName
                    $userPrincipalName

                    $roleName = $role.DisplayName
                    $roleName
                } elseif ($directoryObject.additionalproperties.("@odata.type") -eq "#microsoft.graph.group") {
                    $principal = $directoryObject.additionalproperties.displayName
                    $principal

                    $roleName = $role.DisplayName
                    $roleName
                }

            }
        } catch [System.Exception] {
            Write-Output("Unbekannter Objekttyp")
        }
        
    } else {

        #If there is only one user assigned to the role, do the same as above
        $userPrincipal = Get-MgUser -UserID "$($roleObjectGet.PrincipalId)"
        $userPrincipal.UserPrincipalName

        $roleName = $role.DisplayName
        $roleName
    }

  }

  #Set the $userprincipal to $null again
  $userPrincipal = $null

  $exportTable.add($roleObjectGet)
}

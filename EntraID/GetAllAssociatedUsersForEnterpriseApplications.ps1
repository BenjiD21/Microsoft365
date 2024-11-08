<#
.SYNOPSIS
Retrieves a list of all Enterprise Applications in Entra ID (Azure AD) along with their associated users.

.DESCRIPTION
This script connects to Entra ID (Azure AD) and gathers a list of all Enterprise Applications (service principals).
For each application, it retrieves the users assigned to that application. The resulting data is exported to a CSV file.

.PREREQUISITES
- AzureAD PowerShell Module must be installed.
- User running the script must have appropriate permissions in Azure AD to retrieve service principal and role assignment information.

.REQUIREMENTS
- Ensure you have the AzureAD PowerShell module installed and imported.
- The script should be executed with appropriate Azure AD permissions.

.OUTPUTS
- Exports the results to a CSV file located at C:\temp\AppUsers.csv (path can be modified as needed).

.AUTHOR
Benjamin Daur/audius

.VERSION
1.0 - Initial release

.NOTES
- Be sure to update the file path in the Export-Csv cmdlet if needed.
#>

#Connect to EntraID
Connect-AzureAD

#Get all service principals
$serviceprincipals = Get-AzureADServicePrincipal -All:true

#Get all associated users for each service principal
$results = foreach ($service in $serviceprincipals) {Get-AzureADServiceAppRoleAssignment -ObjectId $service.id | Select ResourceDisplayName,PrincipalDisplayName}

#Store the results in a CSV-file. Change the path attribute according to your needs
$results | Export-Csv -Path "C:\temp\AppUsers.csv" -NoTypeInformation

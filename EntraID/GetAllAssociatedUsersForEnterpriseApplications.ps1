#This script gets a list of all Enterprise Applications in Entra ID and then gets all associated users
#Prerequisites: AzureAD Module

#Connect to EntraID
Connect-AzureAD

#Get all service principals
$serviceprincipals = Get-AzureADServicePrincipal -All:true

#Get all associated users for each service principal
$results = foreach ($service in $serviceprincipals) {Get-AzureADServiceAppRoleAssignment -ObjectId $service.id | Select ResourceDisplayName,PrincipalDisplayName}

#Store the results in a CSV-file. Change the path attribute according to your needs
$results | Export-Csv -Path C://temp/AppUsers.csv -NoTypeInformation

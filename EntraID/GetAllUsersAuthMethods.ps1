<#
.SYNOPSIS
Retrieves a list of all users' authentication methods in ENtra ID and exports the results to a CSV file.

.DESCRIPTION
This script connects to Microsoft Online Services (MSOL) and gathers the UserPrincipalName (UPN) and associated strong authentication methods for all users.
If a user has no authentication method, the corresponding entry will be left empty in the export. The data is then saved in a specified CSV file.

.PREREQUISITES
- The MSOL (Microsoft Online) PowerShell Module must be installed.
- The user running the script must have sufficient privileges to access MSOL user information.

.REQUIREMENTS
- Update the `%FILEPATH%` variable with the full path where you want the CSV file to be saved.
- Ensure that you sign in with a privileged account when prompted.

.OUTPUTS
- Exports the list of users and their authentication methods to a CSV file at the path specified by `%FILEPATH%.csv`.

.AUTHOR
Benjamin Daur/audius

.VERSION
1.0 - Initial release

.NOTES
- Be sure to update `%FILEPATH%` in the Export-Csv cmdlet with the desired file path for the output.
- The MSOL session is cleared at the end of the script to maintain security.
#>

# Connect to MSOL - you will have to sign in using a privileged account
Connect-MsolService

# Get a list of all user's UPNs and authenticationmethods
$UserList = Get-MsolUser -All | Select UserPrincipalName, StrongAuthenticationMethods

# Prepare the Hashtable needed for the export
$UserExport = @{}

# For each user in the UserList check if it has an authentication method set up
# If it has not: add the user to the Hashtable with an empty value
# If it has: add the user to the Hashtable with it's respective authentication methods
$UserList | Foreach-Object {

    if ($_.StrongAuthenticationMethods.count -eq 0) {
        $UserExport.Add($_.UserPrincipalName,"")
    } else {

        # Create the string varibale used to collect all auth methods
        $StringVal = ""

        # Collect all auth methods
        foreach($authmethod in $_.StrongAuthenticationMethods) {
            $StringVal += $authmethod.MethodType
            $StringVal += ","
        }

        $UserExport.Add($_.UserPrincipalName,$StringVal)

    }

}

# Export the list to the given %FILEPATH%
$UserExport.getEnumerator() | Select-Object -Property Key,Value | Export-CSV -Path "%FILEPATH%.csv" -NoTypeInformation

# Close the MSOL session
[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()

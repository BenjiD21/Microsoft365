## Get a list of all user's authentication methods

## ToDo's:
## 1) Set the %FILEPATH% variable for your csv-file

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

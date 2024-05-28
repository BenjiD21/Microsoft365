# Connect to the Tenant
# Use Admin Credentials of the desired Tenant

Connect-AzureAD

# Get all users inside the Group that is specified by an Object ID
# Fill in required ObjectId

$users = Get-AzureADGroup -ObjectId "%INSERTOBJECTID%" | Get-AzureADGroupMember -All $true

# For each user in the specified group - revoke all refresh tokens

foreach ($user in $users)
{
	$userId = $user.objectid
	Revoke-AzureADUserAllRefreshToken -ObjectId $userID
}

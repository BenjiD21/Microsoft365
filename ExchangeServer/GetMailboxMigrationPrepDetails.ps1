<#
.SYNOPSIS
Retrieves information for mailbox analysis to determine migration eligibility to Exchange Online (EXO).

.DESCRIPTION
This script collects data on mailboxes in an Exchange Server environment. It includes mailbox details, 
such as item count, mailbox size, last logon time, and user status, to help decide if the mailbox will be migrated.

.REQUIREMENTS
Must be run on an Exchange Server within the cluster with the necessary permissions to access Active Directory and mailbox statistics.

.OUTPUTS
- Exports results to CSV (C:\temp\MailboxMigrationPrepDetails.csv).

.AUTHOR
Benjamin Daur/audius

.VERSION
1.0 - Initial release
#>

# Create an empty Array used for the Output
$Result=@()

# Get all mailboxes located in the Exchange environment
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Get the necessary details for each mailbox
$mailboxes | Foreach-Object {

# Get the GUID of the mailbox
$mailboxGuid = $_.ExchangeGuid.Guid

# Transform the mailbox GUID
$guidBytes = [GUID]::Parse($mailboxGuid).ToByteArray()
 
# Get the Enabled status for the user conected to the mailbox	
$userEnabled = Get-ADUser -Filter { msExchMailboxGuid -eq $guidBytes } | Select Enabled

$userMail = Get-ADUser -Filter { msExchMailboxGuid -eq $guidBytes } -Properties Mail | Select Mail

# Get the attributes DisplayName, ItemCount, MessageTableTotalSize und LastLogonTime der Mailbox
$mailboxAttributes = $_ | Get-Mailboxstatistics | Select DisplayName, ItemCount, MessageTableTotalSize, LastLogonTime

# Create a new Object per mailbox. Save the gathered information inside the object. Add the object to the array.
$Result += New-Object PSObject -property @{

	DisplayName = $mailboxAttributes.DisplayName

	Mail = $userMail.Mail
		
	Enabled = $userEnabled.Enabled

	ItemCount = $mailboxAttributes.ItemCount
		
	MailboxSize = $mailboxAttributes.MessageTableTotalSize
		
	LastLogonTime = $mailboxAttributes.LastLogonTime
		
	WhenChanged = $_.whenChanged

	RecipientTypeDetails = $_.RecipientTypeDetails

	MailboxGuid = $_.ExchangeGuid }

}

# Export the Result in a CSV file
$Result | Export-CSV -Path "C:\temp\MailboxMigrationPrepDetails.csv" -NoTypeInformation

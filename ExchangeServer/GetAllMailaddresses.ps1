<#
.SYNOPSIS
Retrieves a list of all recipients and their associated email addresses in the Exchange environment, then exports the information to a CSV file.

.DESCRIPTION
This script retrieves all recipient objects using the `Get-Recipient` cmdlet and extracts key properties, including the primary SMTP address, display name, recipient type, Exchange GUID, and the count and list of email addresses.
The data is organized into an output array and saved to a CSV file for reporting purposes.

.PREREQUISITES
- This script requires permissions to access recipient data in the Exchange environment.
- The script should be run in a PowerShell session with access to the Exchange cmdlets.

.OUTPUTS
- The resulting CSV file (`AllMailaddresses.csv`) will contain the following columns:
  - DisplayName
  - PrimarySmtpAddress
  - RecipientTypeDetails
  - ExchangeGuid
  - MailaddressCount
  - MailaddressString (a comma-separated list of all email addresses associated with the recipient)

.PARAMETER OutputFilePath
- `OutputFilePath` is the full path where the CSV file will be saved. Default is "C:\temp\AllMailaddresses.csv".

.AUTHOR
Benjamin Daur/audius

.VERSION
1.0 - Initial release

.NOTES
- Ensure that the specified file path for the output CSV file exists or modify it as needed.
#>

# Create an empty Array used for the Output
$result = @()

# Get all Recipients
$mailadressList = Get-Recipient -ResultSize Unlimited

# For each recipient, add the data to an object and add said object to the output array
$mailadressList | ForEach-Object {

	# Get all standard properties
	$primarySmtpAddress = $_.primarysmtpaddress.Address
	$displayName = $_.displayName
	$recipientTypeDetails = $_.recipientTypeDetails
	$exchangeGuid = $_.exchangeGuid.guid
	
	# Get the number of mailaddresses connected to the recipient
	$mailaddressCount = $_.emailAddresses.Count
	
	# Create an empty String to store the mailaddresses
	$mailaddressString = ""
	
	# Add each mailaddress for the recipient to the mailaddresses string
	$mailaddresses = $_.emailAddresses
	
	ForEach ($mailaddress in $mailaddresses) {
		$mailaddressString += $mailaddress.addressString
		$mailaddressString += ","
	}
	
	# Create an object to store the information and append it to the result array
	$obj = New-Object PSObject
	$obj | Add-Member NoteProperty displayName($displayName)
	$obj | Add-Member NoteProperty primarySmtpAddress($primarySmtpAddress)
	$obj | Add-Member NoteProperty recipientTypeDetails($recipientTypeDetails)
	$obj | Add-Member NoteProperty exchangeGuid($exchangeGuid)
	$obj | Add-Member NoteProperty mailaddressCount($mailaddressCount)
	$obj | Add-Member NoteProperty mailaddressString($mailaddressString)
	
	$result += $obj
	
}

# Create a csv file for the output
$result | Export-CSV -Path "C:\temp\AllMailaddresses.csv" -NoTypeInformation

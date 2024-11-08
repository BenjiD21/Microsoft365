<#
.SYNOPSIS
Retrieves information about unused accepted domains on an Exchange Server.

.DESCRIPTION
This script gathers information on accepted domains and checks if they are used in any mailboxes, distribution groups, or contacts.
Outputs a report indicating whether each domain is in use.

.REQUIREMENTS
Must be run on an Exchange Server within the cluster.

.OUTPUTS
- Displays output in the console in table format.
- Exports results to CSV (C:\temp\UnusedAcceptedDomains.csv).

.AUTHOR
Benjamin Daur/audius

.VERSION
1.0 - Initial release
#>

# Collect all mailboxes, distribution groups, and contacts
$mailboxes = Get-Mailbox -ResultSize Unlimited
$groups = Get-DistributionGroup -ResultSize Unlimited
$contacts = Get-MailContact -ResultSize Unlimited

# Get all accepted domains
$domains = Get-AcceptedDomain

# Create the output array
$output = @()

# For each domain
foreach ($domain in $domains)
{
  # Create a new object used to store information
  $obj = New-Object PSObject

  # Add domain information to the object
  $obj | Add-Member NoteProperty domainName($domain.DomainName)
  $obj | Add-Member NoteProperty domainType($domain.DomainType)

  # Get all mailboxes where the domain is included in the EmailAddresses attribute
  $res = $mailboxes | where-object { $_.EmailAddresses -Match $domain.DomainName }

  # Get the number of mailboxes which use the accepted domain
  $mailboxCount = $res.Count

  # Get all distribution groups where the domain is included in the EmailAddresses attribute
  $res = $groups | where-object { $_.EmailAddresses -Match $domain.DomainName }

  # Get the number of distribution groups which use the accepted domain
  $groupCount = $res.Count

  # Get all contacts where the domain is included in the EmailAddresses attribute
  $res = $contacts | where-object { $_.EmailAddresses -Match $domain.DomainName }

  # Get the number of contacts which use the accepted domain
  $contactCount = $res.Count

  # If the domain is used 1 or more times, write YES inside the object's inUse property - otherwise NO
  if (($mailboxCount + $groupCount + $contactCount) -gt 0) {
      $obj | Add-Member NoteProperty inUse("YES")
  } else {
      $obj | Add-Member NoteProperty inUse("NO")
  }

  # Add the number of mailboxes, groups and contacts that use the domain
  $obj | Add-Member NoteProperty mailboxes($mailboxCount)
  $obj | Add-Member NoteProperty groups($groupCount)
  $obj | Add-Member NoteProperty contacts($contactCount)

  # Append the created object to the output array
  $output += $obj
}

# Write the output to the console
Write-Output $output | Format-Table

# Export the output to a CSV-file in C:\temp
$output | export-csv -path "C:\temp\UnusedAcceptedDomains.csv" -NoTypeInformation

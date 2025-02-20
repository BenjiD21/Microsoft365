<#
.SYNOPSIS
Exports members of mail-enabled security groups to a JSON file.

.DESCRIPTION
The script queries all mail-enabled security groups in Active Directory, retrieves their members, and resolves their email addresses.
Duplicate email addresses are removed, warnings are logged for users missing critical attributes, and null values are excluded from the JSON output.

.VERSION
1.3 - Added duplicate removal for email addresses in the JSON output.

.AUTHOR
Benjamin Daur/audius

.NOTES
- Be sure to update the file path for the JSON export.
#>

# Initialize a hashtable to store group-to-member mapping
[hashtable]$groupsExport = @{}

# Function to retrieve member emails from a group
function Get-GroupMemberEmails {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupDN
    )

    $memberEmails = @()

    # Get group members
    $members = Get-ADGroupMember -Identity $GroupDN -ErrorAction SilentlyContinue
    foreach ($member in $members) {
        if ($member.ObjectClass -eq "Group") {
            # Recursively retrieve emails from nested groups
            $nestedGroupMembers = Get-ADGroupMember -Identity $member.DistinguishedName -ErrorAction SilentlyContinue |
                                  Get-ADUser -Properties Mail -ErrorAction SilentlyContinue
            $nestedEmails = $nestedGroupMembers | Where-Object { $_.Mail } | ForEach-Object { $_.Mail }
            $memberEmails += $nestedEmails
        } elseif ($member.ObjectClass -eq "User") {
            # Retrieve user email
            $user = Get-ADUser -Identity $member.DistinguishedName -Properties Mail -ErrorAction SilentlyContinue
            if ($user) {
                if ($user.Mail) {
                    $memberEmails += $user.Mail
                } else {
                    Write-Warning "User $($member.Name) is missing an email address."
                }
            } else {
                Write-Warning "User $($member.Name) is missing a DistinguishedName or could not be retrieved."
            }
        }
    }
    return $memberEmails
}

# Retrieve all mail-enabled security groups
$mailEnabledGroups = Get-ADGroup -LDAPFilter "(&(mail=*)(groupType:1.2.840.113556.1.4.803:=2147483648))" -Properties DisplayName, Mail

# Process each group
$mailEnabledGroups | ForEach-Object {
    $groupMail = $_.Mail
    $groupDN = $_.DistinguishedName

    if ($groupMail -and $groupDN) {
        # Get all member emails for the group
        $memberEmails = Get-GroupMemberEmails -GroupDN $groupDN

        # Remove empty, null, and duplicate values from the email list
        $memberEmails = $memberEmails | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Unique

        # Add the group and its members to the export table
        $groupsExport.Add($groupMail, $memberEmails)
    } else {
        Write-Warning "Group $($_.Name) is missing a mail address or distinguished name."
    }
}

# Convert the hashtable to JSON format
$groupsJSON = $groupsExport | ConvertTo-Json -Depth 3

# Export the JSON data to a file
$exportPath = "C:\temp\MailEnabledSecurityGroupMembers.json"
$groupsJSON | Out-File -FilePath $exportPath -Encoding UTF8

Write-Host "Export completed. JSON file saved to: $exportPath"

<#
.SYNOPSIS
    Exports details of all mailboxes in Exchange Online with a configured forwarding address.

.DESCRIPTION
    This script connects to Exchange Online and retrieves all mailboxes that have either
    a ForwardingAddress or ForwardingSmtpAddress configured.
    For each matching mailbox, it collects key details including:
        - Display Name
        - User Principal Name
        - Forwarding Primary SMTP Address
        - Forwarding Distinguished Name
        - DeliverToMailboxAndForward flag
    The results are stored in a hashtable keyed by UPN, converted to JSON, and saved to file.

.PARAMETER ExportPath
    The file path where the output JSON file will be saved.
    Defaults to: C:\temp\ForwardingRulesExport.json

.OUTPUTS
    JSON file containing the forwarding configuration of matching mailboxes.

.NOTES
    Author: Benjamin Daur (audius)
    Date: 11.08.2025
    Requires: Exchange Online PowerShell Module (Connect-ExchangeOnline)
    Version: 1.1

.EXAMPLE
    .\Export-ForwardingRules.ps1
    Exports to the default path.

.EXAMPLE
    .\Export-ForwardingRules.ps1 -ExportPath "D:\Exports\ForwardingRules.json"
    Exports to a custom path.
#>

Param(
    [Parameter(Mandatory = $false)]
    [string]$ExportPath = "C:\temp\ForwardingRulesExport.json"
)

# Retrieve mailboxes with forwarding addresses
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.ForwardingAddress -ne $null -or $_.ForwardingSmtpAddress -ne $null }

# Create the hashtable used for the export
[hashtable]$forwardingExport = @{}

$mailboxes | ForEach-Object {
    $forwardingMailboxDetails = [ordered]@{}
    
    $mailboxProperties = $_ | Select-Object DisplayName, UserPrincipalName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward, PrimarySmtpAddress
    
    $DisplayName = $mailboxProperties.DisplayName
    $UserPrincipalName = $mailboxProperties.UserPrincipalName
    $DeliverToMailboxAndForward = $mailboxProperties.DeliverToMailboxAndForward
    $PrimarySmtpAddress = $mailboxProperties.PrimarySmtpAddress
    $DistinguishedNameForward = $mailboxProperties.ForwardingAddress.DistinguishedName
    
    $PrimarySmtpAddressForward = $null
    if ($DistinguishedNameForward) {
        $PrimarySmtpAddressForward = (Get-Mailbox -Identity $DistinguishedNameForward | Select-Object -ExpandProperty PrimarySmtpAddress -ErrorAction SilentlyContinue)
    }

    $forwardingMailboxDetails.Add("DisplayName", $DisplayName)
    $forwardingMailboxDetails.Add("UserPrincipalName", $UserPrincipalName)
    $forwardingMailboxDetails.Add("ForwardingPrimarySmtpAddress", $PrimarySmtpAddressForward)
    $forwardingMailboxDetails.Add("ForwardingDistinguishedName", $DistinguishedNameForward)
    $forwardingMailboxDetails.Add("DeliverToMailboxAndForward", $DeliverToMailboxAndForward)
    
    $forwardingExport.Add($UserPrincipalName, $forwardingMailboxDetails)
}

$forwardingExportJSON = $forwardingExport | ConvertTo-Json -Depth 5
$forwardingExportJSON | Out-File $ExportPath -Encoding UTF8
Write-Host "Forwarding rules exported to $ExportPath" -ForegroundColor Green

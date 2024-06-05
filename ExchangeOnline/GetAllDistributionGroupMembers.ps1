$Result=@()
$groups = Get-DistributionGroup -Filter "EmailAddresses -like '%FILTERVALUE%'" -ResultSize Unlimited
$totalmbx = $groups.Count
$i = 1
$groups | ForEach-Object {
Write-Progress -activity "Processing $_.DisplayName" -status "$i out of $totalmbx completed"
$group = $_
Get-DistributionGroupMember -Identity $group.Name -ResultSize Unlimited | ForEach-Object {
$member = $_
$Result += New-Object PSObject -property @{
GroupName = $group.DisplayName
GroupMail = $group.EmailAddresses
Member = $member.Name
EmailAddress = $member.PrimarySMTPAddress
RecipientType= $member.RecipientType
}}
$i++
}
#$Result | Out-GridView
$Result | Export-CSV "C:\temp\All-Distribution-Group-Members.csv" -NoTypeInformation -Encoding UTF8

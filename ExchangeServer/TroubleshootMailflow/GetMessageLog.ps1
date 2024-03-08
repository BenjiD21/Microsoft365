# gets the message log for a specific user at a specific point in time for all Exchange Servers
# has to be executed in Exchange Management Shell

$end = get-date
$start = (get-date).AddHours(-12)
Get-TransportService | get-messagetrackinglog -resultsize unlimited -start $start -end $end -recipients max.mustermann@contoso.com | select eventid, sender, messagesubject, timestamp
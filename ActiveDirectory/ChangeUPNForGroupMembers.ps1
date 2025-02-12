# Alle User innerhalb der angegebenen Gruppe werden in einer Variable gespeichert
$ChangeUpnUsers = Get-AdGroupMember -Identity "TestUPNGroup"

# Für jeden User innerhalb der Gruppe wird der UPN als Vorname.Nachname@contoso.com festgelegt
$ChangeUpnUsers | foreach {
	$user = $_ | Get-AdUser -Properties Userprincipalname, givenname, sn;
	$NewUPN = $user.givenname + "." + $user.sn + "@contoso.com";
	$user | Set-ADUser -UserPrincipalName $newUpn}

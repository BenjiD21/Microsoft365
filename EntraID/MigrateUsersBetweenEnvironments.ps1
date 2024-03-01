# Get-ADUser -Filter 'Name -like "service,azubi"' -properties * | Select CN, DisplayName, EmailAddress, GivenName, mail, mailNickname, msDS-SupportedEncryptionTypes, msExchALObjectVersion, msExchHideFromAddressLists, @{Name='msExchPoliciesIncluded';Expression={$_.msExchPoliciesIncluded -join ';'}}, msExchRecipientDisplayType, msExchRecipientTypeDetails, msExchRemoteRecipientType, @{Name='msExchTextMessagingState';Expression={$_.msExchTextMessagingState -join ';'}}, @{Name='msExchUMDtmfMap';Expression={$_.msExchUMDtmfMap -join ';'}}, msExchUserAccountControl, msExchVersion, msExchWhenMailboxCreated, Name, ObjectGUID, @{Name='proxyAddresses';Expression={$_.proxyAddresses -join ';'}}, SamAccountName, sAMAccountType, sn, Surname, telephoneNumber, UserPrincipalName | Export-CSV "C:\temp\azubiService2.csv" -NoTypeInformation -Encoding UTF8
# Userabgleich per SamAccountName

# csv importieren
# $users = Import-Csv C:\Temp\VMTags.csv

# alle csv-header holen (sind die Bezeichnungen der Attribute)
# $usersHeaders = $users.psobject.Properties | Select Value

foreach($user in $users){
        
        $testUser = Get-ADUser -Identity $user.SAMAccountName
        
        if ($testUser -eq $null) {

            Write-Host "Der User mit dem Namen $($user.SAMAccountName) ist in der Quelle nicht vorhanden. Es wurde für ihn keine Aktion durchgeführt."

        } else {

            # Die nicht-Multi-Value Attribute setzen
            Set-ADUser -Identity $user.SAMAccountName -Add @{
                CN=$user.CN; 
                DisplayName=$user.DisplayName;
                EmailAddress=$user.EmailAddress;
                GivenName=$user.GivenName;
                mail=$user.mail;
                mailNickname=$user.mailNickname;
                'msDS-SupportedEncryptionTypes'=$user.'msDS-SupportedEncryptionTypes';
                msExchALObjectVersion=$user.msExchALObjectVersion;
                msExchHideFromAddressLists=$user.msExchHideFromAddressLists;
                msExchRecipientDisplayType=$user.msExchRecipientDisplayType;
                msExchRecipientTypeDetails=$user.msExchRecipientTypeDetails;
                msExchRemoteRecipientType=$user.msExchRemoteRecipientType;
                msExchUserAccountControl=$user.msExchUserAccountControl;
                msExchVersion=$user.msExchVersion;
                msExchWhenMailboxCreated=$user.msExchWhenMailboxCreated;
                Name=$user.Name;
                SamAccountName=$user.SamAccountName;
                sAMAccountType=$user.sAMAccountType;
                sn=$user.sn;
                Surname=$user.Surname;
                telephoneNumber=$user.telephoneNumber;
                UserPrincipalName=$user.UserPrincipalName;
            }

            # Multi-Value Attribute schreiben

            # ProxyAddresses
            $proxyAddressesValues = $user.proxyAddresses -split (";")

            foreach ($proxyAddressesValue in $proxyAddressesValues) {

                if ($proxyAddressesValue.startsWith("smtp") -Or $proxyAddressesValue.startsWith("SMTP") -Or $proxyAddressesValue.startsWith("X500") -Or $proxyAddressesValue.startsWith("x500")) {
                
                    Set-ADUser -Identity $user.SAMAccountName -Add @{proxyAddresses=$proxyAddressesValue}
                    
                } else {

                    Write-Host "Die ProxyAdresse $($proxyAddressesValue) für den Benutzer $($user.SAMAccountName) konnte nicht geschrieben werden."

                }

            }

            # msExchUMDtmfMap
            $msExchUMDtmfMapValues = $user.msExchUMDtmfMap -split (";")

            foreach ($msExchUMDtmfMapValue in $msExchUMDtmfMapValues) {
                
                Set-ADUser -Identity $user.SAMAccountName -Add @{msExchUMDtmfMap=$msExchUMDtmfMapValue}    

            }

            # msExchTextMessagingState
            $msExchTextMessagingStateValues = $user.msExchTextMessagingState -split (";")

            foreach ($msExchTextMessagingStateValue in $msExchTextMessagingStateValues) {
                
                Set-ADUser -Identity $user.SAMAccountName -Add @{msExchTextMessagingState=$msExchTextMessagingStateValue}    

            }

            # msExchPoliciesIncluded
            $msExchPoliciesIncludedValues = $user.msExchPoliciesIncluded -split (";")
            
            foreach ($msExchPoliciesIncludedValue in $msExchPoliciesIncludedValues) {
                
                Set-ADUser -Identity $user.SAMAccountName -Add @{msExchPoliciesIncluded=$msExchPoliciesIncludedValue}    

            }  

        }

        $testUser = $null

    }
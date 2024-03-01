# Commands to create a local user account
# can be used to create a local admin account. Use LAPS to change the password upon user creation and assign user to the Administrators group using Intune

New-LocalUser "maurice.moss" -Password (ConvertTo-SecureString -AsPlainText -Force 'YourPassword')
Add-LocalGroupMember -SID "S-1-5-32-544" -Member "maurice.moss"
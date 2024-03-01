$PackageName = "RemoveNewsAndInterests"
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-script.log" -Force

# Remove News and Interests

$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
$Key = "ShellFeedsTaskbarViewMode"
$KeyFormat = "dword"
$Value = "2"

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}

Stop-Transcript
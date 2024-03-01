$PackageName = "RemoveTaskViewButton"
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-script.log" -Force

# Remove Task View button

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Key = "ShowTaskViewButton"
$KeyFormat = "dword"
$Value = "0"

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}


Stop-Transcript
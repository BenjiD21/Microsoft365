$PackageName = "RemoveSearchBox"
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-unscript.log" -Force

# Remove Search bar

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Key = "SearchboxTaskbarMode"
$KeyFormat = "dword"
$Value = "1"

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}


Stop-Transcript
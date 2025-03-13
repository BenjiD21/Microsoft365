# This scrript creates the device identifier CSV-file needed for Windows Autopilot device preparation
# Creates the CSV-file in the directory the script is executed
$objBIOSInfo = Get-Ciminstance -Class Win32_BIOS
$objComputerInfo = Get-Ciminstance -Class Win32_ComputerSystem 
$strManufacturer = $objComputerInfo.Manufacturer
$strModel = $objComputerInfo.Model
$strSerialNumber = $objBIOSInfo.SerialNumber
$strDeviceIdentifier = "$strManufacturer,$strModel,$strSerialNumber"
Set-Content -Path "DeviceIdentifier.csv" -Value $strDeviceIdentifier

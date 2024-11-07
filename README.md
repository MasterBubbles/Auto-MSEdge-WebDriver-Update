# Auto-MSEdge-WebDriver-Update

Automatically update the MS Edge WebDriver if necessary before running any automation script.

This powershell code automatically checks whether the installed version of MS Edge is the same as the last time it updated the driver.
If not, it will update to the corresponding driver version.

It uses the same link format for each update provided by Microsoft here: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/

Replace `C:\selenium` in the first line with the path to the folder where you need the driver


```powershell
$Path = "C:\selenium"
$previousversion = Get-Content -Path $Path\edgeversion.txt
$installedversion = (Get-ItemProperty -Path HKCU:\Software\Microsoft\Edge\BLBeacon -Name version).version
If ($previousversion -eq $installedversion) {
  'Edge WebDriver is already up to date'
  }  Else {
  'Edge WebDriver will be updated'
  $installedversion | Out-File -FilePath $Path\edgeversion.txt
  Remove-Item $Path\msedgedriver.exe
  $WebClient = New-Object System.Net.WebClient
  $URL = "https://msedgedriver.azureedge.net/$installedversion/edgedriver_win64.zip"
  $filepath = "$Path\edgedriver_win64.zip"
  $WebClient.DownloadFile($URL,$filepath)
  Add-Type -Assembly System.IO.Compression.FileSystem
  $zipFile = [IO.Compression.ZipFile]::OpenRead($filepath)
  $zipFile.Entries | Where-Object Name -like msedgedriver.exe | ForEach-Object{[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, “$Path\$($_.Name)”, $true)}
  $zipFile.Dispose()
  Remove-Item $Path\edgedriver_win64.zip
  }
```


Simply add a command at the beginning of your Python scripts (or other) to call upon PowerShell to execute `MSEdge-Webdriver-Updater.ps1`. Or you could just use this code and add the Invoke-Item command at the end to invoke whatever automation tool that requires the driver, or add whatever command you need to run it (for example: `python "C:\path\to\your\script.py"`).

----------

**The first time you run this, it will output an error because the `edgeversion.txt` file needs to be created. This file will be used to determine for which version of Edge the driver was last updated. It checks whether the version indicated in this text file is the same as the actual installed version of MS Edge, to determine whether it needs to update again or not. Therefore, the first time you run it, it will update anyway because it will not know what is the actual version of the driver.***

**Update: If powershell prevents the scripts from running, please run the code below**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

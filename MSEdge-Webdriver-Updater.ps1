$Path = "C:\selenium"
$previousversion = Get-Content -Path "$Path\edgeversion.txt"
$installedversion = (Get-ItemProperty -Path HKCU:\Software\Microsoft\Edge\BLBeacon -Name version).version
If ($previousversion -eq $installedversion) {
  Write-Output 'Edge WebDriver is already up to date'
} Else {
  Write-Output 'Edge WebDriver will be updated'
  $installedversion | Out-File -FilePath "$Path\edgeversion.txt"
  Remove-Item "$Path\msedgedriver.exe" -Force
  $WebClient = New-Object System.Net.WebClient
  $URL = "https://msedgedriver.azureedge.net/$installedversion/edgedriver_win64.zip"
  $filepath = "$Path\edgedriver_win64.zip"
  $WebClient.DownloadFile($URL, $filepath)
  Add-Type -Assembly System.IO.Compression.FileSystem
  $zipFile = [IO.Compression.ZipFile]::OpenRead($filepath)
  $zipFile.Entries | Where-Object { $_.Name -eq "msedgedriver.exe" } | ForEach-Object {
      [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$Path\$($_.Name)", $true)
  }
  $zipFile.Dispose()
  Remove-Item $filepath
}

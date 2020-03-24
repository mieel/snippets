# Universal Dashboard Snippets
## to start a Dashboard in IIS
```
$Dashboard = . "$PSScriptRoot\dashboard-content.ps1"
$DashParams = @{
    Wait      = $true
    Dashboard = $Dashboard
    Force     = $True
}

If ($Cache:UDFolders) {
    $DashParams.Add('PublishedFolder', $Cache:UDFolders)
}

Start-UDDashboard @DashParams
```
## Read Config values from web.config
```
# Reads web.config, creates an Appsettings hashtable
# and creates individual variables of each keypair
$WebConfigContent = ([xml](Get-Content $Cache:WebRoot\$WebConfig))
$KeyPairs = $WebConfigContent.configuration.appsettings.add

$Cache:AppSettings = @{ }
$KeyPairs | ForEach-Object {
    $Cache:AppSettings.Add($_.Key, $_.Value)
    New-Variable -Name $_.Key -Value $_.Value -Force
}
```

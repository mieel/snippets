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
## Page with a Search box and Results grid
```
New-UDPage -Name "Search" -Icon box -Content {
    New-UDInput -Title "Search Something 📝" -Id "webdivSearchForm" -Content {
        New-UDInputField -Type 'textbox' -Name 'SearchString' -Placeholder 'Search'       
    } -Endpoint {
        param(
            $SearchString            
        )
        $GridSettings = @{
            Title      = "Results ~ $SearchString"
            Headers    = $Cache:Fields
            Properties = $Cache:Fields
        }
        Set-UDElement -Id "results" -Content {
            New-UDGrid @GridSettings -Endpoint {
                
                $Results = Search-Something -Parameter $Searchstring              
                $Results | Select-Object -Property $Cache:Fields | Out-UDGridData
            } 
        }
    } -Validate

    New-UDRow -Columns {
        New-UDColumn -SmallSize 12 {
            New-UDElement -Tag "div" -Id "results"
        }
    }


}
```

# Universal Dashboard Snippets
## to start a Dashboard in IIS
Create a content file that will create the dashboard elements
<details>
    <summary>dashboard-content.ps1</summary>
        
```
Param (
    [switch]
    $LocalConfig
)
# Use a local web.config to test locally
$WebConfig = 'web.config'
If ( $LocalConfig ) {
    $WebConfig = 'web.config.local'
}
#Set Cache variables
# See next section: Config Values
...

# local modules 
$EndPointInitModules = @()

# default Toast Parameters
$ToastParams = @{
    Duration     = 5000
    ReplaceToast = $True
    Position     = 'bottomRight'
    Theme        = 'dark'
}

# Load Functions and Pages
## functions are loaded into the session
Get-ChildItem $Cache:WebRoot/functions | Where-Object { $_.FullName -like '*.ps1' } | ForEach-Object { . "$($_.FullName)" }
## pages and navigation are loaded into variables
$Pages = Get-ChildItem $Cache:WebRoot/pages -Recurse | Where-Object { $_.FullName -like '*.Page.ps1' } | Sort-Object { $_.Name } | ForEach-Object { . "$($_.FullName)" }
$Navigation = . "$Cache:WebRoot/pages/elements/Sidebar.Navigation.ps1"

# Expose Folders
$Cache:UDFolders = Publish-UDFolder -Path $Cache:WorkingDirectoryPath -RequestPath "/share"

# Endpoint Inititialization
$EndPointInit = New-UDEndpointInitialization -Module @(
    $EndPointInitModules
) -Variable @(
    'ToastParams'
) -Function @(
    @($ListofFunctions)
)

# Outputting the Dashboard object (to be used in a Start-UDDashboard cmdlet)

New-UDDashboard -Title "Dashboard" -Pages $Pages -EndpointInitialization $EndPointInit -Navigation $Navigation

```

</details>

When using IIS this file will be used to boot the Dashboard
<details>
    <summary>dashboard.ps1</summary>
        
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

</details>

## Read Config values from web.config
<details>
    <summary>read config values</summary>
    
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

</details>

## Page with a Search box and Results grid

<details>
    <summary>SearchPage.ps1</summary>
    
```
New-UDPage -Name "Search" -Icon box -Content {
    New-UDInput -Title "Search Something 📝" -Id "inputSearchForm" -Content {
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

</details>

## Functions to convert an object into a UDTable

<details>
    <summary>Get-PropertiesAsObjects</summary>
    
```
Function Get-PropertiesAsObjects {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [psobject]
        $Object
        ,
        [string[]]
        $SkippedProperties
    )
    $SystemXMLProperties = @(
        'LocalName'
        'NamespaceURI'
        'Prefix'
        'NodeType'
        'ParentNode'
        'OwnerDocument'
        'IsEmpty'
        'Attributes'
        'HasAttributes'
        'SchemaInfo'
        'InnerXml'
        'InnerText'
        'NextSibling'
        'PreviousSibling'
        'Value'
        'ChildNodes'
        'FirstChild'
        'LastChild'
        'HasChildNodes'
        'IsReadOnly'
        'OuterXml'
        'BaseURI'
        'PreviousText'
    )
    $DefaultSkippedProperties = @('HasErrors', 'ItemArray', 'Table', 'RowError', 'RowState')
    $DefaultSkippedProperties += $SystemXMLProperties
    $SkippedProperties += $DefaultSkippedProperties
    $Output = [ordered]@{ }
    $Object.psobject.Properties |
    ForEach-Object {
        if ($SkippedProperties.Contains( $_.Name) -or $_.TypeNameOfValue -like 'System.Xml.*') {
            return
        }
        # Set default value so that we can display it properly in a UD Table
        $Value = '-'
        if ($_.Value -in @($null, '')) {
            $Value = '-'
        } else {
            $Value = $_.Value
        }
        $Output.Add($_.Name, $Value)
    }
    Write-Output $Output

}
```
</details>

<details>
<summary>New-UDPropertiesTable</summary>
    
```
Function New-UDPropertiesTable {

    Param(
        [psobject] $Object
        ,
        [string] $TitleProperty
        ,
        [string] $TitlePrefix
        ,
        [string] $ExpandOn

    )
    $Properties = $Object | Add-UDLink | Get-PropertiesAsObjects
    If ($TitleProperty) {
        $TitlePropertyValue = $Object.$TitleProperty
        $Properties.Remove($TitleProperty)
    }
    If ($ExpandOn) {
        $ExpandNode = $Properties.$ExpandOn
        If ($ExpandNode) {
            $Properties.Remove($ExpandOn)
            $i = 1
            ForEach ($item in $ExpandNode) {
                $Properties.Add("$ExpandOn`_$i", "$($item |Out-String)")
                $i++
            }
        }
    }
    If (!$TitlePrefix) {
        $TitlePrefix = "Details 📃"
    }
    New-UDTable -Title "$TitlePrefix`: $TitlePropertyValue" -Headers @("Name", "Value") -Endpoint {
        $data = $Argumentlist[0]
        $data.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
    }  -ArgumentList @($Properties)
}
```
</details>

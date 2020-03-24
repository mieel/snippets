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
## Function to convert an object into a UDTable
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

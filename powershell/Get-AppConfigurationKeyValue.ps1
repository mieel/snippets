$clientId = 'client/app id'
$tenantId = 'tenant id'
$secret = 'client secret'

az login --service-principal --username $clientId  --password $secret --tenant $tenantId

function Get-KeyReference {
    param(
        $string = 'Server=$(Lookup.Database.Server);Database=$(Lookup.Database.Name);Trusted_Connection=Yes'
        ,
        $regex = '\$\([\w.]*\)'
    )
    $matches = ($string | select-string -pattern $regex -AllMatches).Matches.Value
    if ($matches) { 
        $matches.replace('$(','').replace(')','')     
    }
}

function Convert-KeyReference {
    [cmdletbinding()]
    param(
        $String
        ,
        $Dictionary
        ,
        $Prefix = '\$\('
        ,
        $Suffix = '\)'
    )        
    $stringOutput = $string
    $references = Get-KeyReference -String $string -Regex "$Prefix[\w.]*$Suffix"
    if (-not $references) {
        Return $stringOutput
    }
    $references | Foreach-Object {
        $refKey = $_
        $refValue = ($Dictionary | Where-Object {$_.key -eq $refkey}).Value
        Write-Verbose "$refkey resolved to $refValue"
        $stringOutput = $stringOutput -replace "$Prefix$refKey$Suffix",$refValue            
    }
    Convert-KeyReference -String $stringOutput -Dictionary $Dictionary           
}

function Get-AppConfigurationKeyValue {
    [cmdletbinding()]
    param(
        [string] $Key = '*'
        ,
        [string] $Store
        ,
        [string] $Label = '*'
        ,
        [switch] $NoResolveSecret
        ,
        [switch] $ExcludeNoLabel
    )   
    # az appconfig kv list -h
    If (-not $NoResolveSecret) {
        $resolveKv = '--resolve-keyvault'
    } 
    $Output = az appconfig kv list --name $Store --label \0 --key $Key $resolveKv | ConvertFrom-Json
    $Output += az appconfig kv list --name $Store --label $Label --key $Key $resolveKv | ConvertFrom-Json

    ForEach ($kv in $Output) {
        $value = $kv.value       
        $value = Convert-KeyReference -String $value -Dictionary $Output
        Write-Output @{ $kv.key = $value}
    }
}

$store = 'MyAppConfig'
$Key = '*'
$label = 'Production'
Get-AppConfigurationKeyValue  -Store $store -Key $Key -Label $label

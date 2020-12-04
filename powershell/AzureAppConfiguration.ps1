
function Get-AppConfigurationKeyValue {
    param(
        [string] $Key
        ,
        [string] $Store
        ,
        [string] $Label = '*'
        ,
        [switch] $ResolveSecret
    )   
    # az appconfig kv list -h
    If ($ResolveSecret) {
        $kv = '--resolve-keyvault'
    } 
    $json = az appconfig kv list --name $Store --label $Label --key $Key $kv

    $kvlist = $json | ConvertFrom-Json 

    ForEach($kv in $kvlist) {
             
        @{ }
    }
}


$store = 'mystore'
$Key = 'mykey'
(Get-AppConfigurationKeyValue  -Store $store -Key $Key -Label Acceptance).Value

(Get-AppConfigurationKeyValue  -Store $store -Key $Key -Label Acceptance -ResolveSecret).Value

Measure-Command {
    Write-Host 'all keys'
    Get-AppConfigurationKeyValue  -Store $store -Key * -Label Acceptance
}

Measure-Command {
    Write-Host 'all keys'
    Get-AppConfigurationKeyValue  -Store $store -Key Common* -Label Acceptance
}

Measure-Command {
    Write-Host 'single key'
    Get-AppConfigurationKeyValue  -Store $store -Key $Key -Label Acceptance
}


Measure-Command {
    Write-Host 'single resolved secret'
    Get-AppConfigurationKeyValue  -Store $store -Key $Key -Label Acceptance -ResolveSecret
}

Measure-Command {
    Write-Host 'multi resolved secret'
    Get-AppConfigurationKeyValue  -Store $store -Key MyProduct* -Label Acceptance -ResolveSecret
}

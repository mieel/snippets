function Get-AzStorageHeaders {
    param(
        $resource,
        $storageAccount,
        $storageAccountkey
    )
    $GMTTime = (Get-Date).ToUniversalTime().toString('R')
    $stringToSign = "$GMTTime`n/$storageAccount/$resource"
    $version = "2017-04-17"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Convert]::FromBase64String($storageAccountkey)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    $signature = [Convert]::ToBase64String($signature)
    $local:headers = @{
        'x-ms-date'    = $GMTTime
        Authorization  = "SharedKeyLite " + $storageAccount + ":" + $signature
        "x-ms-version" = $version
        Accept         = "application/json;odata=fullmetadata"
    }
    Write-Output $local:headers
}
function Get-AzTableEntity {
    param(
        $storageAccount,
        $storageAccountkey,
        $tableName,
        $queryFilter
    )
    $resource= "$tableName"
    $table_url = "https://$storageAccount.table.core.windows.net/$resource"
    $local:headers = Get-AzStorageHeaders -resource $resource -storageAccount $storageAccount -storageAccountkey $storageAccountkey
    $queryURL = "$($table_url)?`$filter=($queryFilter)"
    $result = Invoke-RestMethod -Method GET -Uri $queryURL -Headers $local:headers -ContentType application/json
    Write-Output $result.value
}
function Set-AzTableEntity {
    param(
        [string] $storageAccount,
        [string] $storageAccountkey,
        [string] $tableName, 
        [string] $PartitionKey, 
        [string] $RowKey, 
        [psobject] $Entity
    )
    $resource= "$tableName(PartitionKey='$PartitionKey',RowKey='$Rowkey')"
    $table_url = "https://$storageAccount.table.core.windows.net/$resource"
    $local:headers = Get-AzStorageHeaders -resource $resource -storageAccount $storageAccount -storageAccountkey $storageAccountkey
    $body = $Entity | ConvertTo-Json
    $item = Invoke-RestMethod -Method MERGE -Uri $table_url -Headers $local:headers -Body $body -ContentType application/json
}

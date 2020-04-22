#region Doc
<#
	.SYNOPSIS
		Functions to Ensure AAD Users with auto generating passwords backed in an Azure Key Vault.
	.DESCRIPTION
		Customize the follwing functions to tailor your need:
		1) New-Password:
		Here I use the pronounceable pattern from the 'https://makemeapassword.ligos.net' api.
		with two random integers added
		
		2) Get-VaultName:
		some logic to format vault names based on <environment> and <vaultbasename
		e.g: environment='Development', vaulbasename='covid' => 'kv-mycorp-d-covid'
		
		3) Get-ServiceAccountUPN:
		e.g: $domain = 'mycorp.com', $service = 'service_name', $environment = 'Dev'
		=> output: svc_d_service_name@mycorp.com
	
#>
#endregion
#region functions 
Function New-Password {
    $resp = Invoke-RestMethod -uri 'https://makemeapassword.ligos.net/api/v1/pronounceable/json?c=1&sc=3'
    Return ($resp.pws | Out-String).TrimEnd() + (Get-Random -Minimum 10 -Maximum 99)
}

Function Set-AzureKeyvaultSecret {
    param (
        $secretName = 'default'
        ,
        $vaultName = 'VaultName'     # insert default vaultname
        ,
        $resgroup = 'resource-group' # insert your default resource group
        ,
        [switch] $PassThru
		,
		[switch] $UpdatePassword
    )
    $kv = az keyvault create --location westeurope --name $vaultName --resource-group $resgroup
    if (!$?) { Write-Error $_ }
    Write-Host ($kv | ConvertFrom-Json).id

    $secret = az keyvault secret show --vault-name $vaultName --id https://$vaultName`.vault.azure.net/secrets/$secretName
    if (!$? -or $UpdatePassword) {
        Write-Host 'Adding Secret'
        $pw = New-Password
        $secret = az keyvault secret set --vault-name $vaultName --name $secretName --value "$pw"
    }
    $obj = ($secret | ConvertFrom-Json)
    $output = @{
        Id = $obj.id
        Name = $secretName
        Value = $obj.value
    }
    if ($PassThru) {
        Return $output
    }
}

Function Set-ServiceAccountUser {
    param (
        $domain = 'domain.com'
        ,
        $service = 'service_backend'
        ,
        $environment = 'Dev'
        ,
        $vaultBaseName = 'product'
        ,
        [switch] $UpdatePassword
    )
    Begin {
        $upn = Get-ServiceAccountUPN -environment $environment -service $service -domain $domain
        $vaultName = Get-VaultName -environment $environment -vaultBaseName $vaultBaseName
    }
    Process {
        Try {
            Write-host "Getting user [$upn]..."
            $User = Get-AzADUser -UserPrincipalName $upn
        } Catch {
            Throw $_
        }        
        If (!$User) {
            Write-host "$upn - Does not exist, creating..."
            $Secret = Set-AzureKeyvaultSecret -secretName $service.replace('_','-') -vaultName $vaultName -PassThru
            $secString = $Secret.Value | ConvertTo-SecureString  -AsPlainText -Force
            $Splat = @{
                DisplayName = "$environment $Service"
                Password = $secString
                UserPrincipalName = $upn            
                MailNickName = $Service
            }
            $User = New-AzADUser @Splat
        }
        If ($User -and $UpdatePassword) {
            Write-host 'Updating password...'
            $Secret = Set-AzureKeyvaultSecret -secretName $service.replace('_','-') -vaultName $vaultName -PassThru -UpdatePassword
            $secString = $Secret.Value | ConvertTo-SecureString -AsPlainText -Force
            Update-AzAdUser -UserPrincipalName $upn -Password $secString
        }
        Write-Output $user
    }
    End {}
}
Function Get-ServiceAccountUPN {
    param (
        $domain = 'domain.com'
        ,
        $service = 'service_name'
        ,
        $environment = 'Dev'
    )
    # Insert business logic for account formatting
    Return "svc_{0}_{1}@{2}" -f  $environment.substring(0,1).ToLower(),$service,$domain
}
Function Get-VaultName {
    Param (
        $environment,$vaultBaseName
    )
    # Insert business logic for keyvaultname formatting
    Return "kv-mycorp-{0}-{1}" -f $e,$vaultBaseName
}
#endregion

#region MAIN
Import-Module Az    # Install-Module Az 
$Services = @(
    @{ name = 'service_1'    ; description = 'Service 1'},
    ....
)
$envs = @('Dev','Test','Acc','Stage','Prod')

# Creates/updates each service for each environment
Foreach ($Service in $Services){
    Foreach ($e in $envs) {
    	# leave out -UpdatePassword if you don't want to update the password if the user exists
        Set-ServiceAccountUser -service $Service.name -environment $e -vaultGroup 'myproduct' -UpdatePassword
    }
}
 
#endregion

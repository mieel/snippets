```
#requires pssqlhelpers
# Pipeline Vars #
$dbUser = '$(DB_User)'
$userName = '$(SqlUser)'
$userPass = '$(SqlUserPassword)'
$targetDatabase = '$(DatabaseName)'
$role = 'db_owner'
Import-Module PSSQL
$global:sqlAuthToken = @{ Username = $userName; Password = $userPass }

Write-Host 'Preparing new DB: $(DatabaseCurrentName)'
Write-Host 'Adding Login: ' $dbUser
$Query = "
  BEGIN TRY  
    --Create server Login
    CREATE LOGIN [$dbUser] from WINDOWS
  END TRY  
  BEGIN CATCH
    -- Login exists
  END CATCH;
"
Invoke-SqlQuery -Query $Query -Database master -ServerInstance $(ServerInstance)
Write-Host 'Adding User'
$Query = "
  BEGIN TRY  
    --Create Database User
    USE [$targetDatabase];
    CREATE USER [$dbUser] from login [$dbUser]
  END TRY  
  BEGIN CATCH
      -- User exists
  END CATCH;
"
Invoke-SqlQuery -Query $Query -Database master -ServerInstance $(ServerInstance)

Write-Host 'Adding User Role: ' $role 
$Query = "
  BEGIN TRY 
    -- Map user role
    USE [$targetDatabase];
    EXEC sp_addrolemember '$role ', '$dbUser'
  END TRY
  BEGIN CATCH
    -- Role exists
  END CATCH;
"
Invoke-SqlQuery -Query $Query -Database master -ServerInstance $(ServerInstance)

$YYMM = Get-Date -format "yyMM"
$Seed = $YYMM + '000000'
Write-Host 'Seeding Request Table with seed: ' $Seed
$Query = "
  --Set Seed to $Seed
  USE [$targetDatabase];
  DBCC CHECKIDENT (Request, RESEED, $Seed)
"
Invoke-SqlQuery -Query $Query -Database master -ServerInstance $(ServerInstance)

Write-Host 'Rolling over with: $(DatabaseName)'
$suffix = "$(Get-Date -format "yyyyMMdd")_$((new-guid).guid.substring(0,6))"
$DatabaseArchiveName = "$(DatabaseCurrentName)_$suffix"
Write-Host "Archiving Current Database as $DatabaseArchiveName"
$Query = "
  BEGIN TRY 
    -- take current offline and rename
    ALTER DATABASE $(DatabaseCurrentName) SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    ALTER DATABASE $(DatabaseCurrentName) MODIFY NAME = $DatabaseArchiveName
    ALTER DATABASE $DatabaseArchiveName SET MULTI_USER
  END TRY
  BEGIN CATCH
    -- Database doesn't exist
  END CATCH;
  -- replace with new
  ALTER DATABASE $(DatabaseName) SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  GO
  ALTER DATABASE $(DatabaseName) MODIFY NAME = $(DatabaseCurrentName);
  GO  
  ALTER DATABASE $(DatabaseCurrentName) SET MULTI_USER;
  GO
"
Invoke-SqlQuery -Query $Query -Database master -ServerInstance $(ServerInstance)
Write-Host 'New DB is now: $(DatabaseCurrentName)'
  ```

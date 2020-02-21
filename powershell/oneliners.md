## Enumerate list of Functions from a folder(to create .psd1 file)
Assuming you are stored each function in as it's own file  
`(Get-ChildItem .\src\Exportable\Public).BaseName | % { "'$_'"} | Clip`

## Print Environment Variables'
`Get-ChildItem Env: | Where-Object {$_.Name -like 'Build_*' -or $_.Name -like 'RELEASE_*' -or $_.Name -like 'SYSTEM_*'}`

## Enumerate list of Functions from a folder(to create .psd1 file)
Assuming you are stored each function in as it's own file  
`(Get-ChildItem .\src\Exportable\Public).BaseName | % { "'$_'"} | Clip`

# Enumerate list of Functions (to create .psd1 file)
`(Get-ChildItem .\src\Exportable\Public).BaseName | % { "'$_'"} | Clip`

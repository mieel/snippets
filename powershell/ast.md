# Get all functions calls of one command
```
# Requires Select-Ast : https://github.com/KevinMarquette/Select-Ast
Import-Module mymodule
$Command = 'mycoammand'
$CommandScriptBlock = (Get-Command $Command).ScriptBlock 
$CmdAst = $CommandScriptBlock | Select-Ast -Type CommandAst

ForEach ($c in $CmdAst) {
    $c.CommandElements[0].Value
}
```

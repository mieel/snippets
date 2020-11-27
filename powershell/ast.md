# Get all functions calls of one command
```
# Requires Select-Ast : https://github.com/KevinMarquette/Select-Ast
Import-Module mymodule
$Command = 'mycommand'
$CommandScriptBlock = (Get-Command $Command).ScriptBlock 
$CmdAst = $CommandScriptBlock | Select-Ast -Type CommandAst

ForEach ($c in $CmdAst) {
    $c.CommandElements[0].Value
}
```

# Visualize Module Function dependencies with yuml
```
Import-Module "MyModule"
$Commands = (Get-Command -Module MyModule).Name

$yuml = ForEach ($command in $Commands) {
    $CommandScriptBlock = (Get-Command $command).ScriptBlock 
    $CmdAst = $CommandScriptBlock | Select-Ast -Type CommandAst

    ForEach ($astcmd in $CmdAst) {
        if ($Commands -contains $astcmd) {
            "[$Command] - > [$($astcmd.CommandElements[0].Value)]"
        }
    }
}

$yuml = $yuml -join ','
$direction = 'LR'

# get the svg
$base = "https://yuml.me/diagram/scruffy;dir:$direction/class/"
$fullurl = "$base$yuml"

Invoke-WebRequest $fullurl -OutFile diagram.svg
```

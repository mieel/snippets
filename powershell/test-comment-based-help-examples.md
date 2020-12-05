Create Sample Function
```
Function ConvertFrom-UnixTime ($unixtime) {
    <#

        .DESCRIPTION
            Datetimes from JSON are stored as Unixtime. We need this funtion to convert it back as 'Human' time

        .EXAMPLE
            (ConvertFrom-UnixTime 1550504688).toString()
            Expected Output: "18/02/2019 15:44:48"
    #>
    if ( ($unixtime -ne -1) -and ($null -ne $unixtime) ) {
        $origin = New-Object -Type DateTime -ArgumenTlist 1970, 1, 1, 0, 0, 0, 0
        $datetime = $origin.AddSeconds($unixtime)
        Return $datetime
    } else {
        return $null
    }
}
```
Get get-help examples and test output if expected output is defined
```
Function Get-CommandHelpExample {
    <#
        .SYNOPSIS
            Set all code and remarks strings in an array
            PS 5 and 7 have different behaviours settings splitting the example in code/remark
            We use the lines until 'Expected Output' as code to execute
            and the remaining as the assertion
        .EXAMPLE
            $Command = 'Get-KeyReference'
            $Example = Get-CommandHelpExample -Command $Command

    #>
    param(
        $module
        ,
        [parameter(Mandatory=$true)]
        $Command
    )
    $help = Get-Help $Command -Examples
    [string]$exampleText = $help.examples[0].example.code
    $exampleText += "`n$($help.examples[0].example.remarks.Text)"
    [string[]]$strings = $exampleText.split("`n")
    $exampleScriptblock = $exampleText
    if ($exampleText -match 'Expected Output') {
        # Test the code block if Expected Output is specified
        Write-Verbose "Assertion set for Code"
        $i = 0
        $code = @()
        ForEach ($line in $strings) {
            Write-Verbose "$i : $line"
            if ($line -notmatch 'Expected Output') {
                $code += $line
                $i++
            } else {
                break
            }
        }
        $end = $strings.GetUpperBound(0)+1
        $assertion = $strings[$i..$end] -join "`n"
        Write-Verbose $assertion
        $exampleScriptblock = $Code -join "`n"
    }
    Write-Output @{ Scriptblock = $exampleScriptblock  ; Assertion = $assertion.Replace('Expected Output: ','') }
}

$Command = 'Get-KeyReference'
$Example = Get-CommandHelpExample -Command $Command

$expectedOutput = Invoke-Expression ($Example.Assertion | Out-String)
$actualOutput = Invoke-Expression $Example.Scriptblock

Compare-Object $actualOutput $expectedOutput
```
Result in the console
```
18/02/2019 15:44:48
should be
18/02/2019 15:44:48

```

💡Improvent idea: Convert these into dynamic pester tests

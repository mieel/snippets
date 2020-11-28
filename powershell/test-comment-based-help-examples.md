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
$command = 'ConvertFrom-UnixTime'
$help = Get-Help $command -Examples

$codeBlock = $help.examples.example[0].code
$remarks = $help.examples.example[0].remarks | out-string

if ($remarks -match 'Expected Output') {
    # Test the code block if Expected Output is specified
    "Code to test"
    $code
    "Expected Output"
    $expectedOutput = Invoke-Expression ($remarks ).Replace("Expected Output: ","")


    $actualOutput = Invoke-Expression $codeBlock
    $actualOutput "should be" $expectedOutput
}
```
Result in the console
```
18/02/2019 15:44:48
should be
18/02/2019 15:44:48

```

💡Improvent idea: Convert these into dynamic pester tests

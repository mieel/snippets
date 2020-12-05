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

          $expectedOutput = Invoke-Expression ($Example.Assertion | Out-String)
          $actualOutput = Invoke-Expression $Example.Scriptblock

          Compare-Object $actualOutput $expectedOutput
    #>
    param(        
        [parameter(Mandatory=$true)]
        [string] $Command
        ,
        [string] $Module
    )
    $help = Get-Help $Command -Examples
    if (-not $help.examples) { return }
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

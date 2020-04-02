Function Test-CronRange {
    <#
        .EXAMPLE
            # * always passes
            Test-CronRange -Range '*' -InputValue 10 -Verbose
            # a min-max range
            Test-CronRange -Range '1-15' -InputValue 10 -Verbose
            # stepped value
            Test-CronRange -Range '*/15' -InputValue 30 -verbose
            # A specific value list
            Test-CronRange -Range '2,5,8,9' -InputValue 10 -verbose

            Test-CronRange -Range '*/4' -InputValue 60 -verbose
    #>
    [cmdletbinding()]
    param(
        [ValidatePattern("^[\d-*/,]*$")]
        [string]$range
        ,
        [int]$inputvalue
    )
    Write-Verbose "Testing $range"
    If ($range -eq '*') {
        Return $true
    }
    If ($range -match '^\d+$') {
        Write-Verbose 'Specific Value(int)'
        Return ($inputvalue -eq [int]$range)
    }
    If ($range -match '[\d]+-[\d]+([/][\d])*') {
        Write-Verbose 'min-max range'
        [int]$min, [int]$max = $range -split '-'
        Return ($inputvalue -ge $min -and $inputvalue -le $max)
    }
    If ($range -match ('([*]+|[\d]+-[\d]+)[/][\d]+')) {
        Write-Verbose 'Step Value'
        $list, $step = $range -split '/'
        Write-Verbose "Using Step of $step"
        $IsInStep = ( ($inputvalue/$step).GetType().Name -eq 'Int32' )
        Return ( $IsInStep )
    }
    If ($range -match '(\d+)(,\s*\d+)*') {
        Write-Verbose 'value list'
        $list = @()
        $list = $range -split ','
        Return ( $list -contains $InputValue )
    }    
    Write-Error "Could not process Range format: $Range"
}
Function Get-CronNextExecutionTime {
    <#
        .SYNOPSIS
            Currently only support * or digits
            todo: add support for ',' '-' '/' ','
        .EXAMPLE
            Get-CronNextExecutionTime -Expression '* * * * *'
            Get-CronNextExecutionTime -Expression '5 * * * *'
            Get-CronNextExecutionTime -Expression '* 13-21 * * *'
            Get-CronNextExecutionTime -Expression '15 14 * 1-3 *'
            Get-CronNextExecutionTime -Expression '15 14 * * 4'
            Get-CronNextExecutionTime -Expression '15 14 * 2 *'
            Get-CronNextExecutionTime -Expression '15 14 * * *'
            Get-CronNextExecutionTime -Expression '15 14 * * 1-2'
    #>
    [cmdletbinding()]
    param(
        [string]
        $Expression = '* * * * *'
        ,
        $InputDate
    )
    # Split Expression in variables and set to INT if possible
    $cronMinute, $cronHour, $cronDay, $cronMonth, $cronWeekday = $Expression -Split ' '
    Get-Variable -Scope local | Where-Object {$_.name -like 'cron*'} | ForEach-Object {
        If($_.Value -ne '*') {
            Try {
                [int]$newValue = $_.Value
                Set-Variable -Name $_.Name -Value $newValue -ErrorAction Ignore
            } Catch {}
        }
    }
    # Get the next default Time (= next minute)
    $nextdate = If ($InputDate) { $InputDate } Else { Get-Date }
    $nextdate = $nextdate.addMinutes(1)
    $next = [ordered]@{
        Minute  = $nextdate.Minute
        Hour    = $nextdate.hour
        Day     = $nextdate.day
        Weekday = $nextdate.DayOfWeek.value__
        Month   = $nextdate.month
        Year    = $nextdate.year
    }
    # Increase Minutes until it is in the range.
    # If Minutes passes the 60 mark, the hour is incremented
    $done= $false
    Do {
        If ((Test-CronRange -InputValue $next.Minute -range $cronMinute)-eq $False) {
            Do {
                $next.Minute++
                If ($next.Minute -gt '60') { 
                    $next.Minute = 0
                    $next.Hour++
                }
            } While ( (Test-CronRange -InputValue $next.Minute -range $cronMinute) -eq $False )
            continue
        }
        # Check if the next Hour is in the desired range
        # Add a Day because the desired Hour has already passed
        If ((Test-CronRange -InputValue $next.Hour -range $cronHour)-eq $False) {
            Do {
                $next.Hour++
                If ($next.Hour -gt '24') { 
                    $next.Hour = 0
                    $next.Day++
                    $next.Minute = 0
                }
            } While ((Test-CronRange -InputValue $next.Hour -range $cronHour)-eq $False)
            continue
        }
        # Increase Days until it is in the range.
        # If Days passes the 30/31 mark, the Month is incremented
        If ((Test-CronRange -InputValue $next.day -range $cronday)-eq $False) {
            Do {
                $next.Day++
                If ($next.Day -gt '30') {
                    $next.Day = 0
                    $next.Month++
                    $next.Hour = 0
                    $next.Minute = 0
                }
            } While ((Test-CronRange -InputValue $next.day -range $cronday)-eq $False)
            continue
        }
        # Increase Months until it is in the range.
        # If Months passes the 12 mark, the Year is incremented    
        If  ((Test-CronRange -InputValue $next.Month -range $cronMonth)-eq $False) {
            Do {
                $next.Month++
                If ($next.Month -gt '12') {
                    $next.Month = 0
                    $next.Year++
                    $next.Day = 0
                    $next.Hour = 0
                    $next.Minute = 0
                }
            } While ((Test-CronRange -InputValue $next.Month -range $cronMonth)-eq $False)
        }
        $done = $true
    } While ($done -eq $false)
    $datestring = "{0}-{1:00}-{2:00} {3:00}:{4:00}" -f $next.year, $next.month, $next.day, $next.hour, $next.Minute
    $date = [datetime]::ParseExact($datestring,"yyyy-MM-dd HH:mm",$null)
    If (!$date) { Throw 'Could not create date'}
    
    # Add Days until weekday matches
    If ((Test-CronRange -InputValue $Date.DayOfWeek.value__ -Range $cronWeekday) -eq $false) {
        Do {
            $Date = $Date.AddDays(1)                
        } While ( (Test-CronRange -InputValue $Date.DayOfWeek.value__ -Range $cronWeekday) -eq $false )
    }
    Return $Date
}



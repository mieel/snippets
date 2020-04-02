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
            Get-CronNextExecutionTime -Expression '0 1-15 * * *'
            Get-CronNextExecutionTime -Expression '15 14 * * *'
            Get-CronNextExecutionTime -Expression '15 14 * * 4'
            Get-CronNextExecutionTime -Expression '15 14 * 2 *'
            Get-CronNextExecutionTime -Expression '15 14 * * *'
            Get-CronNextExecutionTime -Expression '15 14 * * 1-2'
    #>
    [cmdletbinding()]
    param(
        [string]
        $Expression = '1 2 3 4 5'
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
            } Catch {

            }
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
    $done = $false
    $i = 0
    Do {
        $i++
        If($i -gt 1000) { 
            $datestring = "{0}-{1:00}-{2:00} {3:00}:{4:00}" -f $next.year, $next.month, $next.day, $next.hour, $next.Minute
            $datestring
            Throw 'Something is wrong, stuck in loop' 
        }
        Write-Debug $("{0}-{1:00}-{2:00} {3:00}:{4:00}" -f $next.year, $next.month, $next.day, $next.hour, $next.Minute)
        if ($cronMinute -ne '*' -and $next.minute -ne $cronMinute) {
            if ($next.minute -gt $cron.minute -and ( (Test-CronRange -InputValue $next.hour -range $cronHour) -eq $false) ) {
                $next.Hour++
            }
            $next.Minute = $cronMinute        
        }
        if ($cronHour -ne '*' -and ( (Test-CronRange -InputValue $next.hour -range $cronHour) -eq $false) ) {
            # Add a Day because the desired Hour has already passed
            if ((Test-CronRange -InputValue $next.hour -range $cronHour) -eq $false) {
                Do {
                    $next.Hour++
                } While ((Test-CronRange -InputValue $next.hour -range $cronHour)-eq $true)
                $next.Day++
                $next.Minute = 0            
                continue
            }
            $next.Hour++
            $next.Minute = 0
            continue
        }   
        if ($cronDay -ne '*' -and ( (Test-CronRange -InputValue $next.day -rang $cronDay) -eq $false) ) {
            # Add a Year if the desired Month already has passed
            if ($next.day -gt $cronDay) {
                $next.Month++
                $next.day = 1 #assume days 1..31
                $next.hour = 0
                $next.minute = 0
                continue
            }
            $next.day = $cronDay
            $next.hour = 0
            $next.minute = 0
            continue
        }
        if ($cronMonth -ne '*' -and ( (Test-CronRange -InputValue $next.hour -rang $cronHour) -eq $false) ) {
            if ($next.Month -gt $cronMonth) {
                $next.Month++
                $next.Year++
                $next.Day = 1 # assume days 1..31
                $next.Hour = 0
                $next.Minute = 0
                continue
            }
            $next.month = $cronMonth;
            $next.day = 1
            $next.hour = 0
            $next.minute = 0
            continue
        }
        $done = $true
       
    } While ($done -eq $false)
    $datestring = "{0}-{1:00}-{2:00} {3:00}:{4:00}" -f $next.year, $next.month, $next.day, $next.hour, $next.Minute
    $date = [datetime]::ParseExact($datestring,"yyyy-MM-dd HH:mm",$null)
    If (!$date) { Throw 'Could not create date'}
    if ($cronWeekday -ne '*') {
        # Add Days until weekday matches        
        Do {
            $Date = $Date.AddDays(1)
            $InRange = Test-CronRange -InputValue $Date.DayOfWeek.value__ -Range $cronWeekday            
        } While ( $InRange -eq $false )
    }
    Return $Date
}



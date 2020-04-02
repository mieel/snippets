Function Get-NextCronTime {
    param(
        $cron
    )
    $cronMinute, $cronHour, $cronDay, $cronMonth, $cronWeekday = $cron -Split ' '

    $nextdate = (get-date).addMinutes(1)
    $next = [ordered]@{
        Minute = $nextdate.Minute
        Hour = $nextdate.hour
        Day = $nextdate.day
        Weekday = $nextdate.DayOfWeek.value__
        Month = $nextdate.month
        Year = $nextdate.year
    }

    $done = $false
    Do {
    if ($cronMinute -ne '*' -and $next.minute -ne $cronMinute) {
        if ($next.minute -gt $cron.minute) {
            $next.Hour++            
        }
        $next.Minute = $cronMinute        
    }
    if ($cronHour -ne '*' -and $next.hour -ne $cronHour) {
        if ($next.Hour -gt $cronHour) {
            $next.Hour = $cronHour
            $next.Day++
            $next.Minute = 0            
            continue
        }
        $next.Hour = $cronHour
        $next.Minute = 0
        continue
    }   
    if ($cronDay -ne '*' -and $next.day -ne $cronDay) {
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
    if ($cronMonth -ne '*' -and $next.month -ne $cronMonth) {
        if ($next.month -gt $cronMonth) {
            $next.Month += (12-$next.month+$cronMonth)
            $next.day = 1 # assume days 1..31
            $next.hour = 0
            $next.minute = 0
            continue
        }
        $next.month = $cronMonth;
        $next.day = 1
        $next.hour = 0
        $next.minute = 0
        continue
    }
    $done = $true
    
    } While ( $done -eq $false )
    $datestring = "{0}-{1:00}-{2:00} {3:00}:{4:00}" -f $next.year, $next.month, $next.day, $next.hour, $next.Minute
    $date = [datetime]::ParseExact($datestring,"yyyy-MM-dd HH:mm",$null)

    if ($cronWeekday -ne '*') {
        # Add Days until weekday matches
        Do {
            $Date = $Date.AddDays(1)
        } While ($Date.DayOfWeek.value__ -ne $cronWeekday)
    }
    Return $Date
}
$cron = '* * * * *'
Get-NextCronTime -Cron $cron

$cron = '0 10 * * 3'
Get-NextCronTime -Cron $cron

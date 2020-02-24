# Dates and Times
## Dates
```
import datetime

d = datetime.date(2016, 7, 24)
print(d)                                          # 2016-07-24 🚦 dont pad numbers

today = datetime.date.today()
print(today.day)
print(today.weekday())                              # 0 - 6
print(today.isoweekday())                         # 1- 7

```
## Deltas
```
tdelta = datetime.timedelta(days=7)
print (today + tdelta)                             # the date 7days after today

date2 = date1 + timedelta                          # results a date
timedelta = date1 + date2                          # results a timedelta
        
birthday + datetime.date(2016,9,24)
till_bday = birthday - today
print(till_bday)                                   #  60 days
print(till_bday.total_seconds())                   #  5~mill seconds
```
## Times
```
t = datetime.time(9,30,45,100000)             
print(t.hour)

dt = datetime.datetime(2016,7,26,12,30,45,10000)
print(dt)                                         # 2016-07-26 23:30:45

tdelta = datetime.timedelta(days=7)
print(dt + tdelta)

tdelta = datetime.hours(days=12)
```
## Timezones
```
dt_today = datetime.datetime.today()              # current local timezonde
dt_now = datetime.datetime.now()                  # has  an option to supply timezone
dt_utcnow = datetime.datetime.utcnow()            # current utcnow, supply timezone

..
import pytz                                       # 👌 use utc as best practice
dt = datetime.datetime(2016,7,26,12,30,45,tzinfo=pytz.UTC)
print(dt) # 2016-07-26 23:30:45+00+00             # no ms

dt_utcnow = datetime.datetime.now(pytz.UTC)
print(dt) # 2016-07-26 23:30:45.1212312+00+00     # with milliseconds

#converting
dt_mtn = dt_utc.astimezone(pytz.timezone('US/Mountain'))

# list all timezones
for tz in pytz.all_timezones:
  print(tz)

# make local time timezone aware
dt_now = datetime.datetime.now()                   # converting will result in error 
mtn_tz = pytz.timezone('US/Mountain')

dt_mtn = mtn_tz.localize(dt_mtn)                    # localize to add timezone
dt_eat = dt_mtn.astimezone(pytz.timezone('US/Estern')) # now we can convert



```
## Date Strings
```
print(dt.isoformat())                           # look online for formatting codes
print(strftime(dt, '%B %d, %Y')                 # Format to string 'July 26, 2016'

dt_str = 'July 26, 2016'
dt = datetime.datetime.strptime(dt, '%B %d, %Y') # Parse back to date
```

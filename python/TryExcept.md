```
try:
  f = open('testfile.txt')
except Exception:
  print('Sorry. This file doesnt exist')
```
This is better, use more speficic Exception types
```
try:
  f = open('testfile.txt')
except FileNotFoundError:
  print('Sorry. This file doesnt exist')
```
more handling
```
try:
  f = open('testfile.txt')
except FileNotFoundError:
  print('Sorry. This file doesnt exist')
except Exception:
  print('sorry. something went wrong')
```
output error in variable
```
try:
  f = open('testfile.txt')
except FileNotFoundError e:
  print(e)
except Exception as e::
  print(e)
```

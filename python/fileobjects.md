#File Management
## open file

`f = open('test.txt', 'r')`

`print(f)`

`f.close() #close file when done!`
### using context manager
```
with open ('test.txt','r') as f:
  f_contents = f.read() # Read entire file
  print(f_contents)

with open ('test.txt','r') as f:
  f_contents = f.readlines() #as list
  print(f_contents)

with open ('test.txt','r') as f:
  f_contents = f.readline() # line by one
  print(f_contents, end='')
  
with open ('test.txt','r') as f:  
  # more efficient read entire file
  for line in f:
    print(line,end='') 

with open ('test.txt','r') as f:
  # Read first 100 chars from file
  f_contents = f.read(100) 
  print(f_contents)
  
  # Read the next 100 chars from file
  f_contents = f.read(100) 
  print(f_contents)
  
with open ('test.txt','r') as f:
  
  size_to_read = 10
  
  f_contents = f.read(size_to_read ) 
  while len(f_contents) > 0:
    print(f_contents, end='*')
    f_contents = f.read(size_to_read)
    
    # index of char
    print(f.tell())
    
    # set position
    f.seel(0) # beginning of file
    
  print(f_contents)
  
  # Read the next 100 chars from file
  f_contents = f.read(100) 
  print(f_contents)
print(f.closed)

print(f.read) # should print error because file is closed
```
## Writing files
### basic write
`with open('test2.txt','w') as f: # use 'a' to append instead of write
  f.write('Test')`
### create empty file
`with open('test2.txt','w') as f:
  pass`
## Read and write
```
with open('test', 'r') as rf:
  with open('test_copy.txt', 'w') as wf: # you can put this on the same line, but is better readable
    for line in rf:
      wf.write(line)
```     
    

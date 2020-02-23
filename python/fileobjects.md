# File Management
https://www.youtube.com/watch?v=ve2pmm5JqmI&list=PL-osiE80TeTt2d9bfVyTiXJA-UTHn6WwU&index=26
## Open Files

`f = open('test.txt', 'r')`

`print(f)`

`f.close() #close file when done!`
### using context manager
Context manager automatically closes the file after a block
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
### Picture files
```
with open('picture.jpg', 'r') as rf:
  with open('picture.jpg', 'w') as wf: # you can put this on the same line, but is better readable
    for line in rf:
      wf.write(line)
```   
This does not work, we to open binary `b`
```
with open('picture.jpg', 'rb') as rf:
  with open('picture.jpg', 'wb') as wf: # you can put this on the same line, but is better readable
    for line in rf:
      wf.write(line)
```   
In chunks
```
with open('picture.jpg', 'rb') as rf:
  with open('picture.jpg', 'wb') as wf: # you can put this on the same line, but is better readable
    chunk_size = 4096
    rf_chunk = rf.read(chunk_size)
    while len(rf_chunk) > 0:
      wf.write(rf_chunk)
      rf_chunk - rf.read(chunk_size)      
```  

## Parse and rename files
Original file format:
title-course-number

```
import os # for file manipulation

os.chdir('path/to/folder')

print(os.getcwd()) # get current working directory

for f in os.listdir():
  print(f) # list files
  print(os.path.splitext(f)) # generates a tuple with filename, fileextension
  
  file_name, file_ext = os.path.splitext(f)
  print(file_name)
  print(file_ext)
  
  print(file_name.split('-') # split a string into chunks using - as separator
  
  f_title = f_title.strip # trim spaces  
  f_num = f_num[1:] # skip the first character
  f_num = f_num.zfill(2) # pad integer so it is sortable
  
  new_name = ('{}-{}-{}{}'.format(f_num,f_cource_f_title_,f_ext)
  
  os.rename.(f, new_name) # rename
  
  

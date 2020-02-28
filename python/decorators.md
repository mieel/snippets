## Decorators
### Closures
```
def out er_function():
    message = 'Hi'
    
    def inner_function():
        print(message)
    return inner_function()
outer_function()
# Hi
```


```
def outer_function():
    message = 'Hi'
    
    def inner_function():
        print(message)
    return inner_function()
    
outer_function
# output is a function
```
You need to call it
```
my_func = outer_function()
my_func()
# HI
```

```
def outer_function(msg):    
    def inner_function():
        print(msg)
    return inner_function()

# Hi
```
### Decorators
```
# This is a Closure
def outer_function(msg):    
    def inner_function():
        print(msg)
    return inner_function()
    
# This is a decorator
def decorator_function(original_function):    
    def wrapper_function():
        print('wrapper add this line to'.format(original_function.__name__))
        original_function()
    return wrapper_function
 
def display()
    print('display function')
    
decorator_display = decorator_function(display)
decorator_display()   # should be output of display function

# alternative notation
@ decorator_function
def display()
    print('display function')
    
```
Why? Allows to add functionality to existing functions.


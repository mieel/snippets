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
    
 display() # outputs the decorated original function
    
```
Why? Allows to add functionality to existing functions.

Practical Example
```


def my_logger(orig_func):
    import logging
    logging.basicConfig(filename='{}.log'.format(orig_func.__name__), level=logging.INFO)

    @wraps(orig_func)
    def wrapper(*args, **kwargs):
        logging.info(
            'Ran with args: {}, and kwargs: {}'.format(args, kwargs))
        return orig_func(*args, **kwargs)

    return wrapper


def my_timer(orig_func):
    import time

    @wraps(orig_func)
    def wrapper(*args, **kwargs):
        t1 = time.time()
        result = orig_func(*args, **kwargs)
        t2 = time.time() - t1
        print('{} ran in: {} sec'.format(orig_func.__name__, t2))
        return result

    return wrapper

import time


@my_logger
@my_timer
def display_info(name, age):
    time.sleep(1)
    print('display_info ran with arguments ({}, {})'.format(name, age))

display_info('Tom', 22)
```




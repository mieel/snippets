```
def square_number(nums):
    for i in nums:
        yield(i*i) # this makes it a generator
        
 my_nums = square_numbers([1,2,3,4,5])
 
 print next(my_nums)
 print next(my_nums)
 print next(my_nums)
 print next(my_nums)
 print next(my_nums)
 print next(my_nums)                # Error 
```
You can use for loop
```
for num in my_nums:
    print num
```
list comprehension
```
my_nums = [x*x for x in [1,2,3,4,5]]
for num in my_nums:
    print num
```
putting it in between brackters makes it a generator
```
my_nums = (x*x for x in [1,2,3,4,5])
for num in my_nums:
    print num
```
Generators are good for performance because not all the values are stored in memory at a time

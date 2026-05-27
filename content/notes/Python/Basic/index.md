---
title: "Basic"
subtitle: ""
date: 2026-05-26T20:39:42+08:00
lastmod: 2026-05-26T20:39:42+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Python']
categories: ['IT']

featuredImage: ""
featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
  keepStatic: false
code:
  copy: true
  maxShownLines: 50
math:
  enable: true
  # ...
mapbox:
  # ...
share:
  enable: true
  # ...
comment:
  enable: true
  # ...
library:
  css:
    # someCSS = "some.css"
    # located in "assets/"
    # Or
    # someCSS = "https://cdn.example.com/some.css"
  js:
    # someJS = "some.js"
    # located in "assets/"
    # Or
    # someJS = "https://cdn.example.com/some.js"
seo:
  images: []
  # ...
---

## Function Arguments

### 1. Positional, positional expansion, keyword, keyword expansion

```python
def f1(a, b, *args, c=3.0, d="four", **kwargs):
    print(f"a={a}, b={b}, args={args}, c={c}, d={d}, kwargs={kwargs})")

f1(1, "2", 2.1, "2.2", c=3, d="IV", e=5, f="six")
```

```bash
:!python src/lang/basic_test.py
a=1, b=2, args=(2.1, '2.2'), c=3.01, d=IV, kwargs={'e': 5, 'f': 'six'})
```

**NOTE:** Positional arguments are collected into a tuple, here `args`.
Why not a list but a tuple?

- **Immutability**
  - Tuples are **immutable**.
- **Performance**
  - Tuples are **slightly faster** to create and access than lists
  - Tuples are **lighter weight** in memory overhead
- **Hashability**
  - Tuples are hashable (if all elements are hashable), lists are not
  - A tuple (immutable) can be used as a dict key
- **Semantic meaning**
  - Tuples represents **fixed collections**
  - List represents **mutable sequences** (grows or shrinks)


### 2. Positional arguments come before keyword arguments

#### 2.1 Positional arguments cannot follow keyword arguments

```python
def f2_1(c=3.0, d="four", **kwargs, a, b, *args): ...   # ❌ `a` after **
```

#### 2.2 Non-default argument cannot follow default arguments

```python
def f2_2(c=3.0, a, b, *args): ...                       # ❌ `a` after `c=3.0`
```


### 3. Alert from static type checker

When default value type is smaller than parameter type,

```python
def f3_1(a = 3.0):
    print(f'a={a}')

f3_1(4.0) # ✅, a=4.0
f3_1(4)   # ✅, a=4

def f3_2(a = 3):
    print(f'a={a}')

f3_2(4)   # ✅, a=4

# ⚠️warning from static type checker:
# "float" is not assignable to "int" [reportArgumentType]
f3_2(4.0) # ✅, a=4.0, duck typing, although static type checker warning
```

### 4. `/` Positional-only separator, `*`  Keyword-only separator

- Parameters before `/` must be passed by position; you cannot use keyword
  syntax for them.
- Parameters after `*` must be passed by keyword; you cannot pass them
  positionally.
- Parameters sit in the middle zone and accepts both styles:

```python
def f4(pos_only, /, normal, *, kw_only): ...

f4(1, 2, kw_only=3)         # ✅, normal accepts positional parameter
f4(1, normal=2, kw_only=3)  # ✅, normal accepts keyword parameter
f4(pos_only=1, norml = 2, kw_only = 3) # ❌ TypeError, positional-only but kw
f4(1, 2, 3) # ❌ TypeError, Keyword-only but positional

def f(a):...

f(1)    # ✅, positional
f(a=1)  # ✅, keyword
```

**NOTE:** Languages like C, Java, Lua don't support keyword arguments. Lua is
a bit of a special case —  it doesn't have keyword arguments natively, but
people often simulate them by passing a table:

```lua
local greet = function (g)
  print(g.welcome .. ", " .. g.name .. "!")
end

greet({name = "Messi", welcome = "Hola"})
```

## List/Tuple/Dict


| Type    | Mutable | Hashable                       |
|---------|---------|--------------------------------|
| `list`  | ✅       | ❌                              |
| `dict`  | ✅       | ❌                              |
| `set`   | ✅       | ❌                              |
| `tuple` | ❌       | ✅ (if elements are hashable)  |
| `str`   | ❌       | ✅                              |
| `int`   | ❌       | ✅                              |


### Tuple's Immutability and Hashability

Tuples are immutable while list can shrink and grow. A tuple is hashable only
if all of its elements are hashable.

```python
t = (1, 2, "apple")
print(hash(t))  # change every time, e.g. 4150238736300707661
l = [1, 2, "apple"]
hash(l) # ❌, list is not hashable
```

### Only tuples can used as dict keys

The key rule:
- **If an object can change, its hash value would change**
- **If the hash value changes, dictionaries/sets can't find it anymore**

Example of the problem with mutable objects:

```python
my_list = [1, 2, 3]
my_dict = {my_list: "value"}  # Imagine this worked

my_list.append(4)  # Now the list changed
# The hash changed, so my_dict can't find the key anymore!
# This would break the entire dictionary data structure.
```

Dictionary keys can be **any hashable type**:
```python
# Valid dictionary keys
my_dict = {
    "string_key": 1,      # ✅ Strings are hashable
    42: 2,                # ✅ Integers are hashable
    (1, 2): 3,            # ✅ Tuples are hashable
    frozenset([1, 2]): 4, # ✅ Frozensets are hashable
}
```

**NOTE:** Since the random seed is generated at interpreter startup, a new
hash value is computed on each run.

```bash
> python -c "print(hash('apple'))"
4162066787311949958
> python -c "print(hash('apple'))"
-7455757878238628742
> python -c "print(hash('apple'))"
977427783537403968
```

### Set: operations (`|`, `&`, `-` and `^`)

```python
a = {1, 2, 3}
b = {3, 4, 5}

print(a | b)  # Union: {1, 2, 3, 4, 5}
print(a & b)  # Intersection: {3}
print(a - b)  # Difference: {1, 2}
print(a ^ b)  # Symmetric difference: {1, 2, 4, 5}
```

## Typing

### Dynamic typing:

- **Dynamic typing**: Types are checked at runtime (Python)
- **Static typing**: Types are checked before runtime (Java, C++)
- **Weak typing**: Implicit type conversions (JavaScript: `"5" - 3` → `2`)
- **Strong typing**: No implicit conversions (Python: `"5" - 3` → `TypeError`)

Python is **dynamically typed** AND **strongly typed**. It's not weakly typed.


| Typing | When Types Are Checked | Example Languages |
|--------|----------------------|-------------------|
| Static | Before runtime (compile time) | Java, C++, Rust |
| Dynamic | At runtime | Python, JavaScript, Ruby |


```python
# Python (dynamic typing)
x = 5        # x is int
x = "hello"  # Now x is str — perfectly fine!
```

### Duck Typing

**Duck typing** is a programming philosophy focused on **behavior over type**:

> "If it walks like a duck and quacks like a duck, then it must be a duck."

### Relationship Between Them

| Concept | Focus | Question It Answers |
|---------|-------|---------------------|
| **Dynamic typing** | When types are checked | "When does Python check types?" |
| **Duck typing** | How types are used | "What does Python care about?" |


**Duck typing is a consequence of dynamic typing**:
- Because Python checks types at runtime, it can afford to care about behavior
rather than declared types
- If an object has the right methods, Python doesn't care what class it
belongs to

### Example Showing Both:

```python
# Dynamic typing: x can change type at runtime
x = 5
x = "hello"

# Duck typing: function cares about behavior, not type
def add(a, b):
    return a + b

add(1, 2)           # 3 (int addition)
add("hello", "world")  # "helloworld" (string concatenation)
add([1], [2])       # [1, 2] (list concatenation)
```

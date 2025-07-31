---
title: "C"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['C']
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

## IDE Neovim Lsp Configuration for a C project

### generate compile_commands.json [1]

```sh
make clean; bear -- make
```

### generate .clang-format [2]

```sh
clang-format -style=llvm -dump-config > .clang-format
```

#### By default, `IndentWidth: 2`

## Use gcc/clang to check "include" search pathes on both macOS and Linux

```sh
gcc/clang -xc -E -v -
```

## puts vs printf

1. puts only output strings, while printf is for format
2. puts adds "\n" in the end automatically, while printf does not.
3. performance

E.g.

```c
    for (int i = 0; i < loop; i++) {
        puts(msg);
    }

    for (int i = 0; i < loop; i++) {
        printf("%s\n", msg);
    }

/*
 * Profiling test_puts: 1000000 msg:[Messi]: Time used: 0.061672
 * Profiling test_printf: 1000000 msg:[Messi]: Time used: 0.061735
 */
```

## Recursive call depth

Call depth is limited by stack size. Segment fault occurs when recursive call
goes too deep, i.e. stack overflow. On macOS, the default stack size limit is
8MB. It can be increased to its hard limit 64MB.

```sh
ulimit -s
8192    (KBytes)

ulimit -Hs
65532   (KBytes)
```

Program built in release, optimized mode, stack frame smmaller, depth is deeper.
Program built in debug, unoptimized mode, stack frame bigger, depth is shallower.

Because, program built in optimized mode, like Tail Call Optimization(TCO,
recursive call to iteration), inlining(replacing calls with acutal code, no
stack frames needed). Program built in debug mode needs to add debug symbols.

## ISO C

### <stdarg.h> defined by C compiler GCC/Clang
Although <stdarg.h> is part of the C standard, it is not provided by the C
standard library (glibc/macOS SDK), because it must reflect compiler
internals and ABI-specific details. So the compiler (GCC/Clang) provides it.

## grammar

### keywords

#### restrict

- since `C99`
- a contract between the programmer and the compiler
- applies only to pointers, promises the compiler the pointer is the only way
  to access the memory it points to during its lifetime (i.e., no other
  pointers alias the same memory).
- common usage: memcpy(3), stat(2)

With `restrict` the compiler can assure no aliasing, enabling aggressive
optimization (e.g., reordering instructions, cache values in registers).

### typedef

#### function pointer type

Instead of use the below line to define a function pointer that points to
a function returns a value of `int` type and accepts parameters of type
`const char*` and `int*`.

```c
int (*fp) (const char*, int*);
```

A more readable and less error-prone way is to use `typedef`

```c
typedef int Myfunc(const char*, int*);
Myfunc fp;
```

This separates the definition of the function pointer type from the
declaration of variables of that type, which is a common best practice for
complex types in C.

[1]: https://clangd.llvm.org/installation#compile_commandsjson
[2]: https://clang.llvm.org/docs/ClangFormat.html#standalone-tool

[Mindmap]( /mindmaps/apue/c.html )

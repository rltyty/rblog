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

tags: ['C', 'Unix']
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


### include glibc source to navigate with clangd

#### Build glibc source and generate compile_commands.json

##### Install build essentials
```sh
sudo apt install -y make gcc texinfo make binutils gawk bison perl sed \
  python3 python3-pexpect autoconf gettext
```

##### Build

```sh
cd $SRC_ROOT

mkdir build
cd build
../configure --prefix=$SRC_ROOT/install
bear -- make -j$(nproc)
# make install          # no need if only navigate sources in editor
```

#### Configure up project specific `.clangd`

```yaml
CompileFlags:
  CompilationDatabase: /home/<user>/<path-to-glibc-src-root>/build
  Add: [
    # Include glibc source headers (to enable jump to implementation)
    -I/home/<user>/<path-to-glibc-src-root>/include,
    -I/home/<user>/<path-to-glibc-src-root>,
    -I/home/<user>/<path-to-glibc-src-root>/sysdeps/unix/sysv,
    -I/home/<user>/<path-to-glibc-src-root>/sysdeps/unix/sysv/linux,

    # Clang built-in headers, change to your version
    -isystem/usr/lib/llvm-22/lib/clang/22/include,

    # System libc headers (searched after your glibc sources)
    -isystem/usr/include,
    -isystem/usr/local/include
  ]
```
#### Navigate `<C-]>`

Example:

```c
#include <signal.h>

int main(int argc, char *argv[]) {
...
  sigaddset(&set, SIGQUIT);
...
}
```
To inspect `sigaddset()` implementation code, navigation order:

`glibc-2.36/signal/signal.h`
`glibc-2.36/signal/sigaddset.c`
`glibc-2.36/sysdeps/unix/sysv/linux/sigsetops.h`

```c

#define __sigmask(sig) \
  (1UL << (((sig) - 1) % ULONG_WIDTH))

static inline unsigned long int
__sigword (int sig)
{
  return (sig - 1) / ULONG_WIDTH;
}

static inline void
__sigaddset (sigset_t *set, int sig)
{
  unsigned long int mask = __sigmask (sig);
  unsigned long int word = __sigword (sig);
  set->__val[word] |= mask;
}
```

`/usr/include/limits.h`

```c
# ifndef ULONG_WIDTH
#  define ULONG_WIDTH __WORDSIZE
# endif
```

`glibc-2.36/sysdeps/x86/bits/wordsize.h`

```c
#if defined __x86_64__ && !defined __ILP32__
# define __WORDSIZE	64
#else
# define __WORDSIZE	32
#define __WORDSIZE32_SIZE_ULONG		0
#define __WORDSIZE32_PTRDIFF_LONG	0
#endif
```


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

#### `restrict`

- since `C99`
- a contract between the programmer and the compiler
- applies only to pointers, promises the compiler the pointer is the only way
  to access the memory it points to during its lifetime (i.e., no other
  pointers alias the same memory).
- common usage: memcpy(3), stat(2)

With `restrict` the compiler can assure no aliasing, enabling aggressive
optimization (e.g., reordering instructions, cache values in registers).

#### `volatile`

Tells the compiler don't optimize this variable or cache its value.

Compiler optimizations block includes:

- No register caching: Every read/write goes to memory.
- No reordering: Operations stay in program order (but CPU may still reorder;
  use barriers if needed).

Mainly used for:
- Variables shared with signal handlers
- Multi-threaded variables (though `atomic`, mutex are preferred)
- Memory-mapped hardware registers

#### `sizeof`

```c
int a[108];
assert(432 == sizeof(a));
assert(8 == sizeof(&a[0]); // the address of the 1st element, a pointer type
```

When an array is in an expression or passed to a function, it is decayed to a
pointer.

```c
int a[108];
assert(8 == sizeof(a+1))

void f(int a[]) {
  assert(8 == sizeof(a))
}
```
Compiler will show warnings for the two usages above ("-Wsizeof-array-decay",
"-Wsizeof-array-argument")

Thus, use pointer instead of array as function parameter.

```c
void f(int *a) { ; }
```

#### `typedef`

##### function pointer type

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

### Array declaration and initialization

```c
int numbers[5] = {10, 20, 30, 40, 50}; // Full initialization
int numbers[5] = {10, 20}; // Partial (rest zero-initialized)
int numbers[] = {10, 20, 30}; // Omitted size (compiler determines)
int numbers[5] = {[2] = 30, [0] = 10}; // Designated initializers (C99+)
```

In C, there is no `new` like C++, `int a[]` is used for declaring an array
whose size is determined at compile time. Compilation error occurs in below
code.
```c
// int a[] = calloc(size, sizeof(int));    // ❌ WRONG!
```

Dynamic allocation using pointer to refer to the address.

```c
int *a = (int *)calloc(size, sizeof(int));

if (a == NULL) {
  return EXIT_FAILURE;
}

for (int i = 0; i < size; i++) {
  printf("%d ", a[i]); // Access elements using array-like indexing
}
printf("\n");

free(a);
```

Similarly in C++,

```c++
// int a[] = new int[5];        // ❌ WRONG!
int *a = new int[5];            // uninitialized
int *a = new int[5]();          // zero-initialized
int *a = new int[5]{};          // zero-initialized

delete[] a;                     // match: new - delete, malloc/calloc - free
a = nullptr;
```

## Library functions

### `malloc(3)`, `calloc(3)`, `realloc(3)`, `free(3)`

```c
#include <stdlib.h>

void *
malloc(size_t size);                // garbage values unless memset
                                    // raw memory, full control by yourself

void *
calloc(size_t count, size_t size);  // zero-initialized, e.g. array, struct or
                                    // buffer

void *
realloc(void *ptr, size_t size);    // if ptr != NULL and size == 0, ~ free(ptr)
                                    // if ptr == NULL, ~ malloc(size)
                                    // if size < original, memory shrunk, but
                                    // the returned pointer might not be the
                                    // same as the passed-in ptr
                                    // if ptr points to memory allocated by
                                    // calloc, extended memory is not
                                    // guaranteed zero-initialized

void
free(void *ptr);                    // get the size from allocator metadata
```


#### Allocation Metadata

The actual memory allocated is a bit larger than the requested amount for save
the metadata. `free(3)` can use `ptr` returned by `malloc(3)`, `calloc(3)` and
`realloc(3)` to compute the metadata address, where the size is retrieved to
collect the memory allocated.

    +-------------------------------------------------+
    |  Allocator Metadata (e.g., size, status, etc.)  |
    +-------------------------------------------------+
    |                 Usable Memory Block             | <-- `ptr` points here
    |                 (your requested `size` bytes)   |
    +-------------------------------------------------+

#### `realloc(3)

Even if memory is shrunk when the size passed to `realloc(3)` is smaller than
the original size, the returned pointer might not be the same as the `ptr`
passed to `realloc(3)`. Thus,

- Bad practice

```c
// BAD practice: risk of memory leak if realloc fails
// ptr = realloc(ptr, new_size); // If realloc fails and returns NULL, original ptr is lost!
```

- Godd practice
```c
// GOOD practice:
void *temp_ptr = realloc(ptr, new_size);
if (temp_ptr == NULL && new_size != 0) { // realloc(ptr, 0) is like free, returns NULL
    // Reallocation failed, original ptr is still valid and unchanged
    perror("realloc failed");
    // Handle error, maybe free original_ptr here or keep using it
} else {
    // Reallocation succeeded, update your pointer
    ptr = temp_ptr;
}
```


[1]: https://clangd.llvm.org/installation#compile_commandsjson
[2]: https://clang.llvm.org/docs/ClangFormat.html#standalone-tool


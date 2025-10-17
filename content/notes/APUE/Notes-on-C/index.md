---
title: "Notes on C"
subtitle: ""
date: 2025-10-16T15:26:49+08:00
lastmod: 2025-10-16T15:26:49+08:00
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

markmap:
  initialExpandLevel:
    - 2     # only leaf node collapsed
---

<!--more-->
## [View Source Code of C/C++/Rust & Dart Projects]( https://codebrowser.dev )

- [Glibc](https://codebrowser.dev/glibc/glibc/)
- [Linux](https://codebrowser.dev/linux/linux/)
- [Boost](https://codebrowser.dev/boost/boost)
- [LLVM](https://codebrowser.dev/llvm)
- [GCC](https://codebrowser.dev/gcc)
- [GTK](https://codebrowser.dev/gtk/gtk)
- [Qt6](https://codebrowser.dev/qt6/)
...

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

### Download macOS Libc and xnu kernel sources

- **Libc**

  - macOS 12.5: [Github](https://github.com/apple-oss-distributions/Libc/tree/Libc-1507.100.9), [Download](https://github.com/apple-oss-distributions/Libc/archive/Libc-1507.100.9.tar.gz)
    - e.g. `gen/nanosleep.c`
- **xnu**

  - macOS 12.5 [Github](https://github.com/apple-oss-distributions/xnu/tree/xnu-8020.140.41), [Download](https://github.com/apple-oss-distributions/xnu/archive/xnu-8020.140.41.tar.gz)
    - e.g. `kern/kern_sig.c`

- **Libsystem**

  - macOS 12.5: [Github](https://github.com/apple-oss-distributions/Libsystem/tree/Libsystem-1311.120.1), [Download](https://github.com/apple-oss-distributions/Libsystem/archive/Libsystem-1311.120.1.tar.gz)

## Use gcc/clang to dump or check default defined preprocessor macros

```sh
> clang -dM -E - < /dev/null | grep __APPLE__
#define __APPLE__ 1
> clang -dM -E - < /dev/null | grep __DARWIN_UNIX03
>
> clang -dM -E - < /dev/null | grep __linux__
#define __linux__ 1
```

## Use gcc/clang to check "include" search pathes on both macOS and Linux

```sh
gcc/clang -xc -E -v -
```

## Recursive call depth

Call depth is limited by stack size. Segmentation fault occurs when recursive
call goes too deep, i.e. stack overflow. On macOS / Linux, the default stack
size limit is 8MB. It can be increased to its hard limit 64MB.

```sh
ulimit -s
8192    (KBytes)

ulimit -Hs
65532   (KBytes)
```

Program built in release, optimized mode, stack frame smaller, depth is deeper.
Program built in debug, unoptimized mode, stack frame bigger, depth is shallower.

Because, program built in optimized mode, like Tail Call Optimization(TCO,
recursive call to iteration), inlining(replacing calls with acutal code, no
stack frames needed). Program built in debug mode needs to add debug symbols.

## Automatic array size

The size of an automatic array in a function is limited to thread stack size.
The size can be got and set via:
- `ulimit -s [<size>]`
- `getrlimit/setrlimit(RLIMIT_STACK, ...)`

On macOS and Linux (Debian 12):
```bash
> ulimit -a | grep "\-s"
-s: stack size (kbytes)             8192
```

```c
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <unistd.h>

#define _1_GB 1024 * 1024 * 1024
#define _1_MB 1024 * 1024
#define _7_MB 1024 * 1024 * 7
#define _8_MB 1024 * 1024 * 8
#define _9_MB 1024 * 1024 * 9

/**
 * Lazy stack allocation, only reserved but not committed (mapped to the
 * physical page) until being accessed.
 */
void stack_size_test0() {
  /* Declare 1GB array w/o initialization: ✅ PASSED */
  char a[_1_GB];
}

void stack_size_test1() {
  /* Declare two 1GB arrays w/o initialization: ✅ PASSED */
  char a[_1_GB];
  char b[_1_GB];
}

void stack_size_test2() {
  /* Declare 1GB array w/o initialization, but touch the page: ❌ FAILED */
  char a[_1_GB];
  a[0] = 1;       // write
  assert(a[0] == 1);
}

void stack_size_test3() {
  /* Declare 1GB array w/o initialization, but touch the page: ❌ FAILED */
  char a[_1_GB];
  int x = a[0];   // read
}

/**
 * The call instruction (call `puts`) pushes a return address onto the stack
 * at the new `rsp`, which is already unmapped. It causes segmentation fault.
 */
void stack_size_test4() {
  /* Declare 1GB array w/o initialization, plus a function call: ❌ FAILED */
  char a[_1_GB];
  puts("Declaration 1GB char array w/o initialization is OK. "
       "But another function call that pushes a return address "
       "at a unmapped location will cause segmentation fault.");
}

void stack_size_test5() {
  /* Declare 1GB array w/o initialization, plus a statement: ❌ FAILED */
  char a[_1_GB];
  int b = 1;
}

/**
 * Initialization of such a large array substantially slows down the
 * compilation.
 * Small .o file vs Large time and space consumption for its generation
 * - The compiler is smart enough not to dump a literal 1 GB blob.
 * - It collapses the array into:
 *   - a .bss reservation (.comm or .lcomm) of 1 GB,
 *   - plus a tiny .data fragment for the non-zero entries.
 * - That’s why the output file size is KB, but getting there required walking
 *   through a GB-scale structure.
 */
void stack_size_test6() {
  /* Initialization an array larger than stack size: ❌ FAILED */
  char a[_1_GB] = {
    0,
    [1] = 1,
    [2] = 2,
    [16 * 1024 * 1024] = 127,
  };
}

void stack_size_test7() {
  /* Initialization an array larger than stack size: ❌ FAILED */
  char a[_1_GB] = {
    0
  };
}

void stack_size_test8() {
  /* Declare 8MB array w/o initialization, plus a byte: ❌ FAILED */
  char a[_8_MB];
  char b = 'x';
}

void stack_size_test9() {
  char a[_8_MB];
  assert(0 == a[_8_MB / 2]);
}

void stack_size_test10() {
  char a[_8_MB];
  char b[1];
  // assert(0 == a[_8_MB / 2]);
}

void stack_size_test11() {
  char a[_7_MB] = {
    0,
    [1] = 1,
    [2] = 2,
    [10] = 10,
    [_7_MB / 2] = 127
  };
  assert(a[_7_MB / 2] == 127);
}

int main(void) {
  printf("LONG_MAX=%ld\n", LONG_MAX);

  stack_size_test0();
  stack_size_test1();

  /* Compile without optimization CFLAGS += -O0 , runtime error will occur.*/
  /* Debug mode: runtime error, Release mode: passed */

  stack_size_test2();        // Runtime error: Segmentation Fault
  stack_size_test3();        // Runtime error: Segmentation Fault
  stack_size_test4();        // Runtime error: Segmentation Fault
  stack_size_test5();        // Runtime error: Segmentation Fault
  stack_size_test6();        // Runtime error: Segmentation Fault
  stack_size_test7();        // Runtime error: Segmentation Fault
  stack_size_test8();        // Runtime error: Segmentation Fault

  stack_size_test9();
  stack_size_test10();
  stack_size_test11();
  return 0;
}


/*
 *
NOTE:
Debug mode: CFLAGS += -O0 (no optimization) -g    : Runtime error
Release mode: CFLAGS += O3                        : No error
Assembly Basic:
1. rsp = Register Stack Pointer
2. rbp = Register Base Pointer
3. On x86-64, the stack grows downward (toward lower addresses):
  rsp ──▶ [ return address   ]
          [ saved registers  ]
          [ local variables  ]  ← stack grows downward
4. At function entry, compilers typically do:
  push rbp         ; save old base pointer
  mov rbp, rsp     ; set new base pointer to current stack pointer
  sub rsp, N       ; reserve N bytes for locals
5. In function:
- rbp stays constant throughout the function.
- Local variables are accessed at fixed offsets from rbp (e.g., [rbp - 0x10]).
6. When the function ends:
  add rsp, N       ; free locals
  pop rbp          ; restore old base pointer
  ret              ; return to caller
7. Summary
High addresses
+---------------------+
| Caller’s stack data |
| Return address      | ← saved by CALL
+---------------------+
| Old RBP             | ← push rbp
+---------------------+
| Local variables     | ← rsp after sub
| ...                 |
+---------------------+
Low addresses
8. function call:
On 64-bit Linux and macOS, the calling convention says:
- RDI = 1st function argument
- RSI = 2nd argument
- RDX = 3rd argument
- RCX = 4th argument
- R8 = 5th argument
- R9 = 6th argument
Example:
  lea rdi, [rip+0x0]    ; loads the address of your string literal into
                        ; RDI (the 1st parameter for puts).
  call 87 <stack_size_test4+0x17> ; pushing the return address (87) onto the stack
9. At high optimization levels like -O3, the compiler can completely change
the implementation of a function, as long as it obeys the “as-if” rule from
the C standard:
- The compiler can optimize, reorder, or even remove code as long as the
program behaves the same as if it were executed according to the original
source, with respect to observable behavior.
Thus, when compile in Release mode, from the perspective of compiler:
- stack_size_test0() has a huge array but never uses it → dead → remove.
- stack_size_test1() has two huge arrays but never uses them → dead → remove.
- stack_size_test2() has a huge array and you assign a[0]=1, but the value is
never used anywhere else, so the store has no observable effect from the
outside → dead → remove.

## Object dump (Debug mode):
> objdump -d -M intel ./Debug/standards/test_limits.o > od
On Linux with GCC:

0000000000000000 <stack_size_test0>:
   0:   55                      push   rbp
   1:   48 89 e5                mov    rbp,rsp
   4:   5d                      pop    rbp
   5:   c3                      ret
   6:   66 2e 0f 1f 84 00 00    cs nop WORD PTR [rax+rax*1+0x0]
   d:   00 00 00

0000000000000010 <stack_size_test1>:
  10:   55                      push   rbp
  11:   48 89 e5                mov    rbp,rsp
  14:   5d                      pop    rbp
  15:   c3                      ret
  16:   66 2e 0f 1f 84 00 00    cs nop WORD PTR [rax+rax*1+0x0]
  1d:   00 00 00

0000000000000020 <stack_size_test2>:
  20:   55                      push   rbp
  21:   48 89 e5                mov    rbp,rsp
  24:   48 81 ec 80 ff ff 3f    sub    rsp,0x3fffff80
  2b:   c6 85 00 00 00 c0 01    mov    BYTE PTR [rbp-0x40000000],0x1
  32:   48 81 c4 80 ff ff 3f    add    rsp,0x3fffff80
  39:   5d                      pop    rbp
  3a:   c3                      ret
  3b:   0f 1f 44 00 00          nop    DWORD PTR [rax+rax*1+0x0]

...

0000000000000070 <stack_size_test4>:
  70:   55                      push   rbp
  71:   48 89 e5                mov    rbp,rsp
  74:   48 81 ec 00 00 00 40    sub    rsp,0x40000000
  7b:   48 8d 3d 00 00 00 00    lea    rdi,[rip+0x0]        # 82 <stack_size_test4+0x12>
  82:   e8 00 00 00 00          call   87 <stack_size_test4+0x17>
  87:   48 81 c4 00 00 00 40    add    rsp,0x40000000
  8e:   5d                      pop    rbp
  8f:   c3                      ret

...


## Object dump (Release mode):
> objdump -d -M intel ./Release/standards/test_limits.o > od.rel

0000000000000000 <stack_size_test0>:
   0:	c3                   	ret
   1:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
   8:	0f 1f 84 00 00 00 00
   f:	00

0000000000000010 <stack_size_test1>:
  10:	c3                   	ret
  11:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  18:	0f 1f 84 00 00 00 00
  1f:	00

0000000000000020 <stack_size_test2>:
  20:	c3                   	ret
  21:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  28:	0f 1f 84 00 00 00 00
  2f:	00

0000000000000030 <stack_size_test3>:
  30:	c3                   	ret
  31:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  38:	0f 1f 84 00 00 00 00
  3f:	00

0000000000000040 <stack_size_test4>:
  40:	48 8d 3d 00 00 00 00 	lea    rdi,[rip+0x0]        # 47 <stack_size_test4+0x7>
  47:	e9 00 00 00 00       	jmp    4c <stack_size_test4+0xc>
  4c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

...

 */
```



## ISO C

### <stdarg.h> defined by C compiler GCC/Clang

- Although <stdarg.h> is part of the C standard, it is not provided by the C
  standard library (glibc/macOS SDK), because it must reflect compiler
  internals and ABI-specific details. So the compiler (GCC/Clang) provides it.

## Grammar

### keywords

#### `restrict`

- since `C99`
- a contract between the programmer and the compiler
- applies only to pointers, promises the compiler the pointer is the only way
  to access the memory it points to during its lifetime (i.e., no other
  pointers alias the same memory).
- common usage: memcpy(3), stat(2)
- With `restrict` the compiler can assure no aliasing, enabling aggressive
  optimization (e.g., reordering instructions, cache values in registers).

#### `volatile`

- Tells the compiler don't optimize this variable or cache its value.

- Compiler optimizations block includes:

  - No register caching: Every read/write goes to memory.
  - No reordering: Operations stay in program order (but CPU may still reorder;
    use barriers if needed).

- Mainly used for:
  - Variables shared with signal handlers
  - Multi-threaded variables (though `atomic`, mutex are preferred)
  - Memory-mapped hardware registers

#### `sizeof`

```c
int a[108];
assert(432 == sizeof(a));
assert(8 == sizeof(&a[0]); // the address of the 1st element, a pointer type
```

- When an array is in an expression or passed to a function, it is decayed to a
  pointer.

```c
int a[108];
assert(8 == sizeof(a+1))

void f(int a[]) {
  assert(8 == sizeof(a))
}
```

- Compiler will show warnings for the two usages above ("-Wsizeof-array-decay",
  "-Wsizeof-array-argument"). Use pointer instead of array as function
  parameter.

```c
void f(int *a) { ; }
```

#### `typedef`

##### function pointer type

- Instead of use the below line to define a function pointer that points to
  a function returns a value of `int` type and accepts parameters of type
  `const char*` and `int*`.

```c
int (*fp) (const char*, int*);
```

- A more readable and less error-prone way is to use `typedef`

```c
typedef int Myfunc(const char*, int*);
Myfunc fp;
```

- This separates the definition of the function pointer type from the
  declaration of variables of that type, which is a common best practice for
  complex types in C.

### Array declaration and initialization

```c
int numbers[5] = {10, 20, 30, 40, 50}; // Full initialization
int numbers[5] = {10, 20}; // Partial (rest zero-initialized)
int numbers[] = {10, 20, 30}; // Omitted size (compiler determines)
int numbers[5] = {[2] = 30, [0] = 10}; // Designated initializers (C99+)
```

- In C, there is no `new` like C++, `int a[]` is used for declaring an array
  whose size is determined at compile time. Compilation error occurs in below
  code.

```c
// int a[] = calloc(size, sizeof(int));    // ❌ WRONG!
```

- Dynamic allocation using pointer to refer to the address.

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

### object-like macro vs. real typed constant


| Feature          | `#define CHILD_COUNT 5`              | `static const int CHILD_COUNT = 5`   |
| ---------------- | ------------------------------------ | ------------------------------------ |
| Type             | None (pure text replacement)         | Has type (`int`)                     |
| Scope            | Preprocessor (global until `#undef`) | C scope rules (block/file/global)    |
| Debugging        | Invisible (no symbol)                | Visible in debugger                  |
| Addressable      | No                                   | Yes (`&CHILD_COUNT`)                 |
| Const expression | Always usable in array sizes etc.    | Usable in C99+ as compile-time const |
| Substitution     | Pure text → can cause weird bugs     | Safer, type-checked                  |


- Real typed constant is preferred for safety.


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

#### `realloc(3)`

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

### `puts(3)` vs `printf(3)`

1. Both `puts(3)` and `printf(3)` are buffered.
2. `puts(3)` automatically adds '\n' whereas `printf(3)` doesn't.
3. `puts(3)` doesn't support formatting, so it's generally slightly faster
   than `printf(3)`

E.g.

```c
    // test_puts
    for (int i = 0; i < loop; i++) {
        puts(msg);
    }

    // test_printf
    for (int i = 0; i < loop; i++) {
        printf("%s\n", msg);
    }

    // test_print_no_newline
    for (int i = 0; i < loop; i++) {
        printf("%s", msg);
    }

/*

# 1. Line-buffered (console): the first two flush their streams line by line
> ./Debug/general/test_puts_printf 100000 Messi
...
...
Profiling test_puts: 100000 msg:[Messi]: Time used: 0.096289
Profiling test_printf: 100000 msg:[Messi]: Time used: 0.109352
Profiling test_printf_no_newline: 100000 msg:[Messi]: Time used: 0.013930


# 2. Fully-buffered (redirected to a normal file): '\n' doesn't trigger flush
> ./Debug/general/test_puts_printf 100000 Messi > full
> tail -3 file
...
Profiling test_puts: 100000 msg:[Messi]: Time used: 0.007696
Profiling test_printf: 100000 msg:[Messi]: Time used: 0.013391
Profiling test_printf_no_newline: 100000 msg:[Messi]: Time used: 0.011918

 */

```

## glibc

### `weak_alias`

Used when you want to expose a public API (e.g. `sleep(3)`) that defaults to
an internal implementation (`__sleep`), but can be overridden by another
definition.

`libc-symbols.h`:

```c
#include <libc-symbols.h>

#define weak_alias(name, aliasname) _weak_alias (name, aliasname)
#define _weak_alias(name, aliasname) \
  extern __typeof (name) aliasname __attribute__ ((weak, alias (#name))) \
    __attribute_copy__ (name);
```

#### Understand glibc extension and test

```c
/* weak_alias.c */
#include <assert.h>

/**
sleep.c:
weak_alias (__sleep, sleep)

libc-symbols.h:
# define weak_alias(name, aliasname) _weak_alias (name, aliasname)
# define _weak_alias(name, aliasname) \
  extern __typeof (name) aliasname __attribute__ ((weak, alias (#name))) \
    __attribute_copy__ (name);

 */

static void lshift(int *p, int shift) {
  (*p) = (*p) << shift;
}

static void rshift(int *p, int shift) {
  (*p) = (*p) >> shift;
}

/**
 * 1. GNU C extension: __typeof(x) gives you the type of x
 * **`__typeof`** is a compiler keyword, not a macro nor a function. It just
 * gives the type of the declared symbol
 * 
 * `const`, `volatile`, `restrict`: they're port of type
 * `static`, `extern`, `auto`, `register`, `inline`: they're NOT part of type,
 * they're storage class or linkage.
 */

static __typeof(lshift) *shift;

void __typeof_test(void)
{
  int a;
  __typeof(a) b;    // int b;
  assert(sizeof(b) == 4);
  a = 5;
  lshift(&a, 2);
  assert(20 == a);
  b = 20;
  rshift(&b, 2);
  assert(5 == b);

  shift = lshift;
  shift(&b, 2);
  assert(20 == b);

  shift = rshift;
  shift(&a, 2);
  assert(5 == a);
}


/**
 * 2. __attribute__((weak, alias("name"))) tells the compiler/linker:
 *    - `aliasname` is just another name (an alias) for `name`
 *    - weak means:
 *      - If `aliasname` is referenced, but the real definition of `aliasname`
 *      exists elsewhere, that one overrides this weak alias.
 *      - Otherwise, `aliasname` just points to `name`
 */
#ifdef _GNU_SOURCE
__typeof(rshift) shift2 __attribute((weak, alias ("rshift")));
__typeof(lshift) shift3 __attribute((weak, alias ("lshift")));

/* strong alias, results in linker error: multiple definition of shift3 */
// __typeof(lshift) shift3 __attribute((alias ("lshift"))); // linker error
#elif defined(__APPLE__)
static __typeof(rshift) *shift2 = rshift;
static __typeof(lshift) *shift3 = lshift;
#endif

void __attribute___test(void)
{
  int a = 5;
  shift2(&a, 2);
  assert(1 == a);
  int b = 64;
  shift2(&b, 5);
  assert(2 == b);

  shift3(&b, 4);
#ifdef _GNU_SOURCE
  /* strong definition in shift3.c overrides weak alias */
  assert(64 == b);
#elif defined(__APPLE__)
  assert(32 == b);
#endif
}

#ifdef _GNU_SOURCE
/**
 * 3. __attribute_copy__(name) a glibc extension: it copies attributes (like
 * nonnull, malloc, format(printf, …) etc.) from name to aliasname.
 *
 */

__typeof(lshift) shift4 __attribute((weak, alias ("rshift"))) \
    __attribute_copy__(lshift);

void __attribute_copy___test(void)
{
  int a = 64;
  shift4(&a, 5);
  assert(2 == a);
}
#endif

int main(int argc, char *argv[]) {

  __typeof_test();
  __attribute___test();
#ifdef _GNU_SOURCE
  __attribute_copy___test();
#endif

  return 0;
}
```

```c shift3.c
void shift3(int *p, int shift)
{
  (*p) = (*p) << (shift + 1);
}
```

### Load next symbol (First, strong definition; Next, weak alias)

```c
#include <dlfcn.h>
void* dlsym(void* handle, const char* symbol);
```

`dlsym()` returns the address of the code or data location specified by the
null‐terminated character string symbol.  Which libraries and bundles are
searched depends on the handle parameter.

If `dlsym()` is called with the special handle `RTLD_NEXT`, then `dyld`
searches for the symbol in the dylibs the calling image linked against when
built.

- Example: `dlsym(RTLD_NEXT, "sleep")` (See [implementing sleep(3)](/notes/apue/ch10-signals//#alarm3--sigsuspend2-implementing-sleep3)).

### system call

```c
  result = INLINE_SYSCALL_CALL (rt_sigaction, sig,
                                act ? &kact : NULL,
                                oact ? &koact : NULL, STUB (act,
                                                            __NSIG_BYTES));

```


```c
//--> user call
sigaction(SIGINT, &act, &oact);
//  --> glibc-2.36/include/signal.h
//    --> glibc-2.36/signal/signal.h
extern int sigaction (int __sig, const struct sigaction *__restrict __act,
                      struct sigaction *__restrict __oact) __THROW;
//      --> glibc-2.36/signal/sigaction.c
int
__sigaction (int sig, const struct sigaction *act, struct sigaction *oact)
{
  if (sig <= 0 || sig >= NSIG || is_internal_signal (sig))
    {
      __set_errno (EINVAL);
      return -1;
    }

  return __libc_sigaction (sig, act, oact);
}
libc_hidden_def (__sigaction)
weak_alias (__sigaction, sigaction)
//        --> glibc-2.36/sysdeps/unix/sysv/linux/libc_sigaction.c
int
__libc_sigaction (int sig, const struct sigaction *act, struct sigaction *oact)
{
  int result;

  struct kernel_sigaction kact, koact;

  if (act)
    {
      kact.k_sa_handler = act->sa_handler;
      memcpy (&kact.sa_mask, &act->sa_mask, sizeof (sigset_t));
      kact.sa_flags = act->sa_flags;
      SET_SA_RESTORER (&kact, act);
    }

  /* XXX The size argument hopefully will have to be changed to the
     real size of the user-level sigset_t.  */
  result = INLINE_SYSCALL_CALL (rt_sigaction, sig,
                                act ? &kact : NULL,
                                oact ? &koact : NULL, STUB (act,
                                                            __NSIG_BYTES));

  if (oact && result >= 0)
    {
      oact->sa_handler = koact.k_sa_handler;
      memcpy (&oact->sa_mask, &koact.sa_mask, sizeof (sigset_t));
      oact->sa_flags = koact.sa_flags;
      RESET_SA_RESTORER (oact, &koact);
    }
  return result;
}
libc_hidden_def (__libc_sigaction)

//            --> glibc-2.36/sysdeps/unix/sysdep.h
#define INLINE_SYSCALL_CALL(...) \
  __INLINE_SYSCALL_DISP (__INLINE_SYSCALL, __VA_ARGS__)

#define __INLINE_SYSCALL_DISP(b,...) \
  __SYSCALL_CONCAT (b,__INLINE_SYSCALL_NARGS(__VA_ARGS__))(__VA_ARGS__)

#define __SYSCALL_CONCAT(a,b)       __SYSCALL_CONCAT_X (a, b)
#define __SYSCALL_CONCAT_X(a,b)     a##b

#define __INLINE_SYSCALL_NARGS(...) \
  __INLINE_SYSCALL_NARGS_X (__VA_ARGS__,7,6,5,4,3,2,1,0,)

/* return the 9th element of the sequence */
#define __INLINE_SYSCALL_NARGS_X(a,b,c,d,e,f,g,h,n,...) n

#define __INLINE_SYSCALL0(name) \
  INLINE_SYSCALL (name, 0)
#define __INLINE_SYSCALL1(name, a1) \
  INLINE_SYSCALL (name, 1, a1)
#define __INLINE_SYSCALL2(name, a1, a2) \
  INLINE_SYSCALL (name, 2, a1, a2)
#define __INLINE_SYSCALL3(name, a1, a2, a3) \
  INLINE_SYSCALL (name, 3, a1, a2, a3)
#define __INLINE_SYSCALL4(name, a1, a2, a3, a4) \
  INLINE_SYSCALL (name, 4, a1, a2, a3, a4)
#define __INLINE_SYSCALL5(name, a1, a2, a3, a4, a5) \
  INLINE_SYSCALL (name, 5, a1, a2, a3, a4, a5)
#define __INLINE_SYSCALL6(name, a1, a2, a3, a4, a5, a6) \
  INLINE_SYSCALL (name, 6, a1, a2, a3, a4, a5, a6)
#define __INLINE_SYSCALL7(name, a1, a2, a3, a4, a5, a6, a7) \
  INLINE_SYSCALL (name, 7, a1, a2, a3, a4, a5, a6, a7)


#ifndef INLINE_SYSCALL
#define INLINE_SYSCALL(name, nr, args...) __syscall_##name (args)
#endif
```

This exact form (`__VA_ARGS__,7,6,5,4,3,2,1,0,`) is used to count
*up to 7 arguments beyond name* by right-shifting `n + 1` the sequence.

Thus, the below system call,
```c
result = INLINE_SYSCALL_CALL (rt_sigaction, sig,
                              act ? &kact : NULL,
                              oact ? &koact : NULL, STUB (act, __NSIG_BYTES));
```

, will be mapped to

```c
INLINE_SYSCALL (rt_sigaction, 4, sig, act_ptr, oact_ptr, sigset_size);
```

, and finally

```c
__syscall_rt_sigaction(sig, act_ptr, oact_ptr, sigset_size);
```

More general form:

```c
/*
 * Get the number of arguments for INLINE_SYSCALL_CALL(name, arg1, arg2, …)
 * __VA_ARGS__: name, arg1, arg2, ...
 *
 * Return value: 0 ~ 7. 0 means only function name, no args.
 */

#define _GET_NTH_ARG(_7,_6,_5,_4,_3,_2,_1,_0,n,...) n
#define _COUNT_ARGS(...) _GET_NTH_ARG(__VA_ARGS__,7,6,5,4,3,2,1,0)

void variadic_macro_argument_counting_test()
{
  assert(0 == _COUNT_ARGS("func"));
  assert(1 == _COUNT_ARGS("func", "a1"));
  assert(2 == _COUNT_ARGS("func", "a1", "a2"));
  assert(3 == _COUNT_ARGS("func", "a1", "a2", "a3"));
  assert(4 == _COUNT_ARGS("func", "a1", "a2", "a3", "a4"));
  assert(5 == _COUNT_ARGS("func", "a1", "a2", "a3", "a4", "a5"));
  assert(6 == _COUNT_ARGS("func", "a1", "a2", "a3", "a4", "a5", "a6"));
  assert(7 == _COUNT_ARGS("func", "a1", "a2", "a3", "a4", "a5", "a6", "a7"));

  // BTW, 
  assert(0 == _COUNT_ARGS());
}

int main() {
    variadic_macro_argument_counting_test();
    return 0;
}
```

## Symbol types in `ELF` (`nm` / `objdump -T`)

### Types
- T → symbol is in the text (code) section, strong definition
- U → undefined (imported from another object)
- B → uninitialized data (BSS)
- D → initialized data
- W → weak symbol (can be overridden by another strong definition)

### Example
E.g. The meaning of a output line like `00000000000d3e80 W fork@@GLIBC_2.2.5`
- `00000000000d3e80`: address of the symbol inside `libc.so`
- `W`: `fork` is a weak alias (defined with `weak_alias (__libc_fork, fork)`)
- `fork@@GLIBC_2.2.5`: export symbol `fork` with `GLIBC_2.2.5` namespace


## Debugging Multi-thread Program

### LLDB

#### Basic commands
```sh
> lldb <executable> [args]
(lldb) run
(lldb) b -f Ex11_3_workerthrd.c -n job_find
(lldb) thread list
(lldb) thread select 2
(lldb) thread backtrace [all]   <-- same to `(lldb) bt all`
(lldb) bt all
(lldb) frame select 1           <-- same to `fr s 1`
(lldb) frame variable           <-- same to `fr v`
(lldb) frame variable
```

#### Set breakpoint and debug multiple threads

```sh
> lldb
(lldb) file ./Debug/threads/Ex11_3_workerthrd
Current executable set to '.../Debug/threads/Ex11_3_workerthrd' (x86_64).
(lldb) b job_fetch_atomic
Breakpoint 1: where = Ex11_3_workerthrd`job_fetch_atomic + 16 at Ex11_3_workerthrd.c:150:15, address = 0x0000000100002fc0
(lldb) run
Process 77141 launched: '.../Debug/threads/Ex11_3_workerthrd' (x86_64)

MainThread: Add 8 jobs.
Process 77141 stopped
* thread #2, stop reason = breakpoint 1.1
    frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001afa000) at Ex11_3_workerthrd.c:150:15
   147   * Atomic find, wait and remove a job for the given thread ID
   148   */
   149  struct job *job_fetch_atomic(struct queue *pQ, pthread_t tid) {
-> 150    struct job *pJob = NULL;
   151    if (pthread_mutex_lock(&pQ->q_lock) != 0) return (NULL);
   152    while ((pJob = job_find(pQ, tid)) == NULL) {
   153      pthread_cond_wait(&pQ->q_cond, &pQ->q_lock);
  thread #3, stop reason = breakpoint 1.1
    frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001b7d000) at Ex11_3_workerthrd.c:150:15
   147   * Atomic find, wait and remove a job for the given thread ID
   148   */
   149  struct job *job_fetch_atomic(struct queue *pQ, pthread_t tid) {
-> 150    struct job *pJob = NULL;
   151    if (pthread_mutex_lock(&pQ->q_lock) != 0) return (NULL);
   152    while ((pJob = job_find(pQ, tid)) == NULL) {
   153      pthread_cond_wait(&pQ->q_cond, &pQ->q_lock);
  thread #4, stop reason = breakpoint 1.1
    frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001c00000) at Ex11_3_workerthrd.c:150:15
   147   * Atomic find, wait and remove a job for the given thread ID
   148   */
   149  struct job *job_fetch_atomic(struct queue *pQ, pthread_t tid) {
-> 150    struct job *pJob = NULL;
   151    if (pthread_mutex_lock(&pQ->q_lock) != 0) return (NULL);
   152    while ((pJob = job_find(pQ, tid)) == NULL) {
   153      pthread_cond_wait(&pQ->q_cond, &pQ->q_lock);
(lldb) thread select 3
* thread #3, stop reason = breakpoint 1.1
    frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001b7d000) at Ex11_3_workerthrd.c:150:15
   147   * Atomic find, wait and remove a job for the given thread ID
   148   */
   149  struct job *job_fetch_atomic(struct queue *pQ, pthread_t tid) {
-> 150    struct job *pJob = NULL;
   151    if (pthread_mutex_lock(&pQ->q_lock) != 0) return (NULL);
   152    while ((pJob = job_find(pQ, tid)) == NULL) {
   153      pthread_cond_wait(&pQ->q_cond, &pQ->q_lock);
(lldb) bt
* thread #3, stop reason = breakpoint 1.1
  * frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001b7d000) at Ex11_3_workerthrd.c:150:15
    frame #1: 0x000000010000306a Ex11_3_workerthrd`worker_thrd(arg=0x00007ff7bfefe108) at Ex11_3_workerthrd.c:167:24
    frame #2: 0x00007ff801c914e1 libsystem_pthread.dylib`_pthread_start + 125
    frame #3: 0x00007ff801c8cf6b libsystem_pthread.dylib`thread_start + 15
(lldb) fr i
frame #0: 0x0000000100002fc0 Ex11_3_workerthrd`job_fetch_atomic(pQ=0x00007ff7bfefe108, tid=0x0000700001b7d000) at Ex11_3_workerthrd.c:150:15
(lldb) fr v
(queue *) pQ = 0x00007ff7bfefe108
(pthread_t) tid = 0x0000700001b7d000
(job *) pJob = NULL
(lldb) fr s 1
frame #1: 0x000000010000306a Ex11_3_workerthrd`worker_thrd(arg=0x00007ff7bfefe108) at Ex11_3_workerthrd.c:167:24
   164    struct queue *pQ = arg;
   165    pthread_t tid = pthread_self();
   166    for (;;) {
-> 167      struct job *pJob = job_fetch_atomic(pQ, tid);
   168      if (pJob != NULL) {
   169        printf(
   170            "Job ID: [%d], Job Thread: [%d:0x%lx], Current Thread ID: [0x%lx]\n",
(lldb) fr i
frame #1: 0x000000010000306a Ex11_3_workerthrd`worker_thrd(arg=0x00007ff7bfefe108) at Ex11_3_workerthrd.c:167:24
(lldb) fr v
(void *) arg = 0x00007ff7bfefe108
(queue *) pQ = 0x00007ff7bfefe108
(pthread_t) tid = 0x0000700001b7d000
(job *) pJob = NULL
(lldb) expr pJob == NULL
(bool) $0 = true
```


[1]: https://clangd.llvm.org/installation#compile_commandsjson
[2]: https://clang.llvm.org/docs/ClangFormat.html#standalone-tool

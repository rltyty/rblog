---
title: "Ch07 Process Environment"
subtitle: ""
date: 2025-08-06T07:31:43+08:00
lastmod: 2025-08-06T07:31:43+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['process', 'Unix']
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

##  C Process Start and Termination

![How a C program is started and terminates](<./images/How a C program is started and how it terminates.png>)

### Start-up

```txt
[Kernel loads program with execve()]
    ↓
_start          // in crt1.o
    ↓
__libc_start_main
    ↓
(run initializations)
    ↓
main
```

### Termination

```c
#include <stdlib.h>     // specified by ISO C
void exit(int status);  // cleanup: fclose all open streams, call atexit handlers
void _Exit(int status);

#include <unistd.h>     // specified by POSIX.1
void _exit(int status);
```

#### explicit call of `exit(status)` from `main()`

```txt
main()
    ↓
exit(status) [libc] (bypass __libc_start_main())
    ↓
__run_exit_handlers()
    ↓
call functions registered with atexit() (in reverse order)
    ↓
flush/close stdio
    ↓
_exit(status) [libc → syscall]
    ↓
kernel exit_group()
    ↓
process ends
```

#### return from `main()`

```txt
main() -> return to __libc_start_main()
                            ↓
                    exit(status) [libc]
                            ↓
                (the rest is same to above)
```

#### explicit call of `_exit(status)` from `main`

No much cleanup work.

```txt
main()
    ↓
_exit(status) [libc → syscall]
    ↓
kernel exit_group()
    ↓
process ends
```

#### Call `atexit()` registered handlers in reverse order

```c
static char *p1 = "Bye!";
static char *p2 = "Bye!";

void exit_handler_1(void);
void exit_handler_2(void);

int main(int argc, char *argv[]) {
  if (atexit(exit_handler_1)) my_perror("atexit: exit_handler_1");
  if (atexit(exit_handler_1)) my_perror("atexit: exit_handler_1");
  if (atexit(exit_handler_2)) my_perror("atexit: exit_handler_2");
  if (argc > 1) {
    p1 = argv[1];
    if (argc > 2) {
      p2 = argv[2];
    }
  }
  printf ("argc = %d\n", argc);
}

void exit_handler_1 (void) {
  printf("EXIT_HANDLER_1: %s\n", p1);
}

void exit_handler_2 (void) {
  printf("EXIT_HANDLER_2: %s\n", p2);
}

/*
:!Debug/procenv/exit_handler_test 再见 Adios
argc = 3
EXIT_HANDLER_2: Adios
EXIT_HANDLER_1: 再见
EXIT_HANDLER_1: 再见
 */
```

## Command Line Arguments

### `argv`

`argv` is a pointer to a null‐terminated array of character pointers to
null‐terminated character strings. Both ISO C Standard and POSIX Standard
requires applications shall ensure the last member of `argv` is a null
pointer.

### Iteration over `argv`

```c
/* test_main_argv.c */

// argv[0]: program name, argv[1] ~ argv[argc-1]: arguments, argv[argc]: NULL

int main(int argc, char *argv[]) {
  // 1.
  for (int j = 0; j < argc; j++) printf("argv[%d]: %s\n", j, argv[j]);
  printf("---\n");

  // 2.
  for (int j = 0; argv[j] != NULL; j++) printf("argv[%d]: %s\n", j, argv[j]);
  printf("---\n");

  // 3.
  for (char **p = argv; *p != NULL; p++) printf("p: %p, *p: %s\n", p, *p);
  printf("---\n");

  // print argc arguments + 1.
  for (int j = 0; j <= argc; j++) printf ("argv[%d]: %s\n", j, argv[j]);
  printf("---\n");
}

/*
Debug/procenv/test_main_argv a1 a2
argv[0]: Debug/procenv/test_main_argv
argv[1]: a1
argv[2]: a2
---
argv[0]: Debug/procenv/test_main_argv
argv[1]: a1
argv[2]: a2
---
p: 0x7ff7b81901d8, *p: Debug/procenv/test_main_argv
p: 0x7ff7b81901e0, *p: a1
p: 0x7ff7b81901e8, *p: a2
---
argv[0]: Debug/procenv/test_main_argv
argv[1]: a1
argv[2]: a2
argv[3]: (null)
---
 */
```

### Interpreter file

Read the man page `execve(2)`

If the first two bytes of a script are `#!` (***shebang***), and they're
followed by an **interpreter**, it is an interpreter file (***shebang***
script).

```sh
#! interpreter [ optional-argument ...]
...
```

When it is executed via `./a.sh` or `execve(interpreter_file_path, argv, envp)`

1. The kernel locates and load the **interpreter** after the ***shebang***
2. The arguments to be passed to **interpreter**  are built in this order:
   - the zeroth argument: the **interpreter** itself
   - the first (second, ..) argument: the optional arguments after the **interpreter**
   - the script file path (or the path passed to `execve()`)
   - the original arguments passed to the script or `exec` call (`argv`)
3. The kernel calls a second `execve()` with the **interpreter** and arguments.
   - if the **interpreter** is an executable binary, the kernel will setup
     process image and jump to `_start` in user process.
   - if the **interpreter** is also an ***shebang*** script, the kernel goes
     back to step 1, recursively. (Linux: BINPRM_MAX_RECURSION=4, if exceeded,
     failed with `ELOOP`)

**NOTE:**
  a. The kernel overrides the first argument passed to the ***shebang***
     script with the script path.
  b. On Linux the kernel only supports one optional shebang argument -- it's
     just one contiguous string after the interpreter path, up to newline
     argv[0]: Debug/procenv/printargv
     argv[1]: interp_arg1 interp_arg2   <- Linux: the rest of the line after the interpreter
     argv[2]: ./tmp/data/procenv/interpreter.file
     ...

- Example 1: `execve(2)` with ***shebang*** interpreter file
```c
/* execve.c */

int main(int argc, char *argv[]) {
  static char *newargv[] = {"this will be overridden", "hello", "world", NULL};
  static char *newenviron[] = {NULL};

  if (argc != 2) {
    fprintf(stderr, "Usage: %s <file-to-exec>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  execve(argv[1], newargv, newenviron);
  perror("execve"); /* execve() returns only on error */
  exit(EXIT_FAILURE);
}

/*
cat ./tmp/data/procenv/interpreter.file
#! Debug/procenv/printargv interp_arg1 interp_arg2

Debug/procenv/execve ./tmp/data/procenv/interpreter.file
argv[0]: Debug/procenv/printargv
argv[1]: interp_arg1
argv[2]: interp_arg2
argv[3]: ./tmp/data/procenv/interpreter.file    <-- overridden by kernel
argv[4]: hello
argv[5]: world
 */
```

- Example 2: `execl(3)` with ***shebang*** interpreter file


```c
int main(int argc, char *argv[]) {
  // exec: shebang interpreter file
  if (execl("./tmp/data/procenv/interpreter.file", "this will be overridden", "arg1", "arg2", (char*)0) < 0)
    my_perror("execl error");
  return 0;
}

/*
:!Debug/procenv/exec_interpreter_file
argv[0]: Debug/procenv/printargv
argv[1]: myecho_arg1
argv[2]: myecho_arg2
argv[3]: ./tmp/data/procenv/interpreter.file
argv[4]: arg1
argv[5]: arg2
 */
```

- Example 3: `execl(3)` with executable

```c
int main(int argc, char *argv[]) {
  // exec: executable
  if (execl("./Debug/procenv/printargv", "this will NOT be overridden", "arg1", "arg2", (char*)0) < 0)
    my_perror("execl error");
  return 0;
}

/*
Debug/procenv/exec_executable
argv[0]: this will NOT be overridden
argv[1]: arg1
argv[2]: arg2
 */
```

## Environment

## Memory Layout

![Typical memory arrangement](<images/Typical memory arrangement.png>)

### Stack Segment

Automatic storage duration, variables are declared in a function:

- Automatic allocation on **stack** when function is invoked and deallocation
  when it returns.
- Uninitialized variables contain garbage values.

### Data Segment

Global or static storage duration, variables declared globally or as static
in a function:

- if initialized, located at **initialized data segment**
- if not initialized, located at **Block Start by Symbol (BSS) data segment**
  and zero-initialized by compiler (e.g. int: 0, float: 0.0f, void*: NULL)
- allocation when the program starts and persists for the entire duration of
  the program's execution.

NOTE:

When an array is partially initialized, all unspecified elements are
zero-initialized, no matter what storage duration the array is in.

1. Full: `int numbers[5] = {10, 20, 30, 40, 50};`
2. Partial (rest zero-initialized): `int numbers[5] = {10, 20};`
3. Omitted size (compiler determines): `int numbers[] = {10, 20, 30};`
4. Designated initializers (C99+): `int numbers[5] = {[2] = 30, [0] = 10};`

### Inspect an executable binary layout (`size` or `otool`)

```sh
#
# On Linux:
# > size ./Debug/procenv/printargv ./Debug/procenv/execve
#    text    data     bss     dec     hex filename
#    1392     584       8    1984     7c0 ./Debug/procenv/printargv
#    1815     648      16    2479     9af ./Debug/procenv/execve

```

##  Memory allocation

```c
#include <stdlib.h>
void *malloc(size_t size);
void *calloc(size_t nobj, size_t size);
void *realloc(void *ptr, size_t newsize);
                    // All three return: non-null pointer if OK, NULL on error

void free(void *ptr);
```

- `malloc`: memory allocation
- `calloc`: contagious allocation, array of elements
- `realloc`: when `ptr` is `NULL`, `ralloc` is `malloc`

The allocation allocates more space than requested and use the additional
space for **record-keeping** (size of the block, a pointer to the next
allocated block and the like). Writing past the end or before the start of an
allocated area would overwrite the **record-keeping** information of another
block.

The allocation routines are usually implemented with the `sbrk(2)` syscall.
This call expands (or contracts) the heap of the process. However, the freed
space is not usually returned to the kernel; instead, it is kept in
the `malloc` pool.

- `free`:  Find memory metadata by the help of `ptr` and know the size of
memory to be freed.

## `setjmp` and `longjmp`

`goto` is a local jump, jump in the same function (same stack frame). `setjmp`
and `longjmp` can jump across stack frames. `longjmp` causes the stack to be
***unwound*** back to the function where `setjmp` is called, throwing away
the after stack frames.

```c
#include <setjmp.h>
int setjmp(jmp_buf env);
  // Returns: 0 if called directly, nonzero if returning from a call to longjmp

void longjmp(jmp_buf env, int val);
```
## Incorrect usage of an automatic variable

```c
FILE *
open_data(void)
{
  FILE    *fp;
  char    databuf[BUFSIZ];  /* setvbuf makes this the stdio buffer */ <-- err
  if ((fp = fopen("datafile", "r")) == NULL)
      return(NULL);
  if (setvbuf(fp, databuf, _IOLBF, BUFSIZ) != 0)
      return(NULL);
  return(fp);     /* error */
}
```

`databuf` needs to be allocated from global memory, either statically (`static`
or `extern`) or dynamically (one of `alloc` functions).

## `getlimit` and `setlimit`

```c
#include <sys/resource.h>
int getrlimit(int resource, struct rlimit *rlptr);
int setrlimit(int resource, const struct rlimit *rlptr);
                                 //   Both return: 0 if OK, −1 on error

struct rlimit {
  rlim_t  rlim_max;  /* hard limit: maximum value for rlim_cur */
  rlim_t  rlim_cur;  /* soft limit: current limit */
};
```


| API / Header               | Example                        | Scope               | Changeable?     | Source         |
| -------------------------- | ------------------------------ | ------------------- | --------------- | -------------- |
| `<limits.h>`               | `INT_MAX`, `OPEN_MAX`          | Compile-time / C    | No              | Compiler/C lib |
| `sysconf(_SC_...)`         | `_SC_OPEN_MAX`                 | Runtime query       | No (read-only)  | Kernel/config  |
| `<sys/resource.h>` rlimits | `RLIMIT_NOFILE`, `RLIMIT_DATA` | Runtime per-process | Yes (soft/hard) | Kernel         |



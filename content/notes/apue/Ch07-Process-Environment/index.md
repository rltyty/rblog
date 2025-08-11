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
categories: []

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

### Interpreter File

Read the man page `execve(2)`

If the first two bytes of a script are `#!` (***shebang***), and they're
followed by an **interpreter**, it is an interpreter file.

```sh
#! interpreter [ optional-argument ...]
...
```

When it is executed via `./a.sh` or `execve(interpreter_file_path, argv, envp)`

1. The kernel locates and load the **interpreter** after `#!` (***shebang***)
2. The **interpreter** receives arguments in this order:
   - the zeroth argument: the **interpreter** itself
   - the first (second, ..) argument: the optional arguments after the **interpreter**
   - the interpreter file path (or the path passed to `execve()`)
   - the original arguments passed to the script or `exec` call (`argv`)

The kernel overrides the first argument passed to the ***shebang*** script
with the script path.

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
 *
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

Explicit array initialization with zero-initialized for all storage duration
variables.
1. Full: `int numbers[5] = {10, 20, 30, 40, 50};`
2. Partial (rest zero-initialized): `int numbers[5] = {10, 20};`
3. Omitted size (compiler determines): `int numbers[] = {10, 20, 30};`
4. Designated initializers (C99+): `int numbers[5] = {[2] = 30, [0] = 10};`


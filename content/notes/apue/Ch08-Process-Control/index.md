---
title: "Ch08 Process Control"
subtitle: ""
date: 2025-08-13T06:48:56+08:00
lastmod: 2025-08-13T06:48:56+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Process', 'Unix']
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

<!--more-->

## Process Identifier (PID)

- Unique, non-negative integer.
- PID 0 process: the scheduler process, the ***swapper***, part of the kernel, a
  system process.
- PID 1 process: the **init** process, invoked by the kernel at the end of
  bootstrap procedure. The program file is `launchd` on macOS, `systemd`
  on Linux, replacing the old version `/etc/init`.
  - `/sbin/launchd` (macOS), `/sbin/init -> /lib/systemd/systemd` (Linux)

## How `fork(2)` is typically implemented in a Unix or Linux kernel?

```c
#include <unistd.h>
pid_t fork(void);
    // Returns: 0 in child, process ID of child in parent, −1 on error
```

It's quite sophisticated, primarily relying on a technique called
**Copy-on-Write (CoW)** for efficiency.

### 1. The Goal of `fork()`

`fork()` creates a new process (the **child process**) that is an almost exact
duplicate of the calling process (the **parent process**). Both processes
continue execution from the point of the `fork()` call, but with different
return values:
*   The **parent** receives the **Process ID (PID)** of the new child.
*   The **child** receives **0**.
*   Both processes have their own independent memory space, but they initially
    share many resources efficiently.

### 2. Key Steps in Kernel Implementation:

#### a. Creating a New Process Control Block (PCB)

*   The kernel allocates memory for a new `task_struct` (Linux's PCB equivalent)
    for the child process.
*   Most fields from the parent's `task_struct` are copied directly to the
    child's. This includes:
    *   Process state (e.g., running, sleeping)
    *   CPU registers (copied from the parent's context at the time of the `fork` call)
    *   Scheduling information
    *   Signal handlers
    *   Resource limits
    *   Current working directory
    *   Root directory

#### b. Assigning a Unique PID

*   A new, unique Process ID (PID) is generated and assigned to the child process.

#### c. Virtual Memory Management (Copy-on-Write - CoW)

This is the most critical and complex part for efficiency:

*   **Duplicating Page Tables:** Instead of physically copying all of the
    parent's memory pages (which could be gigabytes), the kernel duplicates
    the **page tables** of the parent process for the child.
*   **Marking Pages Read-Only:** All the memory pages in both the parent's and
    child's virtual address spaces that correspond to the *original* parent's
    writable memory (e.g., data segment, heap, stack) are marked as
    **read-only** in both sets of page tables. They initially point to the
    *same physical memory frames*.
*   **Handling Writes (Page Faults):**
    *   If either the parent or the child attempts to **write** to one of
        these shared, read-only pages, a **page fault** occurs.
    *   The kernel's page fault handler intercepts this.
    *   It then allocates a new physical memory page for the process that
        attempted the write.
    *   The content of the original shared page is copied to this new physical
        page.
    *   The faulting process's page table entry for that virtual address is
        updated to point to the new, private physical page, and the permission
        is set back to writable.
    *   The original shared page remains accessible to the other process
        (parent or child) as read-only.
*   **Efficiency:** This means that only pages that are actually modified by
    either process are duplicated, saving significant memory and time if the
    child process immediately calls `execve()` (to run a new program) or if
    only a small portion of the memory is modified.

#### d. File Descriptors

*   The parent's file descriptor table is duplicated for the child. However,
    the entries in the child's table **point to the same underlying file table
    entries** as the parent.
*   This means parent and child share:
    *   The same open file (e.g., a file on disk).
    *   The same file offset (where the next read/write will occur).
    *   The same [file status
        flags](/notes/apue/ch03-file-io/#open-and-openat-functions).
*   If one process reads from a shared file descriptor, the file offset
    advances for both. If one process closes a file descriptor, the kernel
    only decrements the reference count for the underlying file table entry;
    the file is only truly closed when the last reference count drops to zero.

![Sharing of open files between parent and children after fork](<./images/Sharing of open files between parent and child after fork.png>)

#### e. Return to User Space

*   In the child process, the kernel sets the return value of the `fork()`
    system call to `0` before allowing it to resume execution in user space.
*   In the parent process, the kernel sets the return value of the `fork()`
    system call to the child's PID.

### 3. Simplified Flow:

1.  **User calls `fork()`** -> Enters kernel via system call trap.
2.  **Kernel duplicates `task_struct`**: Creates a new PCB for the child.
3.  **Kernel duplicates page tables**: Child's page tables point to same
physical pages as parent, marked read-only.
4.  **Kernel duplicates file descriptors**: Child's FDs point to same file
table entries.
5.  **Kernel sets child's return value to 0.**
6.  **Kernel sets parent's return value to child's PID.**
7.  **Both parent and child processes are now runnable.** The scheduler can
pick either to run.

This highly optimized implementation allows `fork()` to be a very fast
operation in most cases, especially when it's immediately followed by an
`execve()` call (the `fork-exec` model), as very little memory copying is
needed.

Two typical use of `fork()`:

- Duplicate a process, e.g. network server (the master waits for requests
  from client, calls `fork()` and lets the children handle the incoming
  requests, goes back to waiting for next requests)

- Execute a different program, e.g. shell (the child does an `exec()` right
  after it returns from `fork()`.

  - `spawn` is a concept to combine `fork()` and `exec()` into one operation.

## `exec()` functions

![seven exec()](<./images/Relationship of the seven exec functions.png>)

## `wait()` and `waitpid()`

```c
#include <sys/wait.h>
pid_t wait(int *statloc);
pid_t waitpid(pid_t pid, int *statloc, int options);
            // Both return: process ID if OK, 0 (see later), or −1 on error
```

`wait()` can block the caller until a child terminates, whereas `waitpid()`
has an option that prevents it from blocking.

`wait()` family functions return -1 and set `ECHILD` when the caller has no
children (or being unwaited for).

A terminated process has no parent waiting for it is called a ***zombie***.

```c
int main(int argc, char *argv[]) {
  pid_t pid;

  if ((pid = fork()) < 0) {
    my_perror("error: fork()");
  } else if (pid == 0) {  // child
    printf("I'm a child (PID %d), my parent (PPID %d). I'll become a zombie!\n\n",
           getpid(), getppid());
    sleep(2);
  } else {  // parent
    printf("\nI'm a parent (PID %d). I have a child (PID %d), it is a zombie.\n",
           getpid(), pid);
    sleep(3);
    char *cmd = (char*) malloc(25);
    sprintf(cmd, "ps -o pid,ppid,state,time,utime,etime,command -p %d", pid); // show the child's state
    system(cmd);
  }
  return 0;
}

/*
Sample output:

:!Debug/procctl/zombie
I'm a child (PID 48899), my parent (PPID 48898). I'll become a zombie!

  PID  PPID STAT COMMAND
48899 48898 Z    (zombie)

I'm a parent (PID 48898). I have a child (PID 48899), it is a zombie.

*/
```

- Avoid zombie processes by calling fork twice

```c
const char * const PS_CMD = "ps -o pid,ppid,state,command -p %d";
const char * const ZOMBIE_PID_FILE = "./tmp/data/procctl/zombie.pid";
int main(int argc, char *argv[]) {
  pid_t pid;

  if ((pid = fork()) < 0) {
    my_perror("error: fork()");
  } else if (pid == 0) {  // child
    if ((pid = fork()) < 0) {
      my_perror("error: fork()");
    } else if (pid == 0) {  // grandchild
      sleep(5);
    } else {  // child
      int fd = open(ZOMBIE_PID_FILE, O_WRONLY|O_CREAT|O_TRUNC, FILE_MODE);
      if (fd < 0) {
      my_perror("error: child PID[%d]: open()", getpid());
      } else {
        char buf[10] = {0};
        sprintf(buf, "%d", pid);
        if (write(fd, buf, strlen(buf)) < 0) { // write grandchild pid to file
          my_perror("error: write()");
        };
      }
      _exit(0);
    }
  } else {  // parent
    sleep(3);
    printf("No zombie, but orphan adopted by init.\n");
    int fd = open(ZOMBIE_PID_FILE, O_RDONLY);
    if (fd < 0) {
      my_perror("error: parent PID[%d]: open()", getpid());
    } else {
      char buf[10] = {0};
      int n;
      if ((n = read(fd, buf, sizeof(buf))) < 0) {
        my_perror("error: read");
      } else {
        pid = atoi(buf);
        printf("grandchild: PID[%d]\n", pid);   // read grandchild pid
        char *cmd = (char *)malloc(25);
        sprintf(cmd, PS_CMD, pid);
        system(cmd);
        free(cmd);
      }
    }
  }
  return 0;
}

/*
Sample output:

> ./Debug/procctl/zombie2
No zombie, but orphan adopted by init.
grandchild: PID[60433]
  PID  PPID STAT COMMAND
60433     1 S+   ./Debug/procctl/zombie2        <-- PPID:1
*/
```

### `system(3)` Function

```c
#include <stdlib.h>
int system(const char *cmdstring);
```

Execute a command string from within a program.

Implemented by calling `fork`, `exec`, and `waitpid`. A sample implementation
without signal handling.

```c
int system(const char *cmdstring) {
  pid_t pid;
  int status;
  /* version without signal handling */
  if (cmdstring == NULL) return (1); /* always a command processor with UNIX */
  if ((pid = fork()) < 0) {
    status = -1;         /* probably out of processes */
  } else if (pid == 0) { /* child */
    execl("/bin/sh", "sh", "-c", cmdstring, (char *)0);
    _exit(127); /* execl error */
  } else {      /* parent */
    while (waitpid(pid, &status, 0) < 0) {  // option: 0, blocking mode
      if (errno != EINTR) {
        status = -1; /* error other than EINTR from waitpid() */
        break;
      }
    }
  }
  return (status);
}

/*
Note: waitpid(..., option), when option=0 (blocking mode), wait until the pid
process terminates. while(.. < 0) is for re-wait when there is signal
interrupt causing waitpid() to return -1.
 */
```


## Process Scheduling `nice()`

A process could choose to run with lower priority by adjusting its nice value
(thus a process could be "nice" and reduce its share of the CPU by adjusting
its nice value).

The more nice you are, the lower your scheduling priority is. Lower nice
values have higher scheduling priority.

```c
#include <unistd.h>
int nice(int incr);
                    // Returns: new nice value − NZERO if OK, −1 on error
```

```c
#include <sys/resource.h>
int getpriority(int which, id_t who);
          // Returns: nice value between −NZERO and NZERO−1 if OK, −1 on error
int setpriority(int which, id_t who, int value);
                    // Returns: 0 if OK, −1 on error
```

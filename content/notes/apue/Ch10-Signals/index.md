---
title: "Ch10 Signals"
subtitle: ""
date: 2025-08-17T12:41:28+08:00
lastmod: 2025-08-17T12:41:28+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Unix', 'Signals']
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

## Concepts

- Name: `SIGXXXX`
- Count: macOS and Linux: around 31, Solaris: 40
- Definition: `<signal.h>`


| Aspect           | Linux (glibc + kernel)                           | macOS (BSD-style libc)                             |
| ---------------- | ------------------------------------------------ | -------------------------------------------------- |
| Internal headers | `<bits/signum-*.h>` + `<asm/signal.h>`           | `<sys/signal.h>`, `<machine/signal.h>`             |
| Extra signals    | Linux-specific (`SIGSTKFLT`, `SIGPWR`, `SIGSYS`) | BSD/macOS-specific (`SIGINFO`, `SIGEMT`, `SIGTHR`) |
| Public include   | `<signal.h>`                                     | `<signal.h>`                                       |
| Source of truth  | Linux kernel headers (`asm/signal.h`)            | BSD heritage, inside XNU/libSystem headers         |


### Signal Generation

- Terminal-generated signals when users press certain terminal keys.
  - `<CTRL-C>` -> `SIGINT`
- Hardware exception
  - Divide by 0 -> `SIGFPE`
  - Invalid memory reference -> `SIGSEGV` (segmentation fault)
- Software condition
  - `SIGURG`, `SIGPIPE`, `SIGALRM`
- `kill(2)` send any signal to a process or process group.

### Disposition of the Signal

- Ignore
- Catch
- Let the default action apply.

**`SIGKILL`** and **`SIGSTOP`** cannot be ignored or caught.

### Summary

```txt
No    Name         Default Action       Description
1     SIGHUP       terminate process    terminal line hangup
2     SIGINT       terminate process    interrupt program
3     SIGQUIT      create core image    quit program
4     SIGILL       create core image    illegal instruction
5     SIGTRAP      create core image    trace trap
6     SIGABRT      create core image    abort program (formerly SIGIOT)
7     SIGEMT       create core image    emulate instruction executed
8     SIGFPE       create core image    floating‐point exception
9     SIGKILL      terminate process    kill program
10    SIGBUS       create core image    bus error
11    SIGSEGV      create core image    segmentation violation
12    SIGSYS       create core image    non‐existent system call invoked
13    SIGPIPE      terminate process    write on a pipe with no reader
14    SIGALRM      terminate process    real‐time timer expired
15    SIGTERM      terminate process    software termination signal
16    SIGURG       discard signal       urgent condition present on socket
17    SIGSTOP      stop process         stop (cannot be caught or ignored)
18    SIGTSTP      stop process         stop signal generated from keyboard
19    SIGCONT      discard signal       continue after stop
20    SIGCHLD      discard signal       child status has changed
21    SIGTTIN      stop process         background read attempted from control terminal
22    SIGTTOU      stop process         background write attempted to control terminal
23    SIGIO        discard signal       I/O is possible on a descriptor (see fcntl(2))
24    SIGXCPU      terminate process    cpu time limit exceeded (see setrlimit(2))
25    SIGXFSZ      terminate process    file size limit exceeded (see setrlimit(2))
26    SIGVTALRM    terminate process    virtual time alarm (see setitimer(2))
27    SIGPROF      terminate process    profiling timer alarm (see setitimer(2))
28    SIGWINCH     discard signal       Window size change
29    SIGINFO      discard signal       status request from keyboard
30    SIGUSR1      terminate process    User defined signal 1
31    SIGUSR2      terminate process    User defined signal 2
```

![Unix Signals](<./images/Unix Signals.png>)


### core dump

#### On macOS

```sh
# check if core dump enabled
> sysctl kern.coredump
kern.coredump: 1
# check core file location
> sysctl kern.corefile
kern.corefile: /cores/core.%P
# list core files
> ls -lh /cores
total 7.1G
-r-------- 1 gpanda wheel 3.6G Aug 17 17:37 core.36330
-r-------- 1 gpanda wheel 3.6G Aug 17 17:54 core.44110

# use debugger `lldb` to inspect core file
> lldb ./Debug/signal/abort -c /cores/core.44110
(lldb) bt
(lldb) thread list
(lldb) thread backtrace all
(lldb) image list
(lldb) register read
(lldb) frame variable
```

### `kill(2)` and command `kill(1)`

Sends a signal to a process or a group of processes.

```c
#include <signal.h>
int kill(pid_t pid, int signo);
                                        // Return: 0 if OK, −1 on error
```

- pid > 0, signo is sent to the process whose PID is pid
- pid = 0, signo is sent to all the processes whose group ID is equal to the
  process group ID of the sender
- pid = -1, if the user of the sender has super-user privileges, the signo is
  sent to all the processes excluding system processes and the sender; if not
  super user, the signo is sent to all the processes with the same uid as the
  sender, excluding the sender's process.
- pid < -1, the signo is sent to all the process whose group ID is |pid|

Regarding command, `kill(1)`

```sh
> kill -<SIGXXX> <PID>          -- send to process
> kill -<SIGXXX> -<PGID>        -- send to process group
```

#### Example

```c
void pr_statsig(int);

int main(int argc, char *argv[]) {
  int pid;
  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) { // child
    sleep(10);
    exit(0);
  } else { // parent
    sleep(3);
    int rc = 0;
    kill(pid, SIGSTOP); // send signal 17 to the child
    if (waitpid(pid, &rc, WUNTRACED) == -1) {
      my_perror("error: waitpid");
      exit(1);
    }
    assert(WIFSTOPPED(rc));
    printf("child rc = %d\n", rc);
    pr_statsig(rc);
  }
  return 0;
}

void pr_statsig(int status) {
  if (WIFSTOPPED(status)) {
    printf("Child stopped by signal %d (%s)\n", WSTOPSIG(status),
           strsignal(WSTOPSIG(status)));
  } else if (WIFEXITED(status)) {
    printf("Child exited with status %d\n", WEXITSTATUS(status));
  } else if (WIFSIGNALED(status)) {
    printf("Child killed by signal %d (%s)\n", WTERMSIG(status),
           strsignal(WTERMSIG(status)));
  }
}

/*
 * Sample output:
 *
!Debug/signals/basic
child rc = 4479
Child stopped by signal 17 (Suspended (signal): 17)
 */

```

## `signal(3)` function

`signal(3)` allows for a signal to be caught, to be ignored, or to generate an
interrupt. It registers a handler into a per-process signal disposition table
stored **in the kernel**. Each process has its own independent table.

`signal(3)` facility is a simplified interface to the more general
`sigaction(2)` facility.

```c
#include <signal.h>
void (*signal(int, void (*)(int)))(int);
            // Returns: previous disposition of signal if OK, SIG_ERR on error

// friendlier declaration with a typedef
typedef void (*sighandler_t)(int);
sighandler_t signal(int, sighandler_t);

// or
typedef void Sigfunc(int);
Sigfunc *signal(int, Sigfunc *);
```

Predefined signal handlers:

```c
#define SIG_DFL         (void (*)(int))0
#define SIG_IGN         (void (*)(int))1
#define SIG_ERR         ((void (*)(int))-1)

```
The three values used for these constants need not be −1, 0, and 1. They must
be three values that can never be the address of any declarable function.

### Example 1: Create a signal handler for two signals

A simple signal handler catches either of the two user-defined signals and
prints the signal number.

```c
static void	sig_usr(int);	/* one handler for both signals */
int
main(void)
{
	if (signal(SIGUSR1, sig_usr) == SIG_ERR)
		my_perror("can't catch SIGUSR1");
	if (signal(SIGUSR2, sig_usr) == SIG_ERR)
		my_perror("can't catch SIGUSR2");
	for ( ; ; )
		pause();
}

static void
sig_usr(int signo)		/* argument is signal number */
{
	if (signo == SIGUSR1)
		printf("received SIGUSR1\n");
	else if (signo == SIGUSR2)
		printf("received SIGUSR2\n");
	else
		my_perr_dump("received signal %d\n", signo);
}
```

```sh
> ./Debug/signal/sigusr &
[2] 36330
> kill -USR1 36330
received SIGUSR1
> kill -USR2 36330
received SIGUSR2
> kill 36330
[2]    36330 terminated  ./Debug/signals/sigusr
```

### Example 2: Send a signal to a process / pg / job to generate core dump

```c
int main(int argc, char *argv[]) {
  pid_t pid;

  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) { // child
    while(1) pause();
    _exit(1);
  } else { // parent
    sleep(3);
    printf("I'm a parent (PID:%d), I have a child (PID:%d)\n", getpid(), pid);
    int rc;
    waitpid(pid, &rc, WUNTRACED);
    pr_statsig(rc);
  }

  return 0;
}
```

```sh
> ulimit -c
0
> ulimit -c unlimited

# Tells a process to generate core dump

> ./Debug/signals/sigcore &
[2] 53132
> I'm a parent (PID:53132), I have a child (PID:53135)
>
> jobs
[1]  + suspended  vim
[2]  - running    ./Debug/signals/sigcore
> myps -p 53132,53135
  UID   PID  PPID  PGID   SESS TTY      STAT COMM
  501 53132 49433 53132      0 ttys001  SN   ./Debug/signals/sigcore
  501 53135 53132 53132      0 ttys001  SN   ./Debug/signals/sigcore

> kill -SIGABRT 53135

> myps -p 53132,53135
  UID   PID  PPID  PGID   SESS TTY      STAT COMM
  501 53132 49433 53132      0 ttys001  SN   ./Debug/signals/sigcore
  501 53135 53132 53132      0 ttys001  R    ./Debug/signals/sigcore
> Child killed by signal 6 (Abort trap: 6)

[2]  - 53132 done       ./Debug/signals/sigcore

> myps -p 53132,53135
  UID   PID  PPID  PGID   SESS TTY      STAT COMM

> ll -h /cores
total 3.6G
drwxrwxrwt  3 root   wheel   96 Aug 18 19:36 ./
drwxr-xr-x 20 root   wheel  640 Jul 17  2024 ../
-r--------  1 scv wheel 3.6G Aug 18 19:36 core.53135

# Tells a process group to generate core dump

> ./Debug/signals/sigcore &
[2] 62114
> I'm a parent (PID:62114), I have a child (PID:62117)
>
> kill -SIGABRT -62114
>
[2]    62114 abort (core dumped)  ./Debug/signals/sigcore
> ll -h /cores
total 7.1G
drwxrwxrwt  4 root   wheel  128 Aug 18 19:54 ./
drwxr-xr-x 20 root   wheel  640 Jul 17  2024 ../
-r--------  1 gpanda wheel 3.6G Aug 18 19:54 core.62114
-r--------  1 gpanda wheel 3.6G Aug 18 19:54 core.62117


# Tells a job to generate core dump

> ./Debug/signals/sigcore &
[2] 59032
> I'm a parent (PID:59032), I have a child (PID:59035)
>
> kill -SIGABRT %2
>
[2]    59032 abort (core dumped)  ./Debug/signals/sigcore

> ll -h /cores/
total 7.1G
drwxrwxrwt  4 root   wheel  128 Aug 18 19:48 ./
drwxr-xr-x 20 root   wheel  640 Jul 17  2024 ../
-r--------  1 gpanda wheel 3.6G Aug 18 19:48 core.59032
-r--------  1 gpanda wheel 3.6G Aug 18 19:48 core.59035

```

## Job-control Shell

In a terminal shell supporting job control, a job is a process group. At a
time, there is one foreground job and multiple background jobs. Any running a
program is a job.

### List jobs

```sh
# list jobs, + means current (default) job, - means previous job
> jobs
[1]  + suspended  vim
[2]  - running    ./Debug/signals/shelljob
```

### Interrupt/Suspend/Continue a job and `bg`, `fg`, `kill -<SIGNO> %<JobID>`

- `<CTRL-C>`: send `SIGINT` to interrupt the foreground job (process group)
- `<CTRL-Z>`: send `SIGTSTP` to suspend the foreground job (process group)
- `bg`: move a job to background and continue its running
- `fg`: move a job the foreground job
- `kill -TSTP %<JobID>` = `kill -18 -<PGID>`
- `kill -CONT %<JobID>` = `kill -19 -<PGID>`

```sh
> ./Debug/signals/shelljob
I'm a parent (PID:5219), I have a child (PID:5220)

^Z
[2]  + 5219 suspended
> jobs
[1]  - suspended  vim
[2]  + suspended  ./Debug/signals/shelljob
> myps -p 5219,5220
  UID   PID  PPID  PGID   SESS TTY      STAT COMM
  501  5219 49433  5219      0 ttys001  T    ./Debug/signals/shelljob
  501  5220  5219  5219      0 ttys001  T    ./Debug/signals/shelljob
> bg %2
[2]  - 5219 continued  ./Debug/signals/shelljob
> jobs
[1]  + suspended  vim
[2]  - running    ./Debug/signals/shelljob
> myps -p 5219,5220
  UID   PID  PPID  PGID   SESS TTY      STAT COMM
  501  5219 49433  5219      0 ttys001  S    ./Debug/signals/shelljob
  501  5220  5219  5219      0 ttys001  S    ./Debug/signals/shelljob
> fg %2
[2]  - 5219 running    ./Debug/signals/shelljob
^Z
[2]  + 5219 suspended  ./Debug/signals/shelljob
> jobs
[1]  - suspended  vim
[2]  + suspended  ./Debug/signals/shelljob

> kill -CONT %2
> jobs
[1]  - suspended  vim
[2]  + running    ./Debug/signals/shelljob

> kill -TSTP %2
[2]  + 5219 suspended  ./Debug/signals/shelljob
> jobs
[1]    suspended  vim
[2]  + suspended  ./Debug/signals/shelljob

> kill -19 -5219
> jobs
[1]    suspended  vim
[2]  + running    ./Debug/signals/shelljob

> kill -18 -5219
> jobs
[1]    suspended  vim
[2]  + suspended  ./Debug/signals/shelljob
```

## `sigaction(2)`



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

Signals are asynchronous events, allow the manipulation of a process from
outside its domain. Purposes:

- Avoid race condition and avoid polling
- Interprocess communication (IPC)

When a signal occurs, we can tell the kernel to do one of three things. We
call this the ***disposition*** of a signal, or the ***action*** associated
with a signal.

- Ignore the signal
- Catch the signal via user defined signal-catching function
- Apply the default action

### Basic information

- Signal Name: `SIGXXXX`
- Signal Number: No 0 signal, beginning with 1.
- Definition: `<signal.h>`
- Count: macOS and Linux: around 31, Solaris: 40
  - 31 signals <= 32, `__uint32_t` can holds `sigset_t` bit map
  - modern Linux `sigset_t` can hold 1024 = 64 (unsigned long) * 16 signals
  - modern Linux usually has 64 signals:
    - 1–31 traditional
    - 32–34 glibc reserved
    - 35–64 real-time signals (queued, prioritized, and data-carrying)


| Aspect           | Linux (glibc + kernel)                           | macOS (BSD-style libc)                             |
| ---------------- | ------------------------------------------------ | -------------------------------------------------- |
| Internal headers | `<bits/signum-*.h>` + `<asm/signal.h>`           | `<sys/signal.h>`, `<machine/signal.h>`             |
| Extra signals    | Linux-specific (`SIGSTKFLT`, `SIGPWR`, `SIGSYS`) | BSD/macOS-specific (`SIGINFO`, `SIGEMT`, `SIGTHR`) |
| Public include   | `<signal.h>`                                     | `<signal.h>`                                       |
| Source of truth  | Linux kernel headers (`asm/signal.h`)            | BSD heritage, inside XNU/libSystem headers         |


### Signal Generation

#### Terminal-generated signals

- Common terminal-generated signal mappings:

| Key Combination | Signal Sent | Signal No | Default Action                     | Typical Use Case               |
|-----------------|-------------|---------------|------------------------------------|---------------------------------|
| `<CTRL-C>`      | `SIGINT`    | 2         | Terminate process                  | Gracefully stop a command       |
| `<CTRL-Z>`      | `SIGTSTP`   | 18        | Suspend (pause) process            | Pause and resume later (`fg/bg`)|
| `<CTRL-\>`      | `SIGQUIT`   | 3         | Terminate + core dump (if enabled)  | Force quit and debug            |


- See the full current terminal signal mappings:

```sh
# On macOS:
> stty -a
speed 9600 baud; rows 52; columns 203;
intr = ^C; quit = ^\; erase = ^?; kill = ^U; eof = ^D; eol = <undef>; eol2 = <undef>; start = ^Q; stop = ^S; susp = ^Z; dsusp = ^Y; rprnt = ^R; werase = ^W; lnext = ^V; discard = ^O; status = ^T;
min = 1; time = 0;
-parenb -parodd cs8 hupcl -cstopb cread -clocal -crtscts
-ignbrk brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff ixany imaxbel iutf8
opost -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0
isig icanon iexten echo echoe -echok -echonl -noflsh -tostop -echoprt echoctl echoke -flusho -extproc
```

#### Signal numbers and names

```sh
# On macOS:
# zsh
> kill -l | awk '{for(i=1;i<=NF;i++) printf "%2d) %-8s%s", i, $i, (i%6?"":"\n")}'

 1) HUP      2) INT      3) QUIT     4) ILL      5) TRAP     6) ABRT
 7) EMT      8) FPE      9) KILL    10) BUS     11) SEGV    12) SYS
13) PIPE    14) ALRM    15) TERM    16) URG     17) STOP    18) TSTP
19) CONT    20) CHLD    21) TTIN    22) TTOU    23) IO      24) XCPU
25) XFSZ    26) VTALRM  27) PROF    28) WINCH   29) INFO    30) USR1
31) USR2

# bash
> kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGEMT       8) SIGFPE       9) SIGKILL     10) SIGBUS
11) SIGSEGV     12) SIGSYS      13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGURG      17) SIGSTOP     18) SIGTSTP     19) SIGCONT     20) SIGCHLD
21) SIGTTIN     22) SIGTTOU     23) SIGIO       24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGINFO     30) SIGUSR1
31) SIGUSR2

# On Linux (Debian 12):
# zsh
> kill -l | awk '{for(i=1;i<=NF;i++) printf "%2d) %-8s%s", i, $i, (i%6?"":"\n")}'
 1) HUP      2) INT      3) QUIT     4) ILL      5) TRAP     6) IOT
 7) BUS      8) FPE      9) KILL    10) USR1    11) SEGV    12) USR2
13) PIPE    14) ALRM    15) TERM    16) STKFLT  17) CHLD    18) CONT
19) STOP    20) TSTP    21) TTIN    22) TTOU    23) URG     24) XCPU
25) XFSZ    26) VTALRM  27) PROF    28) WINCH   29) POLL    30) PWR
31) SYS

# bash
> kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

***NOTE***

`zsh` on Linux shows

- `SIGIOT` instead of `SIGABRT`
- `SIGPOLL` instead of `SIGIO`

```c
// glibc-2.36/bits/signum-arch.h

/* Archaic names for compatibility.  */
#define SIGIO           SIGPOLL /* I/O now possible (4.2 BSD).  */
#define SIGIOT          SIGABRT /* IOT instruction, abort() on a PDP-11.  */
#define SIGCLD          SIGCHLD /* Old System V name */
```

##### `strsignal(3)`, `psignal(3)`, `psiginfo(3)`

```c
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/signal.h>

void print_signal_info(int sig) {
#if defined(__APPLE__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__)
    if (sig > 0 && sig < NSIG) {
      printf("sys_signame[%d]=%s, sys_siglist[%d]=%s, strsignal[%d]=%s\n",
             sig, sys_signame[sig], sig, sys_siglist[sig], sig, strsignal(sig));
    }
#else
    printf("strsignal(%d): %s\n", sig, strsignal(sig));
#endif
}

int main(int argc, char *argv[]) {
  for (int i = 0; i < NSIG; i++) {
    print_signal_info(i);
  }
  psignal(SIGSTOP, "STOP");
  psignal(SIGTSTP, "TSTP");
  return 0;
}
```

#### Hardware exception
- Divide by 0 -> `SIGFPE`
- Invalid memory reference -> `SIGSEGV` (segmentation fault)

#### Software condition
- `SIGURG`, `SIGPIPE`, `SIGALRM`
- `kill(2)` send any signal to a process or process group.

### Disposition of the Signal

- Ignore the signal except for `SIGKILL` and `SIGSTOP`
- Catch the signal via signal-catching function except for `SIGKILL` and `SIGSTOP`
- Apply the default action

Every signal has a default action that the kernel will take if the process
hasn't changed it.

**`SIGKILL`** and **`SIGSTOP`** cannot be ignored, caught or blocked. It means
the disposition of either signal cannot be altered and is always to apply the
default action.

`kill -KILL <PID>` always kills the process immediately
`kill -STOP <PID>` always suspends the process immediately

#### `SIGSTOP` and `SIGTSTP`


| Signal      | Number (on your system) | Default action | Typical source                        | `strsignal()`          |
| ----------- | ----------------------- | -------------- | ------------------------------------- | ---------------------- |
| **SIGSTOP** | 17 (Linux: often 19)    | Stop (suspend) | Sent only by `kill` or kernel         | `"Suspended (signal)"` |
| **SIGTSTP** | 18 (Linux: often 20)    | Stop (suspend) | Sent by terminal driver on `<CTRL-Z>` | `"Suspended"`          |


#### Which signals can terminate `pause()` in an infinite loop?

```c
while(1) pause();
```

If a process hasn't change its signal dispositions, then all signals are at
their **default disposition**.

- Signals with default action = **terminate** will kill the process.
  - `SIGINT`, `SIGQUIT`, `SIGKILL`, `SIGTERM`, `SIGHUP`, `SIGSEGV`, etc.
- Signals with default action = **stop** will suspend the process.
  - `SIGSTOP`, `SIGTSTP`, `SIGTTIN`, `SIGTTOU`, etc.
- Signals with default action = **ignore** will be discarded.
  - `SIGURG`, `SIGCHLD`, `SIGCONT`, `SIGWINCH`, etc.

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

A signal may be sent if the sender's effective UID or real UID equals the
receiver's real UID or effective UID. Or the sender has superuser privilege.

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

## `signal(3)/signal(2)` function

`signal(3)` allows for a signal to be caught, to be ignored, or to generate an
interrupt. It registers a handler into a per-process signal disposition table
stored **in the kernel**. Each process has its own independent table. `fork()`
make the child inherits its parent's dispositions.

Returns the old (previous) disposition of the signal.

`signal(3)` facility is a simplified interface to the more general
`sigaction(2)` facility. On macOS, `signal(3)` is a wrapper around
`sigaction(2)` for backward compatibility. On Linux, `signal(2)` is a system
call like `sigaction(2)`. Both `signal()` are outdated, inconsistent. Use
modern `sigaction(2)` instead.

```c
#include <signal.h>
void (*signal(int, void (*)(int)))(int);
            // Returns: **previous disposition** of signal if OK, SIG_ERR on error

// friendlier declaration with a typedef
typedef void (*sighandler_t)(int);
sighandler_t signal(int, sighandler_t);

// or
typedef void Sigfunc(int);
Sigfunc *signal(int, Sigfunc *);
```

Predefined signal dispositions (handlers):

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

### Example 2: Send a signal to a process/process group/job to generate core dump

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

### Example 3: Register SIG_IGN disposition to signals SIGINT and SIGQUIT

In **earlier** version of UNIX, **older** interactive shells have:
- No concept of process groups
- No `tcsetpgrp(3)`

This means "No job control" and no `bg`, `fg` commands. All children of a
shell shared the same controlling terminal and got the same terminal-generated
signals.

To avoid terminal-generated signals like `CTRL-C` m affecting background
processes, the shell manually set `SIGINT` and `SIGQUIT` dispositions to
`SIG_IGN` for background processes.

In no-job-control era, by "foreground" and "background" , it means:

- Foreground
  - The shell `fork()`s and `exec()`s the program
  - The shell `wait()`s or `waitpid()`s for the child
  - While waiting, the shell is blocked.
- background `cmd &`
  - The shell `fork()`s but doesn't wait for its child.
  - The shell remains usable while the child runs.

An interactive program during that time wants to catch `SIGINT` must first
check if it inherited ignore; if so, it continues to ignore. Otherwise, it
installs its own handler.

```c
void sig_int(int), sig_quit(int);
if (signal(SIGINT, SIG_IGN) != SIG_IGN)
  signal(SIGINT, sig_int);
if (signal(SIGQUIT, SIG_IGN) != SIG_IGN)
  signal(SIGQUIT, sig_quit);
```

In **modern** Unix shell with job control (process groups and `tcsetpgrp`),
the terminal driver only sends signals to the foreground process group.
Background jobs simply never receive `SIGINT`/`SIGQUIT` from the terminal. The
shell doesn't need to set them to `SIG_IGN` anymore — though many still do
around exec() to avoid races. A race here is about an incoming interrupt
during a small time window between the shell `fork()`s a children and
`exec()`s a new command.

***NOTE:***
A limitation of `signal()`: unable to determine the current disposition of a
signal without changing the disposition (exchange: set new, return old).

## Process States

On a Linux system, `ps` state column


| Code  | Meaning                                                               |
| ----- | --------------------------------------------------------------------- |
| **R** | Running (or runnable, on run queue)                                   |
| **S** | Interruptible sleep (waiting for event/signal)                        |
| **D** | Uninterruptible sleep (usually I/O wait)                              |
| **T** | Stopped (by signal or tracing/debugging)                              |
| **t** | Tracing stop (specifically being traced)                              |
| **Z** | Zombie (terminated, not reaped)                                       |
| **X** | Dead (shouldn’t appear; internal use)                                 |
| **I** | Idle kernel thread (Linux-specific, seen with `ps` on recent kernels) |


- Sleeping (also **blocked**): process not on CPU and waiting for event
  - interruptible sleep (`S` in `ps`)
    - blocked by user-space visible I/O system call, `read(2)`, `write(2)`
    - blocked by timer, e.g. `pause(3)`
  - uninterruptible sleep (`D` in `ps`, on Linux; `U`, on macOS)
    - signals cannot be delivered until the process wakes naturally
    - critical kernel paths, I/O with hardware where interruption could
      corrupt data

- Stopped (also **suspended**): process in halted state
  - `T` in `ps`
  - still occupy memory and keep its resources open
  - can be resumed by `SIGCONT` signal
    - via `kill`
    - via shell job control commands:
      - `bg`: continue in the background
      - `fg`: continue and bring it back to foreground


## Reentrant Functions

By reentrant, it means async-signal safe.

Call a nonreentrant function from a signal handler, the results are
unpredictable. Nonreentrant functions:

- use static data structures
- call `malloc` or `free`
- part of the standard I/O library (use global data structures)

e.g. `printf` is a NOT reentrant function.

Reentrant functions are:

```c
abort         faccessat     linkat        select        socketpair
accept        fchmod        listen        sem_post      stat
access        fchmodat      lseek         send          symlink
aio_error     fchown        lstat         sendmsg       symlinkat
aio_return    fchownat      mkdir         sendto        tcdrain
aio_suspend   fcntl         mkdirat       setgid        tcflow
alarm         fdatasync     mkfifo        setpgid       tcflush
bind          fexecve       mkfifoat      setsid        tcgetattr
cfgetispeed   fork          mknod         setsockopt    tcgetpgrp
cfgetospeed   fstat         mknodat       setuid        tcsendbreak
cfsetispeed   fstatat       open          shutdown      tcsetattr
cfsetospeed   fsync         openat        sigaction     tcsetpgrp
chdir         ftruncate     pause         sigaddset     time
chmod         futimens      pipe          sigdelset     timer_getover
chown         getegid       poll          sigemptyset   timer_gettime
clock_gettime geteuid       posix_trace_e sigfillset    timer_settime
close         getgid        pselect       sigismember   times
connect       getgroups     raise         signal        umask
creat         getpeername   read          sigpause      uname
dup           getpgrp       readlink      sigpending    unlink
dup2          getpid        readlinkat    sigprocmask   unlinkat
execl         getppid       recv          sigqueue      utime
execle        getsockname   recvfrom      sigset        utimensat
execv         getsockopt    recvmsg       sigsuspend    utimes
execve        getuid        rename        sleep         wait
_Exit         kill          renameat      sockatmark    waitpid
_exit         link          rmdir         socket        write
```

## Reliable Signals

### Life Cycle States

- **Generated**: event that raises a signal.
- **Pending**: signal has been generated but not yet delivered.
- **Blocked**: signal is masked in the process’s signal mask; if generated,
           it stays pending until unblocked.
- **Delivered**: kernel acts on the signal (default action or custom handler).

We say that a signal is **delivered** to a process when the action for a
signal is **taken**.

Each process has a ***signal mask*** that defines the set of signals currently
blocked from delivery to that process. If the bit is on for a given signal,
that signal is currently blocked (See `sigset_t`, `sigprocmask(2)`,
`sigsuspend(2)`).

- Traditional UNIX:

  - Signal delivery checks mostly happened when returning from a syscall (the
    "trap return" path).

- Modern kernels (Linux, *BSD, macOS, etc.):

  - Pending signals are checked in multiple places:

    - Syscall exit path (still true).
    - Syscall entry path — before a syscall actually executes, the kernel may
      deliver pending signals first.
    - When a task is about to sleep / block (e.g. `pause(3)`, `sigsuspend(2)`,
      `nanosleep(2)`). These blocking syscalls explicitly re-check pending signals
      before putting the process to sleep.
    - When a process is scheduled back onto a CPU — some kernels check signals
      when returning from the scheduler.

- Data structures in kernel to trace pending signals (the conceptual level):

  - Each process (task) has:

    - **Blocked mask**: which signals are currently blocked (`sigprocmask(2)`
      manipulates this).
    - **Pending signals**: two levels:
      - Per-thread pending set (signals directed specifically to this thread).
      - Shared, process-wide pending set (signals directed to the process as a whole).

  Both are tracked using a `sigset_t`-like bitmap plus, for real-time signals,
  a queue of `sigqueue` structures.

  Thus,

  - Non-RT signals:
    - Not queued.
    - Only a single bit per signal number in the pending set.
    - If the same signal arrives multiple times while blocked, only one pending
      instance is remembered.
    - Example: 10 `kill -USR1 ..` → process only sees one delivery if blocked.

  - RT signals:
    - Queued in a per-process linked list (`struct sigqueue`).
    - Each arrival is preserved and delivered separately, in order.
    - Example: 10 `kill -RTMIN ..` → process receives handler invoked 10 times.


### `kill(2)` and `raise(3)` Functions

`kill(2)` sends a signal to a process or a group of processes. `raise(3)`
allows a process send a signal to itself.

```c
#include <signal.h>
int kill(pid_t pid, int signo);
int raise(int signo);
                                // Both return: 0 if OK, −1 on error
```

`raise(signo);` is equivalent to `kill(getpid(), signo);`

The superuser can send signals to any process. For other users, the basic rule
is that the real or effective user ID of the sender has to equal the real or
effective user ID of the receiver. One special case: if the signal being sent
is `SIGCONT`, a process can send it to any other process in the same session.

### `alarm(3)` and `pause(3)`

- the kernel schedules `SIGALRM` to be sent after TIMEOUT seconds
- install custom handler before call `alarm(3)` or default action is terminate
- only one alarm clock per process, refreshed by every call returning unslept
  time of last alarm
- `alarm(0)` voids the current alarm and `SIGALRM` will not be delivered
- `pause(3)` causes the calling thread pause until a signal is received from
  `kill(2)` or an interval timer. (See `setitimer(2)`.)
- `alarm(3)` is obsoleted by `setitimer(2)`

#### Example 1: Default action - terminate
```c
int main(int argc, char *argv[]) {
  alarm(5); // modern version: setitimer(2)
  pause();  // modern version: sigsuspend(2)
            // race-condition-safe, precise control over signal masking
  return 0;
}

/*

> ./Debug/signals/sigalarm
[2]    16246 alarm      ./Debug/signals/sigalarm
> echo $?
142           <- (128 + SIGALRM(14))

 */
```

**NOTE: Two types of return code:**

- Normal Exit Status (0-255)

When a program exits normally (e.g., by calling `exit(n)`, or by returning `n`
from `main`), the reported exit status is `(n % 256)`.
  - 0: Indicates success
  - Non-zero (1-255): Indicates an error or failure

The POSIX shell (and the `waitpid` system call) will report the exit status
by:
  - `WIFEXITED(status)` returns `true`
  - `WIFSIGNALED(status)` returns `false`
  - `WEXITSTATUS(status)` returns `n % 256`

- Termination by Signal (128 + Signal Number)

If a process is terminated by an uncaught signal, it doesn't return a value.
The POSIX shell (and the `waitpid` system call) will report an exit status
that indicates it was terminated by a signal. The common convention is:
  - `128 + <signal number>`

The `waitpid` will report the status by:
  - `WIFEXITED(staus)` returns `false`
  - `WIFSIGNALED(status)` returns `true`
  - `WTERMSIG(status)` returns `<signal number>`

#### Example 2: Pause until `SIGALRM` is received

```c
volatile sig_atomic_t got_alarm = 0;

void sig_alrm(int);

int main(int argc, char *argv[]) {
  pid_t pid;
  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) { // child
    sleep(2);
    printf("I'm child: %d, my parent ps info:\n", getpid());
    ps(getppid());
    exit(0);
  } else {
    if (signal(SIGALRM, sig_alrm) == SIG_ERR) {
      my_perror("error: signal");
    }
    printf("I'm parent: %d\n", getpid());
    alarm(3);
    while (got_alarm == 0) {
      pause();    // returns after any caught signal is delivered
                  // during pause, the process is still in running/sleep state
                  // not suspended
    }
    alarm(0);
    printf("Alarm: Time out!\n");
  }
  return 0;
}

void sig_alrm(int signo) {
  got_alarm = 1;
  printf("sig_alrm handler: I'm: %d\n", getpid());
}

/*

> ./Debug/signals/sigalarm2
I'm parent: 74574
I'm child: 74575, my parent ps info:
  UID   PID  PPID  PGID   SESS TTY      STAT COMM
  501 74574 49433 74574      0 ttys001  S+   ./Debug/signals/sigalarm2
sig_alrm handler: I'm: 74574
Alarm: Time out!

 */
```

#### Example 3: Set timeout for "slow" I/O

```c
...
static void sig_alrm(int signo) {};

int main(void) {
...
  signal(SIGALRM, sig_alrm);
  alarm(TIMEOUT);
  // slow I/O, read(), write() on some slow devices
  alarm(0);
...
```

##### Problems

- race condition between first `alarm` call and "slow" I/O call. If the kernel
  blocks the process between the two calls for longer than the alarm period,
  then signal could be delivered before the I/O syscall. When the I/O call
  blocks the process, no `SIGALRM` being to generated again.
- `sigaction.sa_flags = SA_RESTART`, make the process automatically restart
  interrupted syscalls that are restartable.

In both cases, the aim to set a timeout to a slow operation is not achieved.

##### Fixes

###### Option 1: `setjmp(3)` and `longjmp(3)`

Drawbacks: Bypass stack frame unwinding, unnecessary `longjmp` after
successful "slow" I/O but before `alarm(0)`. Not signal-safe.

```c
static jmp_buf env;
static void sig_alrm(int signo) {
  longjmp(env, 1);
}

int main(void) {
  ...
  if (signal(SIGALRM, sig_alrm) == SIG_ERR) {
    my_perror("error: signal");
    return 1;
  }

  if (setjmp(env) != 0) { // Returns 0 first time, 1 if longjmp called
    printf("Time out!\n");
    return 1;
  }

  alarm(TIMEOUT);
  // slow I/O
  alarm(0);

...
}
```

###### Option 2: Use `select()`/`poll()` with Timeout (Suggested)

###### Option 3: Use Thread-Based Timeouts

Revisit Option 2&3 later.

### `sigprocmask(2)`

```c
#include <signal.h>
int
sigprocmask(int how, const sigset_t *restrict set, sigset_t *restrict oset);
                                            // Returns: 0 if OK, −1 on error
// how: SIG_BLOCK, SIG_UNBLOCK, SIG_SETMASK
```

The  `sigprocmask(2)` examines ***and/or*** changes the current signal mask
(those signals that are blocked from delivery).  Signals are blocked if they
are members of the current signal mask set.

After calling `sigprocmask(2)`, if any unblocked signals are pending, at least
one of these signals is delivered to the process before `sigprocmask(2)` returns.

**NOTE:**
1. Why at least one of previous pending signals should be delivered before
`sigprocmask(2)` returns?

This is based on the consideration that in some earlier POSIX implementations,
many kernels only performed the "check for pending signals + deliver them"
step when returning from a system call (the syscall exit path).

- Avoid a "lost window" between blocking and unblocking
- Avoid that sleep-forever race
- When you unblock the pending signals with `sigprocmask(2)`
  - If the kernel did not deliver any signal before returning, user code would
    resume as if nothing had happened.
  - That would look indistinguishable from "no signals are pending."
  - If you then immediately called another blocking primitive (say `pause(3)`
    or `sigsuspend(2)`), you could end up sleeping forever, even though a
    signal was already pending.


| Signal type       | Queue          | Delivery order for pending vs new                        |
| ----------------- | -------------- | -------------------------------------------------------- |
| Standard signals  | Bit per signal | Unspecified if multiple unblocked; usually pending first |
| Real-time signals | Full queue     | FIFO by arrival; lower numbers first                     |


#### Example : Examine and change signal mask of the caller process.

```c
int main(int argc, char *argv[]) {
  sigset_t mask, old, delta;
  sigemptyset(&old);
  sigprocmask(0, NULL, &old);             // get current masked signals
  pr_mask2("      Old Mask: ", &old);
  pr_mask ("  Current Mask: ");

  sigemptyset(&delta);
  sigaddset(&delta, SIGABRT);
  pr_mask2(" Block signals: ", &delta);
  sigprocmask(SIG_BLOCK, &delta, NULL);   // union of current and delta
  pr_mask ("  Current Mask: ");

  sigfillset(&mask);
  sigdelset(&mask, SIGABRT);              // remove SIGABRT from complete set
  pr_mask2("   Mask to set: ", &mask);
  sigprocmask(SIG_SETMASK, &mask, &old);  // set current to mask (exclude
                                          // SIGKILL & SIGSTOP)
  pr_mask ("  Current Mask: ");

  sigemptyset(&delta);
  sigaddset(&delta, SIGQUIT);
  pr_mask2("Unblock signal: ", &delta);
  sigprocmask(SIG_UNBLOCK, &delta, &old); // subtract delta from current
  pr_mask ("  Current Mask: ");

  sigemptyset(&delta);
  sigaddset(&delta, SIGSTOP);
  sigaddset(&delta, SIGKILL);
  pr_mask2(" Block signals: ", &delta);
  sigprocmask(SIG_BLOCK, &delta, &old);   // union of current and delta
                                          // (exclude SIGKILL & SIGSTOP)
  pr_mask ("  Current Mask: ");

  return 0;
}

/*

> Debug/signals/sigmask
      Old Mask:
  Current Mask:
 Block signals:  SIGABRT
  Current Mask:  SIGABRT
   Mask to set:  SIGINT SIGQUIT SIGUSR1 SIGUSR2 SIGALRM SIGTSTP SIGCHLD SIGKILL SIGSTOP
  Current Mask:  SIGINT SIGQUIT SIGUSR1 SIGUSR2 SIGALRM SIGTSTP SIGCHLD
Unblock signal:  SIGQUIT
  Current Mask:  SIGINT SIGUSR1 SIGUSR2 SIGALRM SIGTSTP SIGCHLD
 Block signals:  SIGKILL SIGSTOP
  Current Mask:  SIGINT SIGUSR1 SIGUSR2 SIGALRM SIGTSTP SIGCHLD

 */

```

### `sigpending(2)`

```c
#include <signal.h>
int sigpending(sigset_t *set);
```

Returns a mask of the signals pending for delivery to the calling process in
the location indicated by `set`.

```c
static void sig_quit(int);

int main(void) {
  sigset_t newmask, oldmask, pendmask;

  if (signal(SIGQUIT, sig_quit) == SIG_ERR) err_sys("can't catch SIGQUIT");

  /*
   * Block SIGQUIT and save current signal mask.
   */
  sigemptyset(&newmask);
  sigaddset(&newmask, SIGQUIT);
  if (sigprocmask(SIG_BLOCK, &newmask, &oldmask) < 0)
    err_sys("SIG_BLOCK error");

  sleep(5); /* SIGQUIT here will remain pending */

  if (sigpending(&pendmask) < 0) err_sys("sigpending error");
  if (sigismember(&pendmask, SIGQUIT)) printf("\nSIGQUIT pending\n");

  /*
   * Restore signal mask which unblocks SIGQUIT.
   */
  if (sigprocmask(SIG_SETMASK, &oldmask, NULL) < 0)
    err_sys("SIG_SETMASK error");
  printf("SIGQUIT unblocked\n");  // sig_quit runs before sigprocmask returns

  sleep(5); /* SIGQUIT here will terminate with core file */
  exit(0);
}

static void sig_quit(int signo) {
  printf("caught SIGQUIT\n");
  if (signal(SIGQUIT, SIG_DFL) == SIG_ERR) err_sys("can't reset SIGQUIT");
}

/*
$ ./a.out
ˆ\                          generate signal once (before 5 seconds are up)
SIGQUIT pending             after return from sleep
caught SIGQUIT              in signal handler
SIGQUIT unblocked           after return from sigprocmask
ˆ\Quit(coredump)            generate signal again
$ ./a.out
ˆ\ˆ\ˆ\ˆ\ˆ\ˆ\ˆ\ˆ\ˆ\ˆ\        generate signal 10 times (before 5 seconds are up)
SIGQUIT pending
caught SIGQUIT              signal is generated only once
SIGQUIT unblocked
ˆ\Quit(coredump)            generate signal again

 */
```

### `sigaction(2)`

Supersedes the `signal(2)` function from earlier releases of the UNIX System.

When a signal is delivered to a process a new signal mask is installed for the
duration of the process’ signal handler (or until a `sigprocmask(2)` system
call is made). This mask is formed by taking the union of the current signal
mask set, the signal to be delivered, and the signal mask associated with the
handler to be invoked.

```c
#include <signal.h>
int sigaction(int signo, const struct sigaction *restrict act,
              struct sigaction *restrict oact);
                                        // Returns: 0 if OK, −1 on error

struct  sigaction {
  union __sigaction_u __sigaction_u;    /* signal handler */
  sigset_t sa_mask;                     /* signal mask to apply */
  int     sa_flags;                     /* see signal options below */
};

union __sigaction_u {
  void (*__sa_handler)(int);
  void (*__sa_sigaction)(int, siginfo_t *, void *);
};

#define sa_handler      __sigaction_u.__sa_handler
#define sa_sigaction    __sigaction_u.__sa_sigaction

typedef struct __siginfo {
	int     si_signo;               /* signal number */
	int     si_errno;               /* errno association */
	int     si_code;                /* signal code */
	pid_t   si_pid;                 /* sending process */
	uid_t   si_uid;                 /* sender's ruid */
	int     si_status;              /* exit value */
	void    *si_addr;               /* faulting instruction */
	union sigval si_value;          /* signal value */
	long    si_band;                /* band event for SIGPOLL */
	unsigned long   __pad[7];       /* Reserved for Future Use */
} siginfo_t;
```

An implementation of `signal(2)` using `sigaction(2)`

```c

#include "apue.h"
/* Reliable version of signal(), using POSIX sigaction().  */
Sigfunc *
signal(int signo, Sigfunc *func)
{
  struct sigaction    act, oact;
  act.sa_handler = func;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;
  if (signo == SIGALRM) {
#ifdef  SA_INTERRUPT
    act.sa_flags |= SA_INTERRUPT;
#endif
  } else {
    act.sa_flags |= SA_RESTART;
  }
  if (sigaction(signo, &act, &oact) < 0)
    return(SIG_ERR);
  return(oact.sa_handler);
}
```

#### Examples: Examine and change signal mask 2

```c
void sig_intr(int);
void sig_usr1(int);

static volatile int intr_flag = 0;

int main(int argc, char *argv[]) {

  printf ("Let's examine how the signal mask of the process is changed:\n\n");

  struct sigaction act, oact;
  sigemptyset(&act.sa_mask); /* Initialize sa_mask to empty */
  act.sa_flags = 0;           /* Set flags to 0 for default behavior */
  act.sa_handler = sig_usr1;
  if (sigaction(SIGUSR1, &act, &oact) < 0) {
    my_perror("error: sigaction");
  } else {
    printf("Original signal handler for SIGUSR1: %p\n", oact.sa_handler);
  }

  Sigfunc *pOHand;
  if ((pOHand = signal(SIGINT, sig_intr)) == SIG_ERR) {
    my_perror("error: signal");
  } else {
    printf("Original signal handler for SIGINT: %p\n", pOHand);
  }

  sigset_t mask;
  sigemptyset(&mask);
  sigaddset(&mask, SIGABRT);
  sigaddset(&mask, SIGQUIT);
  sigaddset(&mask, SIGINT);
  sigprocmask(SIG_SETMASK, &mask, NULL);
  pr_mask("Main: initial setup signal mask after sigprocmask: ");

  while(1) {
    pause();
    if (intr_flag == 1) {
      sigemptyset(&mask);
      sigaddset(&mask, SIGINT);
      sigprocmask(SIG_UNBLOCK, &mask, NULL);
      pr_mask("Main: after sigprocmask, unblock SIGINT: ");
      intr_flag = 2;
    }
    pr_mask("Main: ");
  }

  return 0;
}

void sig_intr(int signo) {
  pr_mask("sig_intr: ");
  if (intr_flag == 3) {
    printf("exit(1111)\n");
    exit(1111); // normal exit: $? = status % 256 = 87
  }
}

void sig_usr1(int signo) {
  pr_mask("sig_usr1: ");
  if (intr_flag == 0) {
    printf("sig_usr1: change intr_flag to 1\n");
    intr_flag = 1;
  } else if (intr_flag == 2) {
    printf("sig_usr1: change intr_flag to 3\n");
    intr_flag = 3;
  } else {
    printf("sig_usr1: intr_flag is %d\n", intr_flag);
  }
}


/*

# Shell A:
> ./Debug/signals/sigmask2
Let's examine how the signal mask of the process is changed:

Original signal handler for SIGUSR1: 0x0
Original signal handler for SIGINT: 0x0
Main: initial setup signal mask after sigprocmask:  SIGINT SIGQUIT SIGABRT
^C^C^Csig_usr1:  SIGINT SIGQUIT SIGUSR1 SIGABRT   <-- kill -USR1 81753
sig_usr1: change intr_flag to 1
sig_intr:  SIGINT SIGQUIT SIGABRT                 <-- unblocked pending signal delivered before sigprocmask returns
Main: after sigprocmask, unblock SIGINT:  SIGQUIT SIGABRT
Main:  SIGQUIT SIGABRT
^Csig_intr:  SIGINT SIGQUIT SIGABRT               <-- avoid re-entrancy issue during the time of execution a handler
Main:  SIGQUIT SIGABRT
sig_usr1:  SIGQUIT SIGUSR1 SIGABRT                <-- kill -USR1 81753
sig_usr1: change intr_flag to 3
Main:  SIGQUIT SIGABRT
^Csig_intr:  SIGINT SIGQUIT SIGABRT
exit(1111)
> echo $?
87                                                <-- normal exit, status % 256

# Shell B:
> pgrep sigmask
81753
> kill -USR1 81753
> kill -USR1 81753

NOTE:
1. When a signal (e.g. SIGINT) is blocked, only one instance is recorded
   as pending after sending multiple <CTRL-C>s.
2. At least one of unblocked pending signals is selected to deliver before
   sigprocmask(2), which change the mask setting, returns.
3. During the execution of signal-catching handler, the signal causes it is
   temporarily added to the mask and removed after the execution, to avoid
   re-entrancy issue (recursive calls of the handler).
4. Two types of terminations and different shell return code:
   4.1 Normal `exit(n)`: rc = n % 256
   4.2 Terminated by signal: rc = 128 + <signal number>
 */

```

#### Examples: Restartable (with `SA_RESTART`) and non-restartable syscalls

- Common restartable syscalls (with SA_RESTART):

  - read() (on files, sockets sometimes)
  - write() (on files, sockets sometimes)
  - open() (but not on special files like FIFOs sometimes)
  - close() (usually, but not always meaningful)
  - recv(), recvfrom(), recvmsg()
  - send(), sendto(), sendmsg()
  - wait(), waitpid()
  - msgrcv(), msgsnd() (System V IPC)
  - select(), pselect()
  - poll(), ppoll()
  - readv(), writev()
  - sigprocmask()
  - nanosleep()

- Common non-restartable syscalls (always return EINTR):

  - accept() — on old kernels, sometimes restartable on newer kernels
  - connect() — interrupted during blocking connect
  - sleep() — standard sleep interrupted
  - pause() — always interrupted by signals
  - futex() — some futex operations (depends on flags)
  - recv() / send() on some sockets (especially non-blocking)
  - open() on FIFOs / pipes when no writer is present


```c
void sig_hand(int signo) {
  // just for test, shouldn't use non-reentrant `printf` in a signal handler
  printf("sig_hand: [%s] is caught by PID[%d].\n", strsignal(signo), getpid());
}

void non_restartable_syscall_test() {
  pid_t pid;
  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) {  // child
    printf("Child[PID=%d]: blocking on pause()...\n", getpid());
    pause();  // not restartable
    printf("Child[PID=%d]: Exiting...\n", getpid());
    exit(0);
  } else {
    sleep(2);
    printf("Parent[PID=%d]: Send [%s] to Child[%d]\n",
        getpid(), strsignal(SIGINT), pid);
    kill(pid, SIGINT);
    wait(NULL);
    printf("Parent[PID=%d]: Exiting non_restartable_syscall_test()\n",
           getpid());
  }
}

void restartable_syscall_test() {
  pid_t pid;
  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) {  // child
    char buf[BUFSIZ];
    size_t n;
    printf("Child[PID=%d]: blocking on read()...\n", getpid());
    while ((n = read(STDIN_FILENO, buf, sizeof(buf)-1)) > 0) {
      buf[n] = '\0';
      printf("Child[PID=%d]: Read %ld chars: [%s]\n", getpid(), n, buf);
    }
    if (n == 0) {
      printf("Child[PID=%d]: End of reading.\n", getpid());
      exit(0);
    } else {
      my_perror("Child[PID=%d]: error: read", getpid());
      exit(1);
    }
  } else {
    sleep(1);
    int exitFlag = 3;
    while (exitFlag-- > 0) {
      sleep(3);
      printf("Parent[%d]: Send [%s] to Child[%d]\n",
          getpid(), strsignal(SIGINT), pid);
      kill(pid, SIGINT);
    }
    sleep(1);
    printf("Parent[PID=%d]: Now wait() for the child."
           "Type <CTRL-D> to end the talk.\n\n", getpid());
    wait(NULL);
    printf("Parent[PID=%d]: Exiting estartable_syscall_test()\n", getpid());
  }
}

int main(int argc, char *argv[]) {
  struct sigaction act = {0}, oact = {0};
  act.sa_flags |= SA_RESTART;
  act.sa_handler = sig_hand;

  if (sigaction(SIGINT, &act, &oact) < 0) {
    my_perror("error: sigaction");
  }

  pr_sep_msg('-', 25, "non_restartable_syscall_test()");
  non_restartable_syscall_test();
  pr_sep_msg('-', 25, "restartable_syscall_test()");
  restartable_syscall_test();
  return 0;
}

/*
 * Sample:
> ./Debug/signals/sigaction
-------------------------  non_restartable_syscall_test()  -------------------------
Child[PID=65200]: blocking on pause()...
Parent[PID=65199]: Send [Interrupt: 2] to Child[65200]
sig_hand: [Interrupt: 2] is caught by PID[65200].
Child[PID=65200]: Exiting...
Parent[PID=65199]: Exiting non_restartable_syscall_test()
-------------------------  restartable_syscall_test()  -------------------------
Child[PID=65245]: blocking on read()...
Parent[65199]: Send [Interrupt: 2] to Child[65245]
sig_hand: [Interrupt: 2] is caught by PID[65245].
Parent[65199]: Send [Interrupt: 2] to Child[65245]
sig_hand: [Interrupt: 2] is caught by PID[65245].
Parent[65199]: Send [Interrupt: 2] to Child[65245]
sig_hand: [Interrupt: 2] is caught by PID[65245].
Parent[PID=65199]: Now wait() for the child.Type <CTRL-D> to end the talk.

Hello, world!
Child[PID=65245]: Read 14 chars: [Hello, world!
]
Hello, world!Child[PID=65245]: Read 13 chars: [Hello, world!]
The difference is: 1) first input ended with new line 2) 2nd input ended with <CTRL-D> (EOF).
Child[PID=65245]: Read 94 chars: [The difference is: 1) first input ended with new line 2) 2nd input ended with <CTRL-D> (EOF).
]
Child[PID=65245]: End of reading.
Parent[PID=65199]: Exiting estartable_syscall_test()
 */
```


### `sigsetjmp(2)` and `siglongjmp(2)`

```c
#include <setjmp.h>
int sigsetjmp(sigjmp_buf env, int savemask);
    // Returns: 0 if called directly, nonzero if returning from a call to siglongjmp
void siglongjmp(sigjmp_buf env, int val);
```

When a signal is caught, the signal-catching function is entered, with the
current signal automatically being added to the signal mask of the process.
This prevents subsequent occurrences of that signal from interrupting the
signal handler.

To save and restore the signal mask of the process when `longjmp` from signal
handler (i.e. branching from a signal handler), use `sigsetjmp` and `siglongjmp`
which save `savemask` to `jmp_buf` via `sigsetjmp` and restore it later.


![Timeline for handling two signals](<./images/Timeline for example program handling two signals.png>)

### `sigsuspend(2)`

A modern race-condition-safe version of `pause(3)`, atomically release blocked
signals and wait for interrupt. It always terminates by being interrupted.

```c
#include <signal.h>
int sigsuspend(const sigset_t *sigmask);
                                    // Returns: −1 with errno set to EINTR
```

Temporarily changes the blocked signal mask to the set to which `sigmask`
points, and then waits for a signal to arrive; on return the previous set of
masked signals is restored.

`sigsuspend(2)` provides an **atomic operation** that combines three actions:

1.  **Temporarily changes the process's signal mask** to the set specified by
    its `sigmask` argument.
2.  **Suspends the process** until a signal is caught.
3.  **Restores the process's original signal mask** (the one that was active
    before `sigsuspend` was called) upon returning.

```c
sigprocmask(SIG_SETMASK, &newmask, &oldmask);   // (Unblock desired signals)
pause();                                        // Wait for a signal
sigprocmask(SIG_SETMASK, &oldmask, NULL);       // (Restore original mask)
```

#### `alarm(3)` + `sigsuspend(2)` implementing `sleep(3)`

```c
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <dlfcn.h>

static void sig_alrm(int signo) {
  /* nothing to do, just returning wakes up sigsuspend() */

  /* Just for mark the difference for test */
  printf("sig_alrm\n");
}


unsigned int sleep(unsigned int seconds) {
  struct sigaction newact, oldact;
  sigset_t newmask, oldmask, suspmask;
  unsigned int unslept;

  /* set our handler, save previous information */
  newact.sa_handler = sig_alrm;
  sigemptyset(&newact.sa_mask);
  newact.sa_flags = 0;
  sigaction(SIGALRM, &newact, &oldact);

  /* block SIGALRM and save current signal mask */
  sigemptyset(&newmask);
  sigaddset(&newmask, SIGALRM);
  sigprocmask(SIG_BLOCK, &newmask, &oldmask);

  alarm(seconds);
  suspmask = oldmask;

  /* make sure SIGALRM isn't blocked */
  sigdelset(&suspmask, SIGALRM);

  /* wait for any signal to be caught */
  sigsuspend(&suspmask);

  /* some signal has been caught, SIGALRM is now blocked */

  unslept = alarm(0);

  /* reset previous action */
  sigaction(SIGALRM, &oldact, NULL);

  /* reset signal mask, which unblocks SIGALRM */
  sigprocmask(SIG_SETMASK, &oldmask, NULL);
  return (unslept);
}

int main(int argc, char *argv[]) {
  int timeout = 5;
  if (argc > 1) {
    int n = atoi(argv[1]);
    if (n > 0) timeout = n;
  }
  printf("Call local sleep(%d)\n", timeout);
  sleep(timeout);   // strong definition overrides weak alias of libc

  // unsigned int (*libc_sleep)(unsigned int) = NULL;
  __typeof(sleep) *libc_sleep = dlsym(RTLD_NEXT, "sleep");
  printf("Call the C standard library sleep(%d)\n", timeout);
  libc_sleep(timeout);
  return 0;
}

/*
> Debug/signals/sleep
Call local sleep(5)
sig_alrm
Call the C standard library sleep(5)
>
 */
```

#### Difference between timer and sleeper

| API           | Precision | Multiple timers? | Expiration effect                      | Non-blocking |
| ------------- | --------- | ---------------- | -------------------------------------- | ------------ |
| `alarm()`     | seconds   | No (one only)    | `SIGALRM`                              | Yes           |
| `setitimer()` | usec      | One per type     | `SIGALRM`, `SIGVTALRM`, `SIGPROF`      | Yes          |
| `sleep()`     | sec       | N/A              | Just return (no signal)                | No           |
| `nanosleep()` | nsec      | N/A              | Just return (no signal)                | No           |
| POSIX timers  | nsec      | Yes              | Signal (RT or others), thread callback | Yes          |


Old-fashioned `sleep()` is implemented with `alarm()` + `sigsuspend()` (See [implementing sleep(3)](/notes/apue/ch10-signals//#alarm3--sigsuspend2-implementing-sleep3)).

Modern `sleep(3)` is implemented using `nanosleep(2)`.

```c
#include <time.h>
int nanosleep(const struct timespec *reqtp, struct timespec *remtp);
         // Returns: 0 if slept for requested time or −1 on error

int
clock_nanosleep(clockid_t clock_id, int flags, const struct timespec *reqtp,
                struct timespec *remtp);
        // Returns: 0 if slept for requested time or error number on failure

clock_nanosleep(CLOCK_REALTIME, 0, reqtp, remtp);   // equivalent to
nanosleep(reqtp, remtp);
```

The `clock_id` argument specifies the clock against which the time delay is
evaluated.

`macOS` doesn't implement `clock_nanosleep(2)`

##### [Implementing Software Timers](http://www.kohala.com/start/libes.timers.txt)

## Some Topics

### `abort(3)`

`abort(3)` causes an abnormal termination of the program and never returns.

If `SIGABRT` is ignored or caught by a handler that returns, `abort()` shall
still terminate the process as if `SIGABRT` were not caught. It at most
`raise()`s twice.


An implementation:

```c
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void
abort(void)
{
    sigset_t
    struct sigaction    action;
    /* Caller can’t ignore SIGABRT, if so reset to default */
    sigaction(SIGABRT, NULL, &action);
    if (action.sa_handler == SIG_IGN) {
        action.sa_handler = SIG_DFL;
        sigaction(SIGABRT, &action, NULL);
    }
    if (action.sa_handler == SIG_DFL)
        fflush(NULL);           /* flush all open stdio streams */
    /* Caller can’t block SIGABRT; make sure it’s unblocked */
    sigfillset(&mask);
    sigdelset(&mask, SIGABRT);  /* mask has only SIGABRT turned off */
    sigprocmask(SIG_SETMASK, &mask, NULL);
    kill(getpid(), SIGABRT);    /* send the signal */
    /* If we’re here, process caught SIGABRT and returned */
    fflush(NULL);               /* flush all open stdio streams */
    action.sa_handler = SIG_DFL;
    sigaction(SIGABRT, &action, NULL);  /* reset to default */
    sigprocmask(SIG_SETMASK, &mask, NULL);  /* just in case ... */
    kill(getpid(), SIGABRT);                /* and one more time */
    exit(1);    /* this should never be executed ... */
}
```

### Use `waitpid()` to reap terminated child processes

Here is a typical and robust way to use `waitpid(2)` in a `SIGCHLD` signal
handler to reap terminated child processes.

```c
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <sys/_types/_pid_t.h>
#include <sys/errno.h>
#include <sys/signal.h>
#include <sys/wait.h>
#include <unistd.h>
#include "rltapue.h"

static const int CHILD_COUNT = 5;
volatile sig_atomic_t live_children = CHILD_COUNT;

void sigchld(int signo) {
  int save_err = errno;
  int stat;
  pid_t pid;
  while ((pid = waitpid(-1, &stat, WNOHANG)) > 0) {
    // printf() is not reentrant, async-signal-safe for use in signal handler
    // just for test in informal way
    printf("sigchld: Reap terminated child: %d\n", pid);
    live_children--;
  }
  errno = save_err;
}

int main(int argc, char *argv[]) {
  // sa_flags = 0, sa_handler / sigaction = NULL, sa_mask = 0
  struct sigaction act_chld = {0};
  sigemptyset(&act_chld.sa_mask); // For portability of sigset_t
  act_chld.sa_handler = sigchld;
  if (sigaction(SIGCHLD, &act_chld, NULL) < 0) {
    my_perror("error: sigaction");
  }


  for (int i = 0; i < CHILD_COUNT; i++) {
    pid_t pid;
    if ((pid = fork()) < 0) {
      my_perror("error: fork()");
    } else if (pid == 0) {
      printf("Child(%d): Enter >>>\n", getpid());
      sleep(i+1);
      printf("Child(%d): Exit <<<\n", getpid());
      exit(0);
    }
  }

  while (live_children > 0) {
    pause();
    printf ("Main: pause() was interrupted and now returned.\n");
  }
  return 0;
}

/**

> Debug/signals/waitpid
Child(78710): Enter >>>
Child(78711): Enter >>>
Child(78712): Enter >>>
Child(78713): Enter >>>
Child(78714): Enter >>>
Child(78710): Exit <<<
sigchld: Reap terminated child: 78710
Main: pause() was interrupted and now returned.
Child(78711): Exit <<<
sigchld: Reap terminated child: 78711
Main: pause() was interrupted and now returned.
Child(78712): Exit <<<
sigchld: Reap terminated child: 78712
Main: pause() was interrupted and now returned.
Child(78713): Exit <<<
sigchld: Reap terminated child: 78713
Main: pause() was interrupted and now returned.
Child(78714): Exit <<<
sigchld: Reap terminated child: 78714
Main: pause() was interrupted and now returned.
>

NOTE:

A. `pause(3)` workflow
1. `pause(3)` is called and the process sleeps.
2. A signal is delivered.
3. The operating system interrupts `pause(3)` and executes the registered
   signal handler.
4. The signal handler completes its execution and returns.
5. *Only then* does the `pause(3)` call, which was interrupted, return to the
   calling code.
If the handler calls `exit()` functions, the process just terminates w/o
returning from `pause(3)` to the calling code.

B. Reentrant and async-signal-safe calls in a signal handler

`printf(3)` is NOT reentrant, because it uses shared internal state:
   - Static/global buffers
   - Locks inside the stdio library
   - Heap allocation for formatting
   - Global variables like errno

Then it is not async-signal-safe. Example:
The main process is in the middle of `printf(3)`. Internally, libc has locked
a mutex on `stdout`'s buffer. Now a child dies, `SIGCHLD` arrives and handler
runs. In the handler, another call of `printf(3)` tries to lock the same mutex.
Since the lock is already held by the interrupted code (in `printf(3)`). Thus
deadlock happens. Besides, same `stdout` buffer can be corrupted.

 */
```

### `system(3)`

POSIX.1 requires `system(3)` ignore `SIGINT`, `SIGQUIT` and block `SIGCHLD`.
This is because sometimes, in an invocation of interactive program, like
`system("/bin/ed")`, which also catches the interrupt and quit signals. The
caller process should avoid unnecessary handling. When the program terminates,
i.e. the child created by `system(3)` terminates, it would fool the caller of
`system(3)` into thinking that one of its own children terminated.

#### An implementation:

```c
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>

int system(const char *cmdstring) /* with appropriate signal handling */
{
  pid_t pid;
  int status;
  struct sigaction ignore, saveintr, savequit;
  sigset_t chldmask, savemask;

  if (cmdstring == NULL) return (1); /* always a command processor with UNIX */

  ignore.sa_handler = SIG_IGN; /* ignore SIGINT and SIGQUIT */
  sigemptyset(&ignore.sa_mask);
  ignore.sa_flags = 0;
  if (sigaction(SIGINT, &ignore, &saveintr) < 0) return (-1);
  if (sigaction(SIGQUIT, &ignore, &savequit) < 0) return (-1);
  sigemptyset(&chldmask); /* now block SIGCHLD */
  sigaddset(&chldmask, SIGCHLD);
  if (sigprocmask(SIG_BLOCK, &chldmask, &savemask) < 0) return (-1);

  if ((pid = fork()) < 0) {
    status = -1;         /* probably out of processes */
  } else if (pid == 0) { /* child */
    /* restore previous signal actions & reset signal mask */
    sigaction(SIGINT, &saveintr, NULL);
    sigaction(SIGQUIT, &savequit, NULL);
    sigprocmask(SIG_SETMASK, &savemask, NULL);

    execl("/bin/sh", "sh", "-c", cmdstring, (char *)0);
    _exit(127); /* exec error */
  } else {      /* parent */
    while (waitpid(pid, &status, 0) < 0)
      if (errno != EINTR) {
        status = -1; /* error other than EINTR from waitpid() */
        break;
      }
  }

  /* restore previous signal actions & reset signal mask */
  if (sigaction(SIGINT, &saveintr, NULL) < 0) return (-1);
  if (sigaction(SIGQUIT, &savequit, NULL) < 0) return (-1);
  if (sigprocmask(SIG_SETMASK, &savemask, NULL) < 0) return (-1);

  return (status);
}
```

#### Test ignoring and blocking signals in `system(3)`

```c
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/signal.h>
#include "rltapue.h"

/**
 `system(3)` ignores SIGINT and SIGQUIT, blocks SIGCHLD
 */

void sig_hand(int signo) {
  printf("Caught signal[%d]=%s\n", signo, strsignal(signo));
}

int main(int argc, char *argv[]) {
  struct sigaction act = {0};
  sigemptyset(&act.sa_mask);
  act.sa_handler = sig_hand;
  if (sigaction(SIGINT, &act, NULL) < 0) {
    my_perror("error: sigaction: %d", SIGINT);
  }
  if (sigaction(SIGCHLD, &act, NULL) < 0) {
    my_perror("error: sigaction: %d", SIGCHLD);
  }
  if (sigaction(SIGUSR1, &act, NULL) < 0) {
    my_perror("error: sigaction: %d", SIGUSR1);
  }
  if (system("/bin/ed") < 0) {
    my_perror("error: system()");
  }

  pause();
  return 0;
}

/*

# Terminal A:
> Debug/signals/systemsig
a
hello
^C                                            <-- SIGINT only received by child
?                                             <-- and interrupts `ed` input
你好
?                                             <-- `ed` is in command mode
a                                             <-- needs `a` to resume appending
你好
Caught signal[30]=User defined signal 1: 30   <-- kill -USR1 89613, received by parent
Ciao
.
w out
18
q
^CCaught signal[2]=Interrupt: 2               <-- <CTRL-C> to interrupt parent pause()
> cat out
hello
你好
Ciao
>

# Terminal B:
> pgrep systemsig
89613
> kill -USR1 89613                            <-- caught by parent
> kill -INT 89613                             <-- ignored by parent
> kill -QUIT 89613                            <-- ignored by parent
> kill -CHLD 89613                            <-- blocked by parent
>

NOTE:
The above example illustrates:
1. In system(), the parent ignores SIGQUIT and SIGINT (via `sigaction(2)` and
   `(struct sigaction).sa_handler`). But the child running program via
   `exec()`, respects both.
2. In system(), parent blocks SIGCHLD (via `sigprocmask(2)`). When `ed` is
   running, received `SIGCHLD` is at pending state. When `ed` quits, the kernel
   sends another `SIGCHLD` to the parent. Standard (non-RT) signals are
   not queued, so two `SIGCHLD` collapse into one. And when `waitpid(2)` reaps
   the terminated child (`ed`), the kernel clears the pending `SIGCHLD` bit.
   Thus, even if `SIGCHLD` gets unblocked before `system()` returns, no active
   pending `SIGCHLD` left for the pause(). It keeps blocking until new signal
   arrives.
3. It needs `a` command for `ed` to resume appending mode after interruption.
4. In UTF-8 encoding, each Chinese character consists of 3 bytes.
 */
```

### `sigqueue(3)`

With the real-time extensions to POSIX.1, some systems began adding support
for queueing signals. With ***SUSv4***, the queued signal functionality has moved
from the real-time extensions to the **base** specification.

```c
#include <signal.h>
int sigqueue(pid_t pid, int signo, const union sigval value)
                                    // Returns: 0 if OK, −1 on error
```

## Exercises

### 10.6 IPC via signals

Write the following program to test the parent–child synchronization
functions in Figure 10.24. The process creates a file and writes the
integer 0 to the file. The process then calls fork, and the parent and
child alternate incrementing the counter in the file. Each time the counter
is incremented, print which process (parent or child) is doing the
increment.

#### Use buffered I/O: `fread(3)/fwrite(3)`
```c
/**
 * NOTE:
 *
 * fflush() stream buffer BEFORE fork()!!! Otherwise there will be another
 * integer 0 written in the file.
 *
 * > hexdump tmp/data/signals/sharedfile
 * 0000000 001a 0000 0000 0000
 * 0000008
 *
 * Reason:
 *
 * The problem lies in the child's first run of incre_file() and how fseek()
 * interacts with the child's inherited, unflushed buffer.
 *
 * https://pubs.opengroup.org/onlinepubs/9799919799/functions/fopen.html
 *
 * "When a file is opened with update mode ('+' in the mode argument), both
 * input and output can be performed on the associated stream. However, the
 * application shall ensure that output is not directly followed by input
 * without an intervening call to fflush() or to a file positioning function
 * (fseek(), fsetpos(), or rewind()), and input is not directly followed by
 * output without an intervening call to a file positioning function, unless
 * the input operation encounters end-of-file."
 *
 * "If the stream is writable and buffered data had not been written to the
 * underlying file, fseek() shall cause the unwritten data to be written to
 * the file and shall mark the st_ctime and st_mtime fields of the file for
 * update."

 * fseek(pf, 0, SEEK_SET); (== rewind(pf);)
 *
 * 1. init_file() calls fwrite() to write an integer 0. If there's no
 * fflush(), this 0 sits in the stdio user-space buffer. When fork() is
 * called, both the parent and child processes inherit an identical copy of
 * this memory, which includes this unflushed buffer containing the integer 0

 * 2. The Parent's Turn:
 * fseek(pf, 0, SEEK_SET): The parent's stream has pending output (the 0 in
 * its buffer). To fulfill the fseek request, the stdio library must flush the
 * buffer first. At this point, the kernel file offset is at 0, so the 0 is
 * written to the start of the file. The file now contains 00 00 00 00. The
 * fseek then completes, leaving the offset at 0.

 * fread(): Reads the 0 from the file. The kernel's file offset is now at
 * position 4.

 * fseek(pf, 0, SEEK_SET): Rewinds the kernel offset back to 0.

 * fwrite(): The parent increments the value to 1 and writes it into its
 * buffer.

 * fflush(): The parent's buffer (containing 1) is written to the file at
 * offset 0, overwriting the original 0.

 * Result of Parent's Turn: The file on disk contains the 4-byte integer 1.
 * The shared kernel file offset is now at position 4.

 * 3. The Child's Turn (The Critical Moment) This is where the 8-byte problem
 * occurs, just as you reasoned.

 * Child Wakes Up: The child begins its first run of incre_file(). Crucially,
 * its stdio buffer still contains the original, stale integer 0 that it
 * inherited from before the fork().

 * fseek(pf, 0, SEEK_SET): The child's stream also has pending output (the
 * stale 0). To handle the seek, the stdio library must flush this buffer
 * first. But where does it flush? It flushes to the current kernel file
 * offset, which the parent just left at position 4.

 * The Append: The child's stale 0 is written to the file starting at
 * offset 4. The file now contains the integer 1 (from the parent) followed
 * by the integer 0 (from the child's stale buffer). The file is now 8 bytes
 * long.

 * The Rest of the Function: The fseek now completes, moving the kernel offset
 * to 0. The child then fread()s the integer 1 from the start of the file,
 * increments it to 2, seeks back to 0, and fwrite()s/fflush()es the 2,
 * overwriting the 1.

 * The Final Result After the first round, the file's contents are:

 * Bytes 0-3: The integer 2
 * Bytes 4-7: The integer 0
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "rltapue.h"

FILE* init_file(const char *const path) {
  if (!path) return NULL;
  // Use "w+b" or "wb+" for binary read/write mode
  FILE *pf = fopen(path, "wb+");
  if (!pf) my_perror("error: fopen");

  int value = 0;
  if (fwrite(&value, sizeof(int), 1, pf) < 1) {
    if (feof(pf)) {
      printf("End of file reached.\n");
    } else if (ferror(pf)) {
      printf("Read error occurred (ferror set).\n");
    }
    my_perror("error: fwrite()");
  }
  fflush(pf); // !!! Flush the buffer to disk BEFORE fork() !!!
  return pf;
}

int incre_file(FILE *pf) {
  fseek(pf, 0, SEEK_SET); // move to the start before read, == rewind(pf);
  int value;
  if (fread(&value, sizeof(int), 1, pf) < 1) {
    if (feof(pf)) {
      printf("End of file reached.\n");
    } else if (ferror(pf)) {
      printf("Read error occurred (ferror set).\n");
    }
    my_perror("error: fwrite()");
  }
  printf("value: %d\n", value);

  fseek(pf, 0, SEEK_SET); // move to the start before write
  value++;
  if (fwrite(&value, sizeof(int), 1, pf) < 1) {
    if (feof(pf)) {
      printf("End of file reached.\n");
    } else if (ferror(pf)) {
      printf("Read error occurred (ferror set).\n");
    }
    my_perror("error: fwrite()");
  }
  fflush(pf);             // make sure push changes to disk
  return value;
}

void test(void) {
  const char *const file = "tmp/data/signals/sharedfile";
  FILE *pf = init_file(file);
  const int rounds = 13;
  TELL_WAIT();
  pid_t pid = fork();
  if (pid < 0) {
    my_perror("error: fork()");
  } else if (pid == 0) {  // child
    for (int i = 0; i < rounds; i++) {
      WAIT_PARENT();
      // critical section
      printf("Child: incrementing, value: %d\n", incre_file(pf));
      TELL_PARENT(getppid());
    }
    exit(0);
  } else {  // parent
    for (int i = 0; i < rounds; i++) {
      // critical section
      printf("Parent: incrementing, value: %d\n", incre_file(pf));
      TELL_CHILD(pid);
      WAIT_CHILD();
    }
  }
  fclose(pf);
}

int main(int argc, char **argv) {
  test();
  return 0;
}

/*

### Running in command line: stdout is line-buffered

> ./Debug/signals/Ex10_6_procsync
Parent: incrementing, value: 1
Child: incrementing, value: 2
Parent: incrementing, value: 3
Child: incrementing, value: 4
Parent: incrementing, value: 5
Child: incrementing, value: 6
Parent: incrementing, value: 7
Child: incrementing, value: 8
Parent: incrementing, value: 9
Child: incrementing, value: 10
Parent: incrementing, value: 11
Child: incrementing, value: 12
Parent: incrementing, value: 13
Child: incrementing, value: 14
Parent: incrementing, value: 15
Child: incrementing, value: 16
Parent: incrementing, value: 17
Child: incrementing, value: 18
Parent: incrementing, value: 19
Child: incrementing, value: 20
Parent: incrementing, value: 21
Child: incrementing, value: 22
Parent: incrementing, value: 23
Child: incrementing, value: 24
Parent: incrementing, value: 25
Child: incrementing, value: 26


### Running in Neovim command mode: stdout redirected to fully-buffered pipe

:!Debug/signals/Ex10_6_procsync
Child: incrementing, value: 2
Child: incrementing, value: 4
Child: incrementing, value: 6
Child: incrementing, value: 8
Child: incrementing, value: 10
Child: incrementing, value: 12
Child: incrementing, value: 14
Child: incrementing, value: 16
Child: incrementing, value: 18
Child: incrementing, value: 20
Child: incrementing, value: 22
Child: incrementing, value: 24
Child: incrementing, value: 26
Parent: incrementing, value: 1
Parent: incrementing, value: 3
Parent: incrementing, value: 5
Parent: incrementing, value: 7
Parent: incrementing, value: 9
Parent: incrementing, value: 11
Parent: incrementing, value: 13
Parent: incrementing, value: 15
Parent: incrementing, value: 17
Parent: incrementing, value: 19
Parent: incrementing, value: 21
Parent: incrementing, value: 23
Parent: incrementing, value: 25

Child exits first, its stdout buffer gets flushed first.
Parent waits for the child and exits later, stdout buffer gets flushed later.

### The content of sharedfile

> hexdump -C tmp/data/signals/sharedfile

00000000  1a 00 00 00                                       |....|
00000004
> hexdump tmp/data/signals/sharedfile

0000000 001a 0000
0000004

001a -> 26, the value is correct.

*/

```

#### Use non-buffered I/O `write(2)/read(2)`

```c
/**
 * NOTE:
 *
 * Unlike fread(3)/fwrite(3) which is buffered I/O, read(2)/write(2) is
 * non-buffered in user space. No user space buffer, no flush. Thus there
 * is no "stale buffer data before fork()" problem.
 *
 * When fork() is called, file descriptors are duplicated in child process.
 * Both parent and child have separated file descriptors that refer to the
 * ***same file open file description*** in the kernel. This means they share
 * the same file offset.
 * There's no "stale" user-space buffer data to worry about being duplicated.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include "rltapue.h"

// Initialize file using a file descriptor
int init_file_fd(const char *const path) {
    if (!path) return -1;
    // Open for reading/writing, create if doesn't exist, truncate to zero
    int fd = open(path, O_RDWR | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) my_perror("error: open");

    int value = 0;
    if (write(fd, &value, sizeof(int)) != sizeof(int)) {
        my_perror("error: write()");
    }
    return fd;
}

// Increment the integer in the file using the file descriptor
int incre_file_fd(int fd) {
    lseek(fd, 0, SEEK_SET); // move to the start before read
    int value;
    if (read(fd, &value, sizeof(int)) != sizeof(int)) {
        my_perror("error: read()");
    }

    lseek(fd, 0, SEEK_SET); // move to the start before write
    value++;
    if (write(fd, &value, sizeof(int)) != sizeof(int)) {
        my_perror("error: write()");
    }

    // No need for fsync here for this example, write is usually sufficient
    // but fsync(fd) would be the equivalent of fflush.
    return value;
}

void test_fd(void) {
    const char *const file = "tmp/data/signals/sharedfile_fd";
    int fd = init_file_fd(file);
    const int rounds = 13;

    TELL_WAIT();
    pid_t pid = fork();

    if (pid < 0) {
        my_perror("error: fork()");
    } else if (pid == 0) { // child
        for (int i = 0; i < rounds; i++) {
            WAIT_PARENT();
            // critical section
            printf("Child: incrementing, value: %d\n", incre_file_fd(fd));
            TELL_PARENT(getppid());
        }
        exit(0);
    } else { // parent
        for (int i = 0; i < rounds; i++) {
            // critical section
            printf("Parent: incrementing, value: %d\n", incre_file_fd(fd));
            TELL_CHILD(pid);
            WAIT_CHILD();
        }
    }

    close(fd); // Close the file descriptor
}

int main(int argc, char **argv) {
    test_fd();
    return 0;
}
```


### 10.9 A neat version of `pr_mask()`

The function consists of a single loop that iterates once for every signal in
the current signal mask (not once for every possible signal).

```c
void pr_mask3(const char *str, sigset_t mask) {
  printf("%s: ", str);
  while (mask > 0) {
    sigset_t lsb = -mask & mask; // find least significant bit (the rightmost 1)
    int signo = __builtin_ctzl(lsb) + 1; // use GCC/Clang count trailing zeros
    printf("|%s|, ", strsignal(signo));
    sigdelset(&mask, signo);
  }
  printf("\n");
}
```

Test:

```c
void pr_mask_test()
{
  sigset_t mask;
  sigemptyset(&mask);
  int signals[] = {SIGVTALRM, SIGPROF, SIGXCPU, SIGTTIN, SIGTTOU, SIGWINCH};
  for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
    sigaddset(&mask, signals[i]);
  }
  pr_mask3("Current blocked signals: ", mask);
}

/*
Output:
Current blocked signals: : |Stopped (tty input): 21|, |Stopped (tty output): 22|, |Cputime limit exceeded: 24|, |Virtual timer expired: 26|, |Profiling timer expired: 27|, |Window size changes: 28|,
 */

```

### 10.11 `write(2)` and signal `SIGXFSZ`

Under Linux, macOS, and Solaris, as long as the current file size is below
the limit, `write(2)` will never cross the boundary. The kernel lets the
file grow right up to the limit and then stop. So it won't send the `SIGXFSZ`
signal and the handler won't be called.

Suppose the file size is 500, the limit is 512, another `write(2)` of 100
bytes will return a count of 12 as the file size reaches the limit.

When the file size reaches the limit and if we attempt an additional write
from the end of the file, we will receive `SIGXFSZ` and `write(2)` will return
-1 with `errno` set to `EFBIG`.

```c
#include <assert.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <unistd.h>

#include "rltapue.h"
#define BUFFSIZE 100
#define FSIZE_LIM 512

void sig_hand(int signo) {
  fprintf(stderr, "Signal[%d] is caught: %s\n", signo, strsignal(signo));
}

rlim_t my_setrlim(int name, rlim_t cur) {
  struct rlimit lim;
  if (getrlimit(name, &lim) < 0) {
    my_perror("error: getrlimit(RLIMIT_FSIZE, ...)");
  }
  rlim_t old = lim.rlim_cur;
  lim.rlim_cur = cur;
  if (setrlimit(name, &lim) < 0) {
    my_perror("error: setrlimit(RLIMIT_FSIZE, ...): %ld", cur);
  }
  return old;
}

void ulimit_test() {
  size_t nr, nw;
  char buf[BUFFSIZE];
  while ((nr = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
    if ((nw = write(STDOUT_FILENO, buf, nr)) != nr) {
      my_perror_ret("error: write: nw = %ld", nw);
    }
  if (nr < 0) my_perror("error: read: nr = %ld", nr);
}

void setrlimit_test() {
  rlim_t old_fsz = my_setrlim(RLIMIT_FSIZE, FSIZE_LIM);
  size_t nr, nw;
  char buf[BUFFSIZE];
  while ((nr = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
    if ((nw = write(STDOUT_FILENO, buf, nr)) != nr) {
      my_perror_ret("error: write: nw = %ld", nw);
    }
  if (nr < 0) my_perror("error: read: nr = %ld", nr);
  assert(FSIZE_LIM == my_setrlim(RLIMIT_FSIZE, old_fsz));
}

int main(int argc, char *argv[]) {
  // 1. Install signal handler
  struct sigaction act = {0}, oact = {0};
  act.sa_handler = sig_hand;
  if (sigaction(SIGXFSZ, &act, &oact) < 0) {
    my_perror("error: sigaction()");
  }

  // 2. Test event
  if (argc == 2) {
    fputs("Setup ulimit via `ulimimt -f 1`.\n", stderr);
    ulimit_test();
  } else {
    fputs("Setup rlimit via program.\n", stderr);
    setrlimit_test();
  }

  // 3. Restore signal action
  if (sigaction(SIGXFSZ, &oact, NULL) < 0) {
    my_perror("error: sigaction: restore");
  }
  return 0;
}

/*

## --------------------------------------------------------------
## Prepare fixed size file
> dd if=/dev/random of=./512B bs=1B count=512
512+0 records in
512+0 records out
512 bytes copied, 0.002261 s, 226 kB/s
> dd if=/dev/random of=./513B bs=1B count=513
513+0 records in
513+0 records out
513 bytes copied, 0.002686 s, 191 kB/s
> dd if=/dev/random of=1K bs=1K count=1
1+0 records in
1+0 records out
1024 bytes (1.0 kB, 1.0 KiB) copied, 0.000162 s, 6.3 MB/s
> ll
total 12
drwxr-xr-x   5 gpanda staff  160 Sep 18 11:40 ./
drwxr-xr-x 295 gpanda staff 9440 Sep 18 07:18 ../
-rw-r--r--   1 gpanda staff 1024 Sep 18 11:40 1K
-rw-r--r--   1 gpanda staff  512 Sep 18 11:40 512B
-rw-r--r--   1 gpanda staff  513 Sep 18 11:40 513B

> ulimit -a | grep "\-f"
-f: file size (blocks)              unlimited

## --------------------------------------------------------------
## Test 1: Setup rlimit via program.
> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz < ./512B > copy
Setup rlimit via program.
> ll
total 16
drwxr-xr-x   6 gpanda staff  192 Sep 18 18:45 ./
drwxr-xr-x 295 gpanda staff 9440 Sep 18 07:18 ../
-rw-r--r--   1 gpanda staff 1024 Sep 18 11:40 1K
-rw-r--r--   1 gpanda staff  512 Sep 18 11:40 512B
-rw-r--r--   1 gpanda staff  513 Sep 18 11:40 513B
-rw-r--r--   1 gpanda staff  512 Sep 18 18:45 copy

> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz < ./513B > copy
Setup rlimit via program.
error: write: nw = 12: Undefined error: 0

> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz < ./1K > copy
Setup rlimit via program.
error: write: nw = 12: Undefined error: 0
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large

## --------------------------------------------------------------
## Test 2: Setup ulimit via `ulimimt -f 1`.

> ulimit -f 1
> ulimit -a | grep "\-f"
-f: file size (blocks)              1
> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz 1 < ./512B > copy
Setup ulimit via `ulimimt -f 1`.
> ll
total 16
drwxr-xr-x   6 gpanda staff  192 Sep 18 18:45 ./
drwxr-xr-x 295 gpanda staff 9440 Sep 18 07:18 ../
-rw-r--r--   1 gpanda staff 1024 Sep 18 11:40 1K
-rw-r--r--   1 gpanda staff  512 Sep 18 11:40 512B
-rw-r--r--   1 gpanda staff  513 Sep 18 11:40 513B
-rw-r--r--   1 gpanda staff  512 Sep 18 18:53 copy
> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz 1 < ./513B > copy
Setup ulimit via `ulimimt -f 1`.
error: write: nw = 12: Undefined error: 0
> ~/wksp/apue.3e/mytests/Debug/signals/Ex10_11_sigxfsz 1 < ./1K > copy
Setup ulimit via `ulimimt -f 1`.
error: write: nw = 12: Undefined error: 0
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
Signal[25] is caught: Filesize limit exceeded: 25
error: write: nw = -1: File too large
> ll
total 16
drwxr-xr-x   6 gpanda staff  192 Sep 18 18:45 ./
drwxr-xr-x 295 gpanda staff 9440 Sep 18 07:18 ../
-rw-r--r--   1 gpanda staff 1024 Sep 18 11:40 1K
-rw-r--r--   1 gpanda staff  512 Sep 18 11:40 512B
-rw-r--r--   1 gpanda staff  513 Sep 18 11:40 513B
-rw-r--r--   1 gpanda staff  512 Sep 18 18:54 copy
 */
```

### 10.12 `alarm(3)` and `SIGALRM` on different platforms

```c
#include <signal.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "rltapue.h"

static char _1GB[1 << 30] = {
  [65] = 'A',
  [97] = 'a',
};

void sig_hand(int signo) {
  fprintf(stderr, "Signal[%d] was caught, [%s]\n", signo, strsignal(signo));
}

void sigalrm_test()
{
  struct sigaction act = {0};
  act.sa_handler = sig_hand;
  if (sigaction(SIGALRM, &act, NULL) < 0) {
    my_perror("error: sigaction");
  }
  alarm(1);
  size_t n = fwrite(_1GB, sizeof(char), 1 << 30, stdout);
  if (n < (1 << 30)) {
    my_perror_ret("fwrite: n = %ld", n);;
  }
}

int main(int argc, char *argv[]) {
  sigalrm_test();
  return 0;
}

/**

On macOS:

SIGALRM was caught during fwrite, after returned from the handler, fwrite continued to finish the writing.

> ./Debug/signals/Ex10_12_sigalrm > a
Signal[14] was caught, [Alarm clock: 14]

> ll -h a
-rw-r--r-- 1 gpanda staff 1.0G Sep 19 22:11 a

On Linux:

SIGALRM seems to be blocked or ignored during fwrite.

> ./Debug/signals/Ex10_12_sigalrm > a

> ll -h a
-rw-r--r-- 1 rltyty rltyty 1.0G Sep 21 07:52 a

 */

```

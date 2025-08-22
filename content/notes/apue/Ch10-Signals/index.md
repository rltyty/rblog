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
outside its domain.

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

- See signal numbers

```sh
# On macOS:
> kill -l | awk '{for(i=1;i<=NF;i++) print i ")", $i}' | column
1) HUP          4) ILL          7) EMT          10) BUS         13) PIPE        16) URG         19) CONT        22) TTOU        25) XFSZ        28) WINCH       31) USR2
2) INT          5) TRAP         8) FPE          11) SEGV        14) ALRM        17) STOP        20) CHLD        23) IO          26) VTALRM      29) INFO
3) QUIT         6) ABRT         9) KILL         12) SYS         15) TERM        18) TSTP        21) TTIN        24) XCPU        27) PROF        30) USR1

# On Linux (Debian 12):
➜  ~ kill -l | awk '{for(i=1;i<=NF;i++) print i ")", $i}' | column
1) HUP          4) ILL          7) BUS          10) USR1        13) PIPE        16) STKFLT      19) STOP        22) TTOU        25) XFSZ        28) WINCH       31) SYS
2) INT          5) TRAP         8) FPE          11) SEGV        14) ALRM        17) CHLD        20) TSTP        23) URG         26) VTALRM      29) POLL
3) QUIT         6) IOT          9) KILL         12) USR2        15) TERM        18) CONT        21) TTIN        24) XCPU        27) PROF        30) PWR
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

**`SIGKILL`** and **`SIGSTOP`** cannot be ignored or caught. It means the
disposition of either signal cannot be altered and is always to apply the
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

e.g. `printf` is a nonreentrant function.

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
that signal is currently blocked (See `sigprocmask(2)`, `sigset_t`).

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
- if `sigaction.sa_flags = SA_RESTART`, make the process automatically restart
  interrupted syscalls

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


### sigset_t

### `sigaction(2)`



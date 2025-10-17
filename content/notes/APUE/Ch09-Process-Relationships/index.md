---
title: "Ch09 Process Relationships"
subtitle: ""
date: 2025-08-16T10:00:34+08:00
lastmod: 2025-08-16T10:00:34+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Unix', 'Process']
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

## Terminal Logins

### BSD Terminal Logins

`init` process reads `/etc/ttys` line by line, for every terminal device that
allows a login, does a `fork` followed by an `exec` of the program `getty`

The `getty` program `open` the terminal device for reading and writing. Once
the device is opened, file descriptor 0, 1, and 2 are set to the device.
Then `getty` retrieve input user name, prepare environments and calls `login`
program, like

```c
execle("/bin/login", "login", "-p", username, (char *)0, envp);
```

See `gettytab` for more details on customizing `getty` actions, like invoking
programs other than the default `login`.

![State of processes after login has been invoked](<./images/State of processes after login has been invoked.png>)

`login` calls `getpass(3)` to read input password and calls `crypt(3)` to
encrypt the password and compares the result with `pw_passwd` field from the
shadow password file entry.

- If authentication fails, `login` calls `exit` with return value 1. The
  parent `init` will notice this and `fork` and `exec` `getty` to repeat the
  above procedure over again.

In modern system, PAM (Pluggable Authentication Modules) is used to support
multiple authentication procedures.

- If authentication succeeds, `login` will
  - `chdir` to user home directory
  - `chown` ownership of the terminal device
  - `chmod` permissions of the terminal device
  - `setpgid` and `initgroups` to set up group id
  - initialize environments:
    - HOME
    - SHELL
    - USER
    - PATH
  - `setuid` to change user id
  - finally invoke the login shell

Example:
```c
execl("/bin/sh", "-sh", (char *)0); // minus before sh indicates it's login shell
```

`login` could also do many things like
- prints message-of-the-day file
- checks for new email
- read start-up files like `.profile`, `.bash_profile`, `.cshrc`, `.zshrc`

![Arrangement of processes after everything is set for a terminal login](<./images/Arrangement of processes after everything is set for a terminal login.png>)

### Mac OS X Terminal Logins

Essentially the same procedure.

- `init` is performed by `launchd`
- graphical-based loginwindow

```/etc/ttys
console "/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow" vt100 on secure onoption="/usr/libexec/getty std.9600"
```

### Linux Terminal Logins

Also similar to BSD terminal logins

- `init` is performed by `systemd`
- character based terminal `agetty`

Example: On Debian 12
```sh
/sbin/init -> /lib/systemd/systemd

etc/systemd/system/getty.target.wants/getty@tty1.service
...
ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM
...
```

## Network Logins

Unlike a serial terminal login, which is a point-to-point connection between
the computer and the terminal device, network logins come through the kernel's
network interface drivers (e.g. Ethernet driver), and the number of
connections are undetermined.

To use the same way to process logins over both terminal and network, a
software driver called ***pseudo terminal*** is used to emulate the behaviour
of a serial terminal and map the terminal operations to network operations.

### BSD Network Logins

`inetd` (a.k.a Internet superserver) waits for network connections and spawn
appropriate service program.

![Sequence of processes involved in executing TELNET server](<./images/Sequence of processes involved in executing TELNET server.png>)



![Arrangement of processes after everything is set for a network
login](<./images/Arrangement of processes after everything is set for a network login.png>)


### Mac OS X Network Logins

Essentially the same


### Linux Network Logins

`xinetd` instead of `inetd`


## Process Group

A process group is a collection of one or more processes, usually associated
with the same job (job control is discussed in Section 9.8), that can receive
signals from the same terminal.

A process group lifetime begins when created and ends when the last remaining
process leaves the group.

- Get process group ID
```c
#include <unistd.h>
pid_t getpgrp(void);
                        // Returns: process group ID of calling process
```

- Join or create a process group

```c
#include <unistd.h>
int setpgid(pid_t pid, pid_t pgid);
                        // Returns: 0 if OK, −1 on error
```

The process group ID is the leader's process ID.

## Session


 ![Arrangement of processes into process groups and sessions](<./images/Arrangement of processes into process groups and sessions.png>)

```sh
proc1 | proc2 &
proc3 | proc4 | proc5
```

Create a session

```c
#include <unistd.h>
pid_t setsid(void);
                    // Returns: process group ID if OK, −1 on error
```

- Calling process becomes session leader
- Also the leader of new process group
- `getsid` return the leader's process group ID 

**NOTES**

- A process automatically joins a process group at creation via parent
  inheritance of PGID.
- A process group is created by a successful call of `setpgid(2)` with
  `pgid = pid`:
  - `setpgid(0, 0)` or `setpgid(getpid(), getpid())`: create a group for the
    calling process itself. The caller becomes the group leader.
  - `setpgid(child_pid, child_pid);`: create a group for a child process and
    name the child the group leader. (Allowed only before the child execs or
    runs independently.)
- A process group leader cannot leave (abandon) its group and join another
  group. `setpgid(pid, pgid)` fails with `EPERM` if the target process whose
  PID is `pid` is already a process group leader.
- A process, which is not a leader, can be moved to another existing process
  group in the same session by calling `setpgid(2)`. 
  - If `pgid != pid` and `pgid` does not correspond to an existing group in
    the same session, the kernel returns `EINVAL`.  
  - The `pgid` argument may be the PID of any process in the target group
    (not necessarily the leader), but the group must already exist.
- In a shell terminal, a session is created by a process calling `setsid()`
  which creates a new process group, the calling process becomes the group
  leader and the session leader (`SID=PID`, `PGID=PID`). The call detaches
  the process from the controlling terminal (if any).
  - Daemons typically call `setsid(2)` to detach from the terminal so they
    don’t get killed when you log out or press Ctrl-C.
- A session leader cannot leave (abandon) its session.
- The relationship between a process and a session is formed:
  - at process creation (`fork(2)`) via parent inheritance of SID and PGID
  - at session creation (`setsid(2)`) when the process becomes the session
    leader.
- The only way for a process to leave its current session is to create a new
  session and becomes its leader (via `setsid(2)`).
- A child process can have a different session ID from its parent's when:
  - The original parent creates a new session for itself (calls `setsid()`).
  - The child itself calls `setsid()` to create a new session.
  - When a parent exits, its orphaned children are reparented to `init`
    (PID 1), but their session ID does **not** change.

```c
int main(int argc, char *argv[]) {
  pid_t pid;

  pid_t sid = getsid(0); // get current session id
  printf("current session id: %d\n", sid);

  if ((pid = fork()) < 0) {
    my_perror("error: fork");
  } else if (pid == 0) { // child
    assert(getsid(0) == sid);
    printf("I'm child %d, my parent %d, my PGID %d, my SID %d\n",
           getpid(), getppid(), getpgid(0), getsid(0));

    printf("I'm child, I'm gonna create a grandchild for my parent.\n");
    if ((pid = fork()) < 0) {
      my_perror("error: fork grandchild");
    } else if (pid == 0) { // grandchild
      printf("I'm grandchild %d, my parent %d, my PGID %d, my SID %d\n",
             getpid(), getppid(), getpgid(0), getsid(0));
      sleep(3);
      printf("I'm grandchild %d, my parent %d, my PGID %d, my SID %d\n\n",
             getpid(), getppid(), getpgid(0), getsid(0));
      return 0;
    }
    sleep(1);
    printf("I'm child, I'm gonna create a new session for myself\n");
    sid = setsid();
    assert(getsid(0) == sid);
    printf("I'm child %d, my parent %d, my PGID %d, my SID %d\n",
           getpid(), getppid(), getpgid(0), getsid(0));
    sleep(5); // wait for parent exiting.
    printf("I'm child %d, my parent %d, my parent's SID %d, my PGID %d, my SID %d\n\n",
           getpid(), getppid(), getsid(getppid()), getpgid(0), getsid(0));
    return 0;
  } else { // parent
    assert(getsid(0) == sid);
    sleep(2);
    printf("I'm parent %d, my PGID %d, my SID %d\n",
           getpid(), getpgid(0), getsid(0));
  }

  return 0;
}

/*
> ./Debug/procgrp/sessid
current session id: 49433
I'm child 2716, my parent 2715, my PGID 2715, my SID 49433
I'm child, I'm gonna create a grandchild for my parent.
I'm grandchild 2717, my parent 2716, my PGID 2715, my SID 49433
I'm child, I'm gonna create a new session for myself
I'm child 2716, my parent 2715, my PGID 2716, my SID 2716
I'm parent 2715, my PGID 2715, my SID 49433
> I'm grandchild 2717, my parent 2716, my PGID 2715, my SID 49433

I'm child 2716, my parent 1, my parent's SID 1, my PGID 2716, my SID 2716
>

 */
```

## Controlling Terminal
 
 ![Process groups and sessions showing controlling terminal](<./images/Process groups and sessions showing controlling terminal.png>)

There are times when a program wants to talk to the controlling terminal,
regardless of whether the standard input or standard output is redirected. The
way a program guarantees that it is talking to the controlling terminal is to
open the file `/dev/tty`.

Example:

```c
/*
 * Difference between read from dev/tty and read from standard input.
 */
int main(int argc, char *argv[]) {
  int termfd = open("/dev/tty", O_RDONLY);
  char buf[BUFSIZ];
  int n;
  while ((n = read(termfd, buf, BUFSIZ)) > 0) { // read from terminal
    printf("Echo input from terminal:[%s]\n", buf);
  } // <CTRL-D> to end input, <CTRL-D> w/o input to end the loop 

  while ((n = read(STDIN_FILENO, buf, BUFSIZ)) > 0) { // read from STDIN
    printf("Echo input from STDIN:[%s]\n", buf);
  }
}

/*
> ./Debug/procrelation/ctrlterm
tty input 1. Echo input from terminal:[tty input 1. ]
tty input 2. Echo input from terminal:[tty input 2. ]
std input 1. Echo input from STDIN:[std input 1. ]
std input 2. Echo input from STDIN:[std input 2. ]

> ./Debug/procrelation/ctrlterm < log2
tty input 1. Echo input from terminal:[tty input 1. ]
tty input 2. Echo input from terminal:[tty input 2. ]
Echo input from STDIN:[Sat Aug 16 12:16:54 CST 2025
Main process say Hi!
#]
 */

/*
  NOTE:
  <CTRL-D> tells the terminal driver:
  1. if empty buffer: signal EOF (end of input)
  2. if non-empty buffer: deliver the current buffer contents immediately,
                      without adding a newline.
*/
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



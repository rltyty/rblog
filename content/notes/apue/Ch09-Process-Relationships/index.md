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
  - `setgid` and `initgroups` to set up group id
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




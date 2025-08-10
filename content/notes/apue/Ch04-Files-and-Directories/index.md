---
title: "Ch04 Files and Directories"
subtitle: ""
date: 2025-08-10T13:01:20+08:00
lastmod: 2025-08-10T13:01:20+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Filesystem', 'Unix']
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

## struct stat

- Linux: `/usr/include/x86_64-linux-gnu/bits/struct_stat.h:26`
- macOS: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/stat.h:158`

```c
#define __DARWIN_STRUCT_STAT64 { \
	dev_t		st_dev;                 /* [XSI] ID of device containing file */ \
	mode_t		st_mode;                /* [XSI] Mode of file (see below) */ \
	nlink_t		st_nlink;               /* [XSI] Number of hard links */ \
	__darwin_ino64_t st_ino;                /* [XSI] File serial number */ \
	uid_t		st_uid;                 /* [XSI] User ID of the file */ \
	gid_t		st_gid;                 /* [XSI] Group ID of the file */ \
	dev_t		st_rdev;                /* [XSI] Device ID */ \
	__DARWIN_STRUCT_STAT64_TIMES \
	off_t		st_size;                /* [XSI] file size, in bytes */ \
	blkcnt_t	st_blocks;              /* [XSI] blocks allocated for file */ \
	blksize_t	st_blksize;             /* [XSI] optimal blocksize for I/O */ \
	__uint32_t	st_flags;               /* user defined flags for file */ \
	__uint32_t	st_gen;                 /* file generation number */ \
	__int32_t	st_lspare;              /* RESERVED: DO NOT USE! */ \
	__int64_t	st_qspare[2];           /* RESERVED: DO NOT USE! */ \
}
```

### Holes in a File

- Create a real 1GB file filling with zeros

```sh
dd if=/dev/zero of=real1G bs=1G count=1

```
- Create a sparse1G file with a hole
```sh
dd if=/dev/zero of=sparse1G bs=1 count=0 seek=1G
```

- Logical size and disk usage
```sh
ls -lhs hole1G sparse1G real1G
1.0G -rw-r--r-- 1 gpanda staff 1.0G Aug  7 12:29 real1G
   0 -rw-r--r-- 1 gpanda staff 1.0G Aug  7 12:25 sparse1G
8.0K -rw-r--r-- 1 gpanda staff 1.1G Jun 27 07:39 hole1G
```

`ls -l`: shows logical size, `st_size`
`ls -s`: shows disk usage, `st_blocks`

`ls -s` use 1KB as block size to report the disk usage, this doesn't mean the
real block size (allocation unit) of the file system is 1KB.
To show file system block size: `stat -f /`

- Use `stat file` to show file logical size and blocks usage

## Exercises

### 4.1
When using `stat` instead of `lstat`, symbolic links will be followed. The
`struct stat` retrieved for a symbolic link like `/dev/stdin` is that of the
target file it points to, not the link itself. Therefore, the file type is
not `symbolic link` but `character special`.
`/dev/stdin -> /dev/fd/0` (macOS),
`/dev/stdin -> /proc/self/fd/0` (Linux)

### 4.2
When `umask` is set to `0777`, the new created file mode will all turned off,
resulting in `----------` (000) permissions.

```sh
> umask
022
> umask 0777
> touch x
> ll x
---------- 1 david staff 0 Jun 22 21:05 x
> umask 022
> touch y
> ll y
-rw-r--r-- 1 david staff 0 Jun 22 21:07 y
```
### 4.3

```sh
> ll a
--w-r--r-- 1 david staff 6 Jun 23 13:36 a
> echo "hello" >> ./a
> echo "world" >> ./a
> cat ./a
cat: ./a: Permission denied
> sudo cat ./a
hello
world
```
Even if a file is owned by a user, turning off its user-read permission
denies the user's reading access. However, if user-write permission is on,
it still allows the user to write to it.

### 4.4

```sh
> cat foo
foo
> cat bar
bar
> ll foo bar
-rw-r--r-- 1 gpanda staff 4 Jun 23 14:02 bar
-rw-r--r-- 1 gpanda staff 4 Jun 23 14:02 foo
> ./umask
> cat foo
> cat bar
> ll foo bar
-rw-r--r-- 1 gpanda staff 0 Jun 23 14:03 bar
-rw-r--r-- 1 gpanda staff 0 Jun 23 14:03 foo
>
```

If a file already exists, changing `umask` doesn't affect file creation mode.
However, the new creation will truncate the original file because the `umask`
script uses `creat(2)`, which is equivalent to
`open(path, O_CREAT | O_TRUNC | O_WRONLY, mode);`.

### 4.5
No, a directory type file's content has at least two directory entries: dot
and dot-dot. A symbolic link's file content is the path of the target file
the link points to. Therefore, the content size of either type of file cannot
be zero.

### 4.6

[Ex_4.6c](src/Ex4_6.c)


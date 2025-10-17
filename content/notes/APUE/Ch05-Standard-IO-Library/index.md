---
title: "Ch05 Standard IO Library"
subtitle: ""
date: 2025-08-16T10:02:55+08:00
lastmod: 2025-08-16T10:02:55+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Unix', 'I/O', 'libc', 'stdio']
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
The standard I/O library is specified by the ISO C standard because it's been
implemented on many operating systems. Additional interfaces are defined as
extensions to the ISO C standard by the SUS.


The standard I/O library written by Dennis Ritchie around 1975. It centers on
***streams*** and handles details like:

- buffer allocation
- performing I/O in optimal-sized chunks

## Streams and `FILE` Objects

When we open or create a file with the standard I/O library, we have
associated a stream with a file and get a file pointer `FILE *`.

A `FILE` object is a structure contains all the information required by the
standard I/O library to manage the stream:

- the file descriptor used for actual I/O (in the context of a UNIX system)
- a pointer to a buffer for the stream
- the size of the buffer
- the number of characters currently in the buffer
- error flag
- etc.

Applications use a file pointer as a handle of a stream to invoke the standard
I/O library functions.

Stream orientation: single-byte or wide character sets used (see `<wchar.h>`)

## `stdin`, `stdout` and `stderr`

Three streams are predefined and automatically available to a process. They
are referred through predefined `FILE*` pointers `stdin`, `stdout`, and
`stderr`. The corresponding underlying file descriptors are `STDIN_FILENO`,
`STDOUT_FILENO`, `STDERR_FILENO`.

## Buffering

The goal of the buffering is to use the minimum number of read and write calls.

### Three types of buffering

#### Fully buffered

Actual I/O takes place when the standard I/O buffer is filled. Files residing
on disk are normally fully buffered.

The term ***flush*** describes the writing of a standard I/O buffer. A buffer
can be flushed automatically when a buffer fills, or we can call `fflush` to
flush a stream.

#### Line buffered

Actual I/O takes place when a new line is encountered on input or output. This
is typically used on a stream that refers to terminal (TTY, character special
file).

The I/O may take place when:

- A buffer is filled before receives a newline
- Input is requested through:
  - an unbuffered stream
  - a line-buffered stream (requested by the kernel), all the line-buffered
    output stream are flushed

#### Unbuffered

Actual I/O take place as many times as the number of characters to input or 
output.

Most implementations default to the following types of buffering:

- `stderr`: always unbuffered
- all other streams are:
  - line-buffered, if refer to a terminal device 
  - fully-buffered, otherwise

Example:

- Running a command in a terminal, the `stdin` and `stdout` are line-buffered.
- Redirect the output of a command to a file, the `stdout` is fully-buffered.

```c
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
  printf("Main process says Hi!\n");
  system("date");   // spawn: fork, exec, waitpid
  return 0;
}
```

```sh
> ./Debug/stdio/buffer
Main process says Hi!
Sat Aug 16 12:15:16 CST 2025

> ./Debug/stdio/buffer > log
> cat log
Sat Aug 16 12:16:05 CST 2025
Main process says Hi!
```

### Custom buffering

```c
#include <stdio.h>
void setbuf(FILE *restrict fp, char *restrict buf );
int setvbuf(FILE *restrict fp, char *restrict buf, int mode, size_t size);
                                        // Returns: 0 if OK, nonzero on error
```

![Summary of the setbuf and setvbuf functions](<./images/Summary of the setbuf and setvbuf functions.png>)


## `fread(3)/fwrite(3)` and `fscanf(3)/fprintf(3)`

- `fread(3)` / `fwrite(3)`:

  - I/O type : Unformatted (binary) I/O
  - Unit     : Objects of given size (often bytes, but can be larger if size > 1)
  - Behavior : Direct copy between memory and file with no conversion or interpretation
  - Usage    : Structs, arrays, images, serialized data, any binary format

- `fscanf(3)` / `fprintf(3)`:

  - I/O type : Formatted (text) I/O
  - Unit     : Characters, parsed/printed according to format string
  - Behavior : Converts between internal representation and textual form
  - Usage    : Human-readable files, logs, configuration, CSV, text protocols

### Examples

```c
#include <assert.h>
#include <stdio.h>
void test_character_stream()
{
  const char * const file = "tmp/data/stdio/charstream";
  FILE *fp = fopen(file, "w+");
  fprintf(fp, "%d", 16384);

  rewind(fp);

  int a;
  fscanf(fp, "%d", &a);
  assert(a == 16384);

  fclose(fp);
}

void test_byte_stream()
{
  const char * const file = "tmp/data/stdio/bytestream";
  FILE *fp = fopen(file, "w+");
  int a = 16384;
  fwrite(&a, sizeof(int), 1, fp);

  rewind(fp);

  int b;
  fread(&b, sizeof(int), 1, fp);
  assert(b == 16384);

  fclose(fp);
}

int main(int argc, char *argv[]) {
  test_character_stream();
  test_byte_stream();
  return 0;
}

/*

> hexdump tmp/data/stdio/charstream
0000000 3631 3833 0034
0000005
> hexdump -c tmp/data/stdio/charstream
0000000   1   6   3   8   4
0000005
> cat tmp/data/stdio/charstream
16384%
> hexdump tmp/data/stdio/bytestream
0000000 4000 0000
0000004
> hexdump -c tmp/data/stdio/bytestream
0000000  \0   @  \0  \0
0000004
> cat tmp/data/stdio/bytestream
@%                                    # @: ascii (0x40)

 */
```


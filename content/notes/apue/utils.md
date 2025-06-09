---
date: '2025-06-09T18:38:46+08:00'
draft: true
title: 'Utils'
ShowToc: true
---
## awk

### read a file line by line

```awk
#!/usr/bin/awk -f

BEGIN {
    while (getline < "test.awk.input" > 0) {
        printf("[%s] | [%s]\n", $1, $2);
    }
    close("test.awk.input")
    exit
}
END {
    printf("Argentina Vamos!\n")
}
```

This can be used to generate files. (See below [Makefile](#makefile), Ch.2 standards)

## Makefile

### Use implicit rules and awk to generate files.

Note: ***A implicit rule is followed by NO recipes!!!***

```Makefile
conf:	conf.c

conf.c:	makeconf.awk sysconf.sym pathconf.sym
	$(AWK) -f makeconf.awk >conf.c

sysconf.sym:	sysconf-lim.sym
	grep -v "^#" sysconf-lim.sym >sysconf.sym

pathconf.sym:	pathconf-lim.sym
	grep -v "^#" pathconf-lim.sym >pathconf.sym
```

## grep

###  Inverse match `-v`

Ex. Ignore all comments

```sh
grep -v "^#" in > out
```

## Markdown

### jump to header

An implicit id will be generated for a header during markdown-to-html process
by replacing internal spaces with hyphens and making lowercase.

```markdown
## The Header

[Jump to the header](#the-header)
```

This is equivalent to 

```html
<a href="#the-header">Link Text</a>
```

## od - octal, decimal, hex, ASCII dump

-c, C-style escaped characters, -h, hexadecimal shorts, -a ASCII named chars.

```sh
od -c file.hole

0000000    a   b   c   d   e   f   g   h   i   j  \0  \0  \0  \0  \0  \0
0000020   \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
*
0040000    A   B   C   D   E   F   G   H   I   J
0040012

od -h ./file.hole
0000000      6261    6463    6665    6867    6a69    0000    0000    0000
0000020      0000    0000    0000    0000    0000    0000    0000    0000
*
0040000      4241    4443    4645    4847    4a49
0040012

od -a ./file.hole
0000000    a   b   c   d   e   f   g   h   i   j nul nul nul nul nul nul
0000020  nul nul nul nul nul nul nul nul nul nul nul nul nul nul nul nul
*
0040000    A   B   C   D   E   F   G   H   I   J
0040012
```

**NOTE**

1. offset in octal
2. In octal, 6261 -> 9897 -> ab, 4241 -> 6665 -> AB

## getconf(1)

Retrieve standard configuration variables

     getconf -a [file]
     getconf [-v environment] path_var file
     getconf [-v environment] system_var

E.g.

```sh
getconf NAME_MAX ./aaa
255
getconf PATH_MAX ./aaa
1024
getconf -v POSIX_V6_LP64_OFF64 UINT_MAX
4294967295
getconf -v POSIX_V6_LP64_OFF64 INT_MAX
2147483647
getconf -v POSIX_V6_LP64_OFF64 FILESIZEBITS ./aaa
56
```

## Zathura

    <Tab>   Display the contents

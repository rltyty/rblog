---
title: "Utils"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Utils', 'Unix']
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

```make
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

```sh
 getconf -a [file]
 getconf [-v environment] path_var file
 getconf [-v environment] system_var
```

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

```manual
<Tab>   Display the contents
```


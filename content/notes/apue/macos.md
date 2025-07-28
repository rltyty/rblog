---
title: "macOS"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['macOS']
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

## Toolchains

Print macOS developer directory active in use

```sh
xcode-select -p
```

Select toochains

```sh
sudo xcode-select --switch /Library/Developer/CommandLineTools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcode-select -r                    # (reset to default)
```

Toolchains installed from CommandLineTools (CLT) are used for
general c/c++ application development:

```sh
/Library/Developer/CommandLineTools/usr/{bin,include,lib}
/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/{bin,include,lib}
```

The toolchains installed from Xcode for macOS/iOS/tvOS application development: 

```sh
/Applications/Xcode.app/Contents/Developer
```

Show macOS SDK path

```sh
xcrun --sdk macosx --show-sdk-path
```

Use gcc/clang to check "include" search pathes on both macOS and Linux

```sh
gcc/clang -xc -E -v -
```

Use search manual pathes of SDK

```sh
find $(xcode-select -p) -type d | /usr/bin/grep '/usr/share/man$' | /usr/bin/tr -s '\n' ':'; echo
```

## New shared library .tbd files

.tbd files are text-based stub libraries (to reduce download size), which
points to the real binary .dylib files under

```sh
/usr/lib/system/libSystem_*.dylib
```

In newer macOS, shared libs are merged into a single binary

```sh
/System/Library/dyld/dyld_shared_cache_x86_64
```

A tool (brew install keith/formulae/dyld-shared-cache-extractor) can be used
to extract it to separated .dylib files.

```sh
dyld-shared-cache-extractor dyld_shared_cache_x86_64 ~/tmp/libs
```

 - Examples of separated libs:
   + Standard C lib
```sh
~/tmp/libs/usr/lib/system/libsystem_c.dylib
```

   + Standard C math lib
```sh
~/tmp/libs/usr/lib/system/libsystem_m.dylib
```

   + pthreads lib
```sh
~/tmp/libs/usr/lib/system/libsystem_pthread.dylib
```


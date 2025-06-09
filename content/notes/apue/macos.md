---
date: '2025-06-09T18:38:18+08:00'
draft: true
title: 'Macos'
showToc: true
---
## Toolchains

Print macOS developer directory active in use

    xcode-select -p

Select toochains

    sudo xcode-select --switch /Library/Developer/CommandLineTools
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    sudo xcode-select -r (reset to default)

Toolchains installed from CommandLineTools (CLT) are used for
general c/c++ application development:

    /Library/Developer/CommandLineTools/usr/{bin,include,lib}
    /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/{bin,include,lib}

The toolchains installed from Xcode for macOS/iOS/tvOS application development: 

    /Applications/Xcode.app/Contents/Developer

Show macOS SDK path

    xcrun --sdk macosx --show-sdk-path

Use gcc/clang to check "include" search pathes on both macOS and Linux

    gcc/clang -xc -E -v -

Use search manual pathes of SDK

    find $(xcode-select -p) -type d | /usr/bin/grep '/usr/share/man$' | /usr/bin/tr -s '\n' ':'; echo

## New shared library .tbd files

.tbd files are text-based stub libraries (to reduce download size), which
points to the real binary .dylib files under

    /usr/lib/system/libSystem_*.dylib

In newer macOS, shared libs are merged into a single binary

    /System/Library/dyld/dyld_shared_cache_x86_64

A tool (brew install keith/formulae/dyld-shared-cache-extractor) can be used
to extract it to separated .dylib files.

    dyld-shared-cache-extractor dyld_shared_cache_x86_64 ~/tmp/libs

 - Examples of separated libs:
   + Standard C lib

            ~/tmp/libs/usr/lib/system/libsystem_c.dylib
   + Standard C math lib

            ~/tmp/libs/usr/lib/system/libsystem_m.dylib
   + pthreads lib

            ~/tmp/libs/usr/lib/system/libsystem_pthread.dylib


---
title: "Make"
subtitle: ""
date: 2025-08-07T23:29:08+08:00
lastmod: 2025-08-07T23:29:08+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['make', 'build']
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

## Notes on `make` and Makefile


### Run make without echoing commands

```sh
make -s

```
To pass `-s` flag (contained in `MAKEFLAGS`) to all sub-make builds, use
`$(MAKE)` instead of `make`

### Incremental Compilation and Linking

- Monitor header files, if a header is updated, all the C sources including
  it will be recompiled.

```make
CFLAGS += -MMD -MP # generate .d files contains headers inclusion info.

DEPS := $(OBJS:.o=.d)
-include $(DEPS)
```

- Keep intermediate files `OBJS` from auto removal. If some C sources are
  updated, corresponding object files will be recompiled and corresponding
  executables will be relinked.

```make
.PRECIOUS: $(OBJS) # prevent from removal
```

- If executables has a library dependency, once the library has been updated,
  executables will be relinked.

### Build Shared Library: 

```make
# macOS (Darwin)
LIBTARGET = librltapue.dylib.$(VERSION)
LDFLAGS += -dynamiclib
LDFLAGS += -Wl,-install_name,@rpath/$(LIBTARGET)

# Linux
LIBTARGET = librltapue.so.$(VERSION)
LDFLAGS += -shared
LDFLAGS += -Wl,-rpath,'$$ORIGIN' -Wl,-soname,$(LIBTARGET)
```

#### Check shared library run path on Linux

```sh
readelf -d ../librlt/librltapue.so.3 | grep -E "RUNPATH|SONAME"
0x000000000000000e (SONAME)             Library soname: [librltapue.so.3]
0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN]
```

### Check shared library run path on macOS

```sh
otool -l ../librlt/librltapue.dylib.3 | grep -A2 LC_ID_DYLIB
         cmd LC_ID_DYLIB
     cmdsize 56
        name @rpath/librltapue.dylib.3 (offset 24)
```

### Build Executable Link Shared Library:

```make
LDFLAGS: -Wl,-rpath,$(LIBDIR_ABS)]
```

#### Check executable library run path on Linux:

```sh
readelf -d ./Debug/filedir/Ex4_1 | grep -E "RUNPATH|NEEDED"
0x0000000000000001 (NEEDED)             Shared library: [librltapue.so.3]
0x000000000000001d (RUNPATH)            Library runpath: [/home/kdfj/wksp/apue.3e/librlt]
```

#### Check executable library run path on macOS:

```sh
otool -l ./Debug/filedir/Ex4_1 | grep -E -A2 "LC_RPATH|LC_LOAD_DYLIB"
        cmd LC_LOAD_DYLIB
    cmdsize 56
       name @rpath/librltapue.dylib.3 (offset 24)
        cmd LC_RPATH
    cmdsize 48
       path /Users/gpanda/wksp/apue.3e/librlt (offset 12)
```

### Concurrent build

```sh
make -j[N]  # N is how many jobs in parallel
```

- when `N` is omitted `-j` is equivalent to `-j$(nproc)`

### Comaprison of `-j`, `-j4`, w/o `-j` on a `$(nproc) -eq 8` system

```sh
78.91s user 17.90s system 484% cpu 20.001 total (-j)
53.32s user 13.46s system 286% cpu 23.292 total (-j4)
50.03s user 12.33s system 94% cpu 1:05.72 total (no parallel)
```


### A Makefile sample

```make
# Makefile for mytests.
#
# make [BUILD=Debug|Release] [SHARED=Y|N]
# NOTE: `SHARED=Y` means build tests against dynamic shared librltapue

.SECONDEXPANSION:
ROOT = ..
PLATFORM = $(shell $(ROOT)/systype.sh)

include $(ROOT)/Make.defines.$(PLATFORM)

# source files to be excluded from the main build
# add "-E " option of `fd` command to each excluded file or directory
include ./mytests.inc
MAIN_SRC_EXCLUDED := $(addprefix -E , $(EXCLUDE_DIRS))
MAIN_SRC_EXCLUDED += $(addprefix -E , $(SINGLETONS))

# # find all c sources using `fd` under "src/"
# SRCS := $(shell fd -e c $(MAIN_SRC_EXCLUDED) . src)
# SRCS := $(patsubst src/%.c, %.c, $(SRCS))
#
# Now for easy debug configuration, let's flatten the sources by removal
# of the top level "src" folder.
SRCS := $(shell fd -e c $(MAIN_SRC_EXCLUDED))
SRCS := $(filter-out $(EXCLUDE), $(SRCS))

OBJS := $(patsubst %.c, $(BUILD)/%.o, $(SRCS))
BINS := $(OBJS:.o=)

# NOTE: `=` does recursive expansion, meaning
# if `a = $(b) b = $(c) c = d`, then `$(a)` reflects `d`.
# Thus, `=` cannot be used to self-assignment, like `CFLAGS = $(CFLAGS) -g3`,
# use `:=` instead, e.g. `CFLAGS := $(CFLAGS) -g3`

all: msg0 prep $(OBJS) $(BINS) $(SINGLETONS) msg1

prep:
	mkdir -p tmp && cp -r data/ tmp/

msg0:
	@printf "Build mytests in [32m[%s][m mode.\n" $(BUILD)
	@printf "Platform:[32m[%s][m\n" $(PLATFORM)
	@printf "Ignore directory: [%s]\n" $(EXCLUDE_DIRS)

msg1:
	@printf "Build finished [32m[%s][m.\n\n" $(BUILD)

include $(ROOT)/Make.librltapue.inc

LDFLAGS		= -L$(ROOT)/librlt
LDLIBS		= -l$(LIBRLTAPUE_NAME)
CFLAGS		+= $(CFLAGS.$(BUILD)) -MMD -MP
ifeq ($(SHARED), Y)
LDFLAGS		+= $(BIN_DYNLIB_RPATH)
endif

############################################################
$(BUILD)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD)/%: $(BUILD)/%.o $(LIBRLTAPUE_FILE)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) -o $@ $< $(LDLIBS)
############################################################
DEPS := $(OBJS:.o=.d)
-include $(DEPS)
.PRECIOUS: $(OBJS) # prevent from removal
############################################################
$(SINGLETONS):
	@printf "\nMaking %s in mytests...\n" $(SINGLETONS)
	@for dir in $(shell fd $(SINGLETONS)); do \
		echo "Making $$dir" && $(MAKE) BUILD=$(BUILD) -C $$dir; \
	done
############################################################
clean:
	$(RM) -r Release Debug release debug
	@for dir in $(shell fd $(SINGLETONS)); do \
		echo "Making clean $$dir" && $(MAKE) -C $$dir clean; \
	done
	$(RM) -r $(TEMPFILES)
############################################################
test:
############################################################
.PHONY: clean test all msg0 $(SINGLETONS) msg1 prep

```

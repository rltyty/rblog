---
title: "Notes on Memory Management"
subtitle: ""
date: 2026-11-18T13:56:24+08:00
lastmod: 2026-11-18T21:21:15+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Linux', 'Unix', 'MemoryManagement']
categories: ['IT', 'System']

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

## Virtual memory and physical memory

CPU's MMU + page-tables: translates virtual addresses to physical addresses.

![A System with Virtual Memory](<./images/vmm.jpeg>)

### 1. **Physical memory won't really allocate the requested amount of memory.**

```c
char *p = malloc(1024 * 1024 * 1024); // 1 GiB

p[0] = 'A';
p[4096] = 'B';
```

- The allocator obtains a sufficiently large virtual address range from the
  process's address space.
- Physical memory is generally allocated on demand when pages are first
  accessed. In the above example, only two physical pages (4KB / page) are
  allocated to back the accesses.

### 2. **Only virtual address range is reserved for an allocation.**

Suppose `malloc(3)` obtains a contiguous 1GB virtual address range. With 4KB
pages, there could be 1GB / 4K = 256K = 262,144 pages.

Linux can establish a virtual memory area (VMA) describing that range without
allocating those 262,144 individual leaf page-table entries.

VMA describes:

- Start and end virtual addresses.
- Memory permissions.
- Whether the region is anonymous or file-backed.
- How the region should be handled when accessed.

```c
char *p = malloc(1024 * 1024 * 1024);
char *q = p + 500000000;*
// No access to p's contents yet.
```

### 3. **Page demanding policy.**

Memory access must ultimately be resolved to an physical memory location.

The actual lower-level page-table entries (PTE) are generally populated as
memory is accessed. PTE stores the page mapping information. Its core content
is physical page number (PPN).

```c
p[0] = 'A';
```


## Memory Management Details

### 4. **Page fault handling.**

When CPU attempts to access a virtual address and MMU discovers that the
corresponding PTE is not present, then CPU raises a page fault exception. The
kernel's fault handler must resolve it.

The source of the page content depends on why the page was absent:

- Anonymous page, never touched (first access) — e.g., a heap/stack page, or a
  MAP_ANONYMOUS `mmap`.

  - Allocate a physical page frame.
  - Zero it (for security).
  - Install the PTE mapping.

  No disk I/O. This is the "demand-zero" case.

- Page is in swap — the page was previously evicted to swap space.

  - Allocate a physical page frame.
  - Read the page back from swap into that frame.
  - Update the PTE (clear the swap entry, set the present bit).

  This is "demand paging from swap."

- File-backed page (`mmap` of a file, or demand-paged executable/library) —
  the page contents exist in a file.

  - Allocate a physical page frame.
  - Read the page from the file (page cache may satisfy it if already cached).
  - Install the PTE mapping.

  This is "demand paging from a file."

- Copy-on-write (COW) — a special case: the page is present but shared read-only.

  - Allocate a new physical page frame.
  - Copy the contents of the shared page into it.
  - Remap the PTE to the new page, writable.

  No external source (swap/file) needed.

### 5. **A process's page-table resides in kernel-managed memory.**

Page-tables are kernel-managed data structures. A process cannot directly
access or modify its page-tables through ordinary user-space pointers.

### 6. **Page-table is NOT a flat table but a hierarchy tree.**

- Shared Kernel Portion

The kernel's virtual memory is mapped into every process's page table so that
when a syscall or interrupt occurs, the kernel code and data are immediately
accessible without a full page table switch. This means the top-level page
table entries pointing to kernel space are largely identical across all
processes on the system.

### 7. **More on Copy-on-Write (COW)**

When a process attempts to modify a shared page, only the process performing
the write needs to obtain a private copy. The other processes do not need to
copy anything.

Suppose p0 has one physical page, PF0, containing some data. p0 forks p1 and
p2. There are three separate page-tables. They all have a PTE that refers to
the same physical page PF0. The write protection is imposed on each PTE.

When p0 attempts to write to PF0, the following sequence occurs:

  - The MMU detects that p0's PTE is read-only.
  - A page fault occurs.
  - Linux determines that this is a legitimate **COW** write.
  - Linux allocates PF1 and copies the contents of PF0 into PF1.
  - Linux updates p0's PTE to point to PF1 and permits writing.
  - The original write instruction is retried.

p0 got a new physical page PF1. p1 and p2 still share PF0. Neither p1 nor p2
needs to copy anything. p1 and p2 retain their original data.

Then p1 or p2 attempts to write, it follows the same principle:

*Copying is performed on behalf of the process that attempts to write, not on
behalf of all processes sharing the page.*

After both p0 and p1 finish writing — PF1 and PF2 have been created, only p2
has reference to PF0. When p2 attempts to write, Linux recognizes there is no
sharing of PF0, then it makes PF0 writable for p2 rather than allocates
another physical page and copying it. This is called COW reuse.

Suppose p0 forks p1 and p2, p1 forks p3 at the beginning. p3 also has a
separate page-table containing a PTE pointing to PF0.

**References**

    kernel/fork.c       process creation and address-space duplication.
    mm/memory.c         page-fault handling and COW.
    mm/mmap.c           virtual memory area management.

### 8. **A page fault does not necessarily mean an invalid memory access.**

There are legitimate page faults:
- Demand-zero page fault.
- File-backed demand paging.
- Swap-in page fault.
- COW page fault.

There are also genuinely invalid accesses, such as accessing an unmapped
address or violating permissions, which may ultimately result in `SIGSEGV`.

## Summary


|Concept                | What it actually represents|
|-------                | ---- |
|Virtual address space  | The address range available to a process|
|VMA                    | Metadata describing a virtual memory region|
|Page table             | Hardware-assisted virtual-to-physical translation structures|
|PTE                    | Mapping and permission information for a virtual page|
|Physical page          | A page-sized unit of physical memory|
|Page fault             | CPU exception requiring OS intervention|
|Demand paging          | Allocating or loading pages when accessed|
|COW                    | Sharing physical pages until a write requires separation|


### A. Virtual memory allocation

`malloc()` / `brk()` / `mmap()`

Establish virtual address ranges and their properties. Physical pages need not
be allocated yet.

### B. Demand paging

First access → page fault → physical page allocation or loading → page-table update.

A virtual page becomes backed by an accessible physical page.

### C. Copy-on-Write (COW)

`fork()` → shared physical pages → write-protected mappings → write fault →
private copy if necessary.

Physical pages are shared until a process needs to modify its private data.


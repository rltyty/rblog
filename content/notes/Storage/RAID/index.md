---
title: "RAID"
subtitle: ""
date: 2025-08-01T00:14:45+08:00
lastmod: 2025-08-01T00:14:45+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Storage', 'RAID']
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
## RAID

- **RAID 0 (Striping):** Data is split and written across multiple disks
for **high performance**, but offers **no redundancy**. If one disk fails,
all data is lost.
- **RAID 1 (Mirroring):** Data is **duplicated** across disks for
**high redundancy**. Tolerates one disk failure, but usable storage is halved.
- **RAID 5 (Striping with Parity):** Data is striped, and **distributed parity**
allows for **single disk failure tolerance** with good storage efficiency
and balanced performance.
- **RAID 6 (Striping with Dual Parity):** Similar to RAID 5 but with
**two distributed parity blocks**, tolerating **two simultaneous disk failures**
at the cost of more write overhead.
- **RAID 10 (Striping & Mirroring):** Combines RAID 1 and RAID 0 for
**excellent performance and high redundancy**. Tolerates multiple failures
as long as they are not in the same mirrored set, but is more expensive.

### RAID 0

**Striping** is a data storage technique where data is broken down into blocks
and spread sequentially across multiple physical disks.

Analogy: Dealing Cards

Think of it like dealing a deck of cards to several players. The first card
goes to Player 1, the second to Player 2, the third to Player 3, and then
you circle back to Player 1. In this analogy:

- The **deck of cards** is your file.
- Each **card** is a block of data.
- Each **player** is a hard disk.

**Striping** offers high performance because it enables **parallel data access**.

### RAID 5

- At least 3 disks
- Single Parity
- Single disk failure tolerance.

RAID 5 doesn't replicate data in the sense of making an identical copy; it
uses a more efficient mathematical calculation to allow for data recovery from
a single disk failure.

$$\text{Disk usable capacity} = (N-1) \times \text{(size of smallest disk)}$$

- Parity calculation:

$$ A \oplus B = P$$
$$ A \oplus P = B$$
$$ P \oplus B = A$$

`XOR` $\\oplus$ table
|A |B |P|
|-------|-------|-|
|0 |0 |0|
|0 |1 |1|
|1 |0 |1|
|1 |1 |0|


As long as $N \ge 3$, any one disk fails, any block on that disk can be
calculated from all the other disks. For example, A, B, C, D blocks are
across 4 disks, $P=A \oplus B \oplus C \oplus D$, when the disk contains C
fails, C can be calculated by $C=P \oplus A \oplus B \oplus D$.

### RAID 6

- At least 4 disks.
- Dual Parity
- Two disks failure tolerance.

- `Sum1 = Data1 + Data2 + Data3` (like P parity).
- `Sum2 = (Data1 * X) + (Data2 * Y) + (Data3 * Z)` (like Q parity, using
  different coefficients or a different operation).
- if Data1 and Data2 are lost, two equations (`Sum1` and `Sum2`) with
  two unknowns (Data1 and Data2). With two independent equations, you
  can solve for both missing numbers.

### RAID 10

- At least 4 disks
- Mulitple disks failure tolerance
- Performance comes first cases

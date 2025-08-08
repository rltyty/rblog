---
title: "Huffman"
subtitle: ""
date: 2025-07-31T23:39:17+08:00
lastmod: 2025-07-31T23:39:17+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Algorithm']
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
## Huffman Coding

### construction of minimum weighted binary coding tree

To find a binary coding tree with minimum weighted path length from the root,
where the weight means the estimated frequency of occurrence.

![Huffman Coding](./images/Huffman_coding_visualisation.svg.png)

**Shannon's Source Coding Theorem** states that for any lossless compression:
$$H \le L \lt H+1$$

```octave
octave:2> huffman_entropy
plaintext = A DEAD DAD CEDED A BAD BABE A BEADED ABACA BED
h_encoding = 1000011101001000110010011101100111001001000111110010011111011111100010001111110100111001001011111011101000111111001
p_len = 46
h_len = 115
bits_per_symbol = 2.5000
Entropy: 2.4441 bits
Huffman Encoding: [2.500000] bits/symbol.
Entropy of the plain text: [2.444137] bits.
```

$2.44137 \le 2.5 \lt 3.44137$

See [huffman_entropy](./huffman_entropy.m), [entropy_calc](./entropy_calc.m)


---
title: "Ch7 Procenv"
subtitle: ""
date: 2025-08-06T07:31:43+08:00
lastmod: 2025-08-06T07:31:43+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['process', 'Unix']
categories: []

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

## Arguments

## Environment

## Memory Layout

### Stack Segment

Automatic storage duration, variables are declared in a function:

- Automatic allocation on **stack** when function is invoked and deallocation
  when it returns.
- Uninitialized variables contain garbage values.

### Data Segment

Global or static storage duration, variables declared globally or as static
in a function:

- if initialized, located at **initialized data segment**
- if not initialized, located at **Block Start by Symbol (BSS) data segment**
  and zero-initialized by compiler (e.g. int: 0, float: 0.0f, void*: NULL)
- allocation when the program starts and persists for the entire duration of
  the program's execution.

NOTE:

Explicit array initialization with zero-initialized for all storage duration
variables.
1. Full: `int numbers[5] = {10, 20, 30, 40, 50};`
2. Partial (rest zero-initialized): `int numbers[5] = {10, 20};`
3. Omitted size (compiler determines): `int numbers[] = {10, 20, 30};`
4. Designated initializers (C99+): `int numbers[5] = {[2] = 30, [0] = 10};`



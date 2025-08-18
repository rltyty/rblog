---
title: "Digital Signature"
subtitle: ""
date: 2025-08-16T07:44:20+08:00
lastmod: 2025-08-16T07:44:20+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Security', 'Cryptography']
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

## Signing
- Hash the original data (messages, digital media, etc.).
- Sign the hash with private key.

## Verifying Signature
- End user receives the data and compute the hash.
- Decrypt the signature with public key.
- Compare the decrypted hash with the computed hash.

**NOTE**

Here the cryptographic hashes are ***collision-resistant***, meaning it is
computationally infeasible (practically impossible with current computing
power) to deliberately find two different inputs that hash to the same output.

Collisions must exist in theory (because the input space is infinite but the
output space is finite).

But a good cryptographic hash makes it so hard to find one that it’s
practically impossible.


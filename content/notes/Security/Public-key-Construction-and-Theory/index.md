---
title: "Public Key Construction and Theory"
subtitle: ""
date: 2025-08-16T08:02:48+08:00
lastmod: 2025-08-16T08:02:48+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Security', 'Cryptography', 'RSA', 'PKI']
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

## 1. Constructing a Public/Private Key Pair (RSA)

1. **Pick two large primes**
   \(p, q\).
   Compute:
    $$n = p \cdot q$$

$n$ is the modulus, part of both public and private keys.

2. **Compute Euler’s totient**

    $$\varphi(n) = (p-1)(q-1)$$

3. **Choose a public exponent $e$**

- Typically $65537$ (a prime, chosen for efficiency).
- Must satisfy:
    $$\gcd(e, \varphi(n)) = 1$$

4. **Compute the private exponent $d$**

    $$d \cdot e \equiv 1 \pmod{\varphi(n)}$$

5. **Keys:**

- public key: $(e, n)$
- private key: $(d, n)$

## 2. The Theory

### Fermat’s Little Theorem

If $p$ is a prime and $gcd(a, p) = 1$, then:

$$a^{p-1} \equiv 1 \pmod p$$

### Euler’s Theorem (generalization)

If $gcd(a, n) = 1$, then:

$$a^{\varphi(n)} \equiv 1 \pmod{n}$$

This extends Fermat's theorem to any modulus $n$, using Euler's totient
function $\varphi(n)$.

### Connection to RSA

Suppose message $m$ with $gcd(m, n) = 1$

#### Encryption

$$c = m^e \pmod{n}$$

#### Decryption

$$m' = c^d \pmod{n}$$


Since $d \cdot e \equiv 1 \pmod{\varphi(n)}$, or

$$d \cdot e = 1 + k\varphi(n)$$

So:

$$m' = (m^e)^d \equiv m^{ed} \equiv m^{1 + k\varphi(n)} \pmod{n}$$

By Euler's Theorem:

$$m ^ {\varphi(n)} \equiv 1 \pmod n$$

Thus:

$$m' \equiv m \pmod n$$



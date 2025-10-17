---
title: "Bitwise Operation"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Java', 'Bitwise']
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

## Bitwise operations

### NOT operation (`~`)

Flip all bits: $0 \rightarrow 1$, $1 \rightarrow 0$. In a 32-bit system,

$$\sim x + x \equiv 2^{32} - 1 \pmod{2^{32}}$$
### Negate (`-`)

To negate a number $x$, computer does

$$-x = \sim x + 1$$

$$-x + x \equiv 2^{32} \equiv 0 \pmod{2^{32}}$$

In Java, the range of `Integer` is $[-2^{31}, 2^{31}-1]$. Negating the most
negative integer $-2^{31}$ overflows and wraps around to itself.

```java
- Integer.MIN_VALUE == Integer.MIN_VALUE
```
Mathematically, in 2's complement system,

$$ \sim x = -x - 1 = - (x + 1)$$
$$\text{(Flip all bits) } = \text{ (Negate and subtract 1) or (Add 1 and negate)}$$

$$ -x = \sim x + 1 = \sim (x - 1)$$
$$\text{(Negate) } = \text{ (Flip all bits and add 1) or (Subtract 1 and flip all bits)}$$

```java
   ~ 0  == -1
   ~ -1 == 0
   ~ 1  == -2
   ~ -5 == 4
   ~ 6  == -7
   ~ Integer.MIN_VALUE == Integer.MAX_VALUE
   ~ Integer.MAX_VALUE == Integer.MIN_VALUE 
```

### Alignment Rounding

One of the most common bit-manipulation idioms in low-level systems programming.

Like round $x$ up to the next multiple of `pagesize`.

$$
\begin{aligned}
\text{aligned} 
  &= (x + \text{pagesize} - 1) \ \&\ \sim(\text{pagesize} - 1) \\
  &= \left\lceil \frac{x}{\text{pagesize}} \right\rceil \times \text{pagesize}
\end{aligned}
$$

E.g.

```Java
    assertEquals(8192, 5000 + ((1 << 12) - 1) & ~ ((1 << 12) - 1));
```

### Two's complement

$$x = \mathrm{TC}(y) \iff x + y \equiv 0 \pmod{2^n}$$

$$x + \mathrm{TC}(x) \equiv 0 \pmod{2^n}$$

$$\mathrm{TC}(x) = \sim x + 1$$

In Java, the range of signed integer is $[-2^{31}, 2^{31}-1]$,

$$\mathrm{TC}(x) = -x \quad$$

Even if x is the most negative integer, it still holds because 

```java
- Integer.MIN_VALUE == Integer.MIN_VALUE
```

### $\texttt{Integer.toUnsignedLong(int)}$

Mathematically,

$$
\texttt{toUnsignedLong}(x) = x \bmod 2^{32}
$$

For example, $\texttt{toUnsignedLong}(-5) = -5 + 2^{32} = 4294967291$

In Java, it just reinterpret the signed integer as an unsigned one, the
result is returned as a long in the range $[0, 2^{32}-1]$

```java
Integer.toUnsignedLong(x) = 0xffffffffL & x
```

### Arithmetic shift (`>>`) and logical shift (`>>>`, `<<`)

There is only arithmetic right shift, no arithmetic left shift. Because the
sign bit is the leftmost bit, whether replicate it to fill the new leftmost
empty bit is only relevant to right shift.

### Arithmetic right shift (`>>`)
- Floored division, rounds toward -∞.
- Preserves the sign.
- Fills new leftmost with the sign bit.

```java
x >> n == Math.floorDiv(x, 1 << n) == Math.floor((double)x / (1 << n))

int Math.floorDiv(x, y) {
  int q = x / y;
  // if the signs are different and modulo not zero, round down
  if ( (x ^ y) < 0 && q * y != x ) {
    return q - 1;
  }
  return q;
}

Math.floorDiv(x, y) == Math.floor((double) x / y)

-7 >> 1 == -4               // round toward -∞
-7 >> 2 == -2               // round toward -∞
-8 >> 1 == -4
```

### Division (`/`)
- Truncated division (fraction part truncated), rounds toward 0.
- Preserves the sign

```java
-7 / 2 = -3                 // truncate the fraction part
-7 / 4 = -1                 // truncate the fraction part
```

### Logical right shift (`>>>`)

- Always treats number as unsigned
- Fills new leftmost with 0

Mathematically, `x >>> n` is equivalent to
```java
// NOTE:
// 1. 1L << n
// 2. cast the reuslt of long integer devision back to int
(x >= 0) ? x / (1 << n) : (int)(Integer.toUnsignedLong(x) / (1L << n))
```

### Logical left shift (`<<`)

- Fills new rightmost with 0

Mathematically, regardless of whether $x$ is positive or negative, the
operation is equivalent to:
$$x \ll n = \left( x \times 2^n \right) \bmod 2^{32}$$

```java
0 << 5 == 0
1 << 4 == 16
-1 << 4 == -16
Integer.MIN_VALUE << 1 == 0
Integer.MAX_VALUE << 1 == -2
(Integer.MIN_VALUE+1) << 1 == 2

```


---
title: "Growth of Functions"
subtitle: ""
date: 2026-04-26T16:54:24+08:00
lastmod: 2026-04-26T16:54:24+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Algorithm', 'Complexity', 'Growth', 'Asymptotic', 'Efficiency']
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

## Asymptotic Notations

Assume all functions are asymptotically nonnegative unless otherwise stated.

### $\Theta$-notation  $\underline{渐近紧界}$

$$
\begin{aligned}
\Theta(g(n)) = \{f(n): &\text{ there exist positive constants } c_1, c_2 \text{ and } n_0 \\
&\text{ such that } c_1 g(n) \le f(n) \le c_2 g(n) \text{ for all }
n \ge n_0\}
\end{aligned}
$$

We say that $f(n)$ is $\Theta(g(n))$, i.e., $g(n)$ is a tight asymptotic bound
for $f(n)$.

### $O$-notation  $\underline{渐近上界}$

$$
\begin{aligned}
O(g(n)) = \{f(n): &\text{ there exist positive constants } c \text{ and } n_0 \\
&\text{ such that } f(n) \le c g(n) \text{ for all } n \ge n_0\}
\end{aligned}
$$

We say that $f(n)$ is $O(g(n))$, i.e., $g(n)$ is an asymptotic upper bound
for $f(n)$.

### $\Omega$-notation $\underline{渐近下界}$

$$
\begin{aligned}
\Omega(g(n)) = \{f(n): &\text{ there exist positive constants } c \text{ and } n_0 \\
&\text{ such that } c g(n) \le f(n) \text{ for all } n \ge n_0\}
\end{aligned}
$$

We say that $f(n)$ is $\Omega(g(n))$, i.e., $g(n)$ is an asymptotic lower bound
for $f(n)$.

**NOTE:**
- $\Theta(g(n))$ is pronounced “big-theta of g of n”, $\Omega(g(n))$ is
  pronounced “big-omega of g of n”, $O(g(n))$ is pronounced “big-oh of g of n”

### Summary of $\Theta$, $O$ and $\Omega$

- $\Theta(g(n))$ — **always tight**, because $f(n)$ is sandwiched between
  $c_1 g(n)$ and $c_2 g(n)$
- $O(g(n))$      — **may not be tight**, only guarantees an upper bound
- $\Omega(g(n))$ — **may not be tight**, only guarantees a lower bound

Thus, $\Theta(g(n)) = O(g(n)) \cap \Omega(g(n))$, i.e.,

$$
f(n) \in \Theta(g(n)) \iff \bigl(f(n) \in O(g(n)) \text{ and } f(n) \in \Omega(g(n))\bigr)
$$

### Asymptotic notation in equations and inequalities

Using asymptotic notation can help eliminate inessential detail and clutter in
an equation.

$$
\begin{aligned}
2n^2 + 3n + 1 &= 2n^2 + \Theta(n) \\
              &= \Theta(n^2)
\end{aligned}
$$

Strictly speaking $\Theta(g(n))$ is a set not a value. Here it is used
informally to denote an arbitrary function in the class. Similarly for other
asymptotic notations.

### Non-tight asymptotic notations

#### $o$-notation $\underline{非紧渐近上界}$

$$
\begin{aligned}
o(g(n)) = \{f(n): &\text{ for any } c > 0, \text{ there exists a } n_0 > 0 \\
&\text{ such that } f(n) < c g(n) \text{ for all } n \ge n_0 \}
\end{aligned}
$$

$f(n)$ grows strictly slower than $g(n)$,
$\lim_{n \to \infty} \frac{f(n)}{g(n)} = 0$ (assuming $g(n) > 0$ eventually).

$o$-notation is stricter than $O$-notation; e.g., $n^2 = \Theta(n^2)$ and
$n^2 = O(n^2)$, but $n^2 \ne o(n^2)$.

#### $\omega$-notation $\underline{非紧渐近下界}$

$$
\begin{aligned}
\omega(g(n)) = \{f(n): &\text{ for all } c > 0, \text{ there exists a } n_0 > 0 \\
&\text{ such that } c g(n) < f(n) \text{ for all } n \ge n_0 \}
\end{aligned}
$$

$f(n)$ grows strictly faster than $g(n)$,
$\lim_{n \to \infty} \frac{f(n)}{g(n)} = \infty$ (assuming $g(n) > 0$ eventually).

$\omega$-notation is stricter than $\Omega$-notation; e.g., $n^2 = \Theta(n^2)$,
$n^2 = \Omega(n^2)$, but $n^2 \ne \omega(n^2)$.

Note that $o$ and $\omega$ are strict counterparts of $O$ and $\Omega$, respectively.

### Intuition and analogy

For a fixed comparison function $g(n)$ (omitted below for brevity), to help
memorize each notation reflects:

| Notation | Intuition | Analogy |
| :------: | :-------: | :-----: |
| $O$      | "at most" | $\le$   |
| $\Omega$  | "at least" | $\ge$   |
| $\Theta$      | "exactly (same order)" | $=$ (up to constants)   |
| $o$      | "strictly smaller" | $<$   |
| $\omega$      | "strictly larger" | $>$   |


**NOTE:** Not all functions are asymptotically comparable, see
[Trichotomy](#trichotomy).

### Comparison of functions using the notations

As above, we write $f(n) = \Theta(g(n))$ (i.e., $f(n)$ is $\Theta(g(n))$) to
mean $f(n) \in \Theta(g(n))$ for brevity. Similarly for other notations.

#### Transitivity

Applies to all notations: $\Theta$, $O$, $\Omega$, $o$, $\omega$

e.g. $f(n) = O(g(n))$ and $g(n) = O(h(n))$ imply $f(n) = O(h(n))$

#### Reflexivity

$\Theta$, $O$, $\Omega$

e.g. $f(n) = \Omega(f(n))$

#### Symmetry

$\Theta$

$f(n) = \Theta(g(n)) \iff g(n) = \Theta(f(n))$

#### Transpose symmetry

($O$, $\Omega$), ($o$, $\omega$)

$f(n) = O(g(n)) \iff g(n) = \Omega(f(n))$

$f(n) = o(g(n)) \iff g(n) = \omega(f(n))$

#### Trichotomy 

For any two real numbers $a$ and $b$, exactly one of the following must hold:
$a < b$, $a = b$ or $a > b$. Not all functions are asymptotically comparable.

e.g. $n$ and $n^{1 + \sin n}$ are not asymptotically comparable, because the
exponent $1+\sin n$ oscillates between 0 and 2 as n approaches infinity.

#### Properties

- $o \subset O$, $\Theta \subset O$, $o \cap \Theta = \varnothing$, $o \cup \Theta = O$
- $\omega \subset \Omega$, $\Theta \subset \Omega$, $\omega \cap \Theta = \varnothing$, $\omega \cup \Theta = \Omega$
- $\Theta = O \cap \Omega$


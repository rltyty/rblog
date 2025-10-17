---
title: "Subtyping"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Java']
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


## Subtyping (`<:`)

[Subtyping Test Code](https://github.com/rltyty/javatest/blob/main/src/test/java/korhal/lang/SubtypingTest.java)
- Subtyping (`subtype <: supertype`) is a **reflexive** and **transitive**
relation on two types, include:
  - identity
  - subclassing
  - interface extension
  - interface implementation

- Subtyping enables upcasting.
- To examine subtyping relation of all the above cases

  ```java
  SUPERTYPE.class.isAssignableFrom(SUBTYPE.class)
  ```

### Identity

Every type is a subtype of itself, by reflexivity of subtyping.

- To examine identity relation

  ```java
  A.class == B.class
  ```

  **NOTE:**
  Within a given class loader, a class (by name) has exactly one Class object
  at runtime.

  ```java
  ClassLoader loader1 = ...;
  ClassLoader loader2 = ...;

  Class<?> a = loader1.loadClass("mypkg.MyClass");
  Class<?> b = loader2.loadClass("mypkg.MyClass");

  assertFalse(a == b);        // FALSE
  ```

### Subclassing

```java
class A {}
class B extends A {}
class C extends B {}
```

`B` is a subtype of `A` by direct class inheritance.

`C` is a subtype of `A` by indirect class inheritance.

Subclassing is about two classes not interfaces.

- To examine **direct** class inheritance

  ```java
  A.class == B.class.getSuperclass()
    ```

- To examine **direct** and **indirect** class inheritance

  ```java
  private boolean isSubclass(Class<?> possibleSub, Class<?> possibleSuper) {
    if (possibleSub == null || possibleSuper == null
                            || possibleSub == possibleSuper)
      return false;
    Class<?> clazz = possibleSub;
    for (; clazz != null && clazz != possibleSuper;
           clazz = clazz.getSuperclass()) ;
    if (clazz != null) return true;
    return false;
  }

  isSubclass(C.class, A.class)
  ```

**NOTE:** `Object` is the root of the class hierarchy. It has no superclass
and is not a subclass of any class. But it is its own subtype, by reflexivity
of subtyping.

```java
Object.class.getSuperclass() == null
```

### Interface extension

  ```java
  interface Intf {}
  interface IntfSub extends Intf {}
  ```

`IntfSub` is a subtype of `Intf` by interface extension.

**NOTE:**
Every interface is a subtype of `Object`, but not a subclass of `Object`.
Interfaces have no superclass.

### Interface implementation

  ```java
  interface Intf {}
  class ClassA implements Intf {}
  ```

`ClassA` is a subtype of `Intf` by implementation.

### `isAssignableFrom()` and `isInstance()`

```java
if (Super.class.isAssignableFrom(obj.getClass())) {
 assert obj instanceof Super;  // compile time check: Super is known
}

Class<?> c;
if (c.isAssignableFrom(obj.getClass()) {
 assert c.isInstance(obj);     // runtime check: type of c is dynamic
}

private void assert_isInstance_isAssignableFrom(Class<?> c, Object o) {
  assertTrue(c.isAssignableFrom(o.getClass()));
  assertTrue(c.isInstance(o));
}

```

  

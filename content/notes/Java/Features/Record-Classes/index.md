---
title: "Record Classes"
subtitle: ""
date: 2026-11-19T14:39:27+08:00
lastmod: 2026-11-19T16:11:17+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Java', 'Record']
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

A **record** is a special kind of class introduced as a standard feature in
Java 16 (JEP 395). It is designed primarily to serve as an immutable data
carrier, reducing boilerplate code.

### Characteristics

- **Implicitly final:** A record class is implicitly `final` and cannot be
  extended by another class. However, it can implement interfaces.
- **Shallowly immutable:** Record component fields are implicitly `private
  final`, so their references (or primitive values) cannot be reassigned after
  construction. However, if a component references a mutable object, that
  object's internal state can still be modified.
- **Automatically generated methods:** The compiler generates:
  - A canonical constructor to initialize all record components.
  - Accessor methods for each component (e.g., `name()` rather than
    `getName()`).
  - `equals()`, `hashCode()`, and `toString()` implementations.
- **Custom behavior:** Records can define additional methods, constructors,
  static fields, and implement interfaces. However, they cannot declare
  additional non-static instance fields.

### Example

```java
public record Person(String name, int age) {

  public Person {
    if (age < 0) {
      throw new IllegalArgumentException("Invalid age");
    }
  }

  public String greeting() {
    return "Hello, " + name;
  }
}
```

### Usage

```java
Person person = new Person("Alice", 25);

person.name();      // "Alice"
person.age();       // 25
person.greeting();  // "Hello, Alice"

System.out.println(person); // Person[name=Alice, age=25]
```


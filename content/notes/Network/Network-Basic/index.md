---
title: "Network Basic"
subtitle: ""
date: 2025-08-05T12:21:07+08:00
lastmod: 2025-08-05T12:21:07+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Network', 'Port']
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

### Official Port Ranges (IANA)


| Port Range      | Description                       | Use case                                                     |
| --------------- | --------------------------------- | ------------------------------------------------------------ |
| **0–1023**      | Well-known ports (privileged)     | Standard public protocols (HTTP=80, HTTPS=443, SSH=22, etc.) |
| **1024–49151**  | Registered ports (user-assigned)  | Public apps, common services                                 |
| **49152–65535** | Dynamic/private (ephemeral) ports | Internal use, temporary connections, app backends            |


#### Public apps

- MySQL: 3306
- Redis: 6379

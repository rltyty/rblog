---
title: "Nginx"
subtitle: ""
date: 2025-08-05T12:59:52+08:00
lastmod: 2025-08-05T12:59:52+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Nginx', 'Web']
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

## Parent-master-child architecture


| Responsibility                             | Who Handles It               |
| ------------------------------------------ | ---------------------------- |
| `bind()` and `listen()` port                         | Nginx master                 |
| `fork()` workers                           | Nginx master                 |
| `epoll_wait` and `accept()` clients                     | Nginx workers                |
| Deciding which worker handles a connection | **Kernel**, not Nginx master |


```sh
# The same file descriptor (FD 24u) pointing to the same underlying socket.
nginx   504     root     24u  IPv4 ... TCP *:28327 (LISTEN)
nginx 50995 www-data     24u  IPv4 ... TCP *:28327 (LISTEN)
nginx 50996 www-data     24u  IPv4 ... TCP *:28327 (LISTEN)
```

1. The master process `bind(2)` a port name to a socket and set the socket as
   passive by `listen(2)`. The socket should get `FD_CLOEXEC` cleared for
   inheritable to the children.
2. The master process `fork(2)` child workers which inherit the socket
   (file descriptor).
3. All the workers `epoll_wait` for and `accept(2)` connections using the same
   shared socket

When a client `connect(2)` to the port, the **kernel** chooses which worker
gets to `accept(2)` the connection, via a queue or wakeup mechanism (e.g.
epoll/kqueue).



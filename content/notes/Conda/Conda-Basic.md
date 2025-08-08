---
title: "Conda Basic"
subtitle: ""
date: 2025-07-28T15:21:10+08:00
lastmod: 2025-07-28T15:21:10+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Conda', 'Python']
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

## Miniconda3 (suggested)
[getting-started](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html)

### Commands

- List environments
```sh
conda info -e
```

- Activate base environment
```sh
actconda
```
NOTE: `actconda` is an alias

```sh
actconda='eval "$(/home/rbach/rbox.local/var/miniconda3/bin/conda shell.zsh hook)"'
```

- Deactivate current environment
```sh
conda deactivate
```

- Activate an environment
```sh
conda activate aistudy
```

- Create an environment
```sh
conda create -n aistudy python=3.11
```

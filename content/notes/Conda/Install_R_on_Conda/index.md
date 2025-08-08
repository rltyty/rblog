---
title: "Install_R_on_Conda"
subtitle: ""
date: 2025-08-08T13:31:34+08:00
lastmod: 2025-08-08T13:31:34+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: []
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

<!--more-->
## Install R from conda
### Install: `conda install r-base`
#### [Optional]: `conda install pandoc`
### Run R: `R`
### Choose nearest mirror to download packages: `chooseCRANMirror()`
### To use rmarkdown in R: `install.packages("rmarkdown")`
### To export PDF document from R:
#### `install.packages("tinytex")`
#### `tinytex::install_tinytex()`
### Edit a [ ex1.rmd ](./ex1.rmd)
### Render it in R:
#### `library(rmarkdown)`
#### `rmarkdown::render('ex1.rmd')`
#### `rmarkdown::render("ex1.rmd", output_format = "pdf_document")`
##### Common output_format options include:
    "html_document"
    "pdf_document"
    "word_document"
    "all" (renders all formats specified in the YAML header)
#### Or in command line: `Rscript -e "rmarkdown::render('ex1.rmd')"`
### Example output: [ex1.pdf](./ex1.pdf)

---
title: "Install R via Conda"
subtitle: ""
date: 2025-08-08T16:03:42+08:00
lastmod: 2025-08-08T16:03:42+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['R', 'Statistics']
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
## Install R via Conda
### Install
```sh
conda install r-base
```
```sh
conda install r-base pandoc
```

### Run R
```sh
R
```
### Install R Markdown

#### Install via R
```R
> chooseCRANMirror()
> install.packages("rmarkdown")
```

#### Install via Conda from conda-forge (Suggested)
```sh
conda install -c conda-forge r-rmarkdown
```

### Export PDF from R:
#### Install `tinytex` or use system installed TeX like MacTeX
```R
> install.packages("tinytex")
> tinytex::install_tinytex()
```

#### Edit R Markdown document, e.g [ ex1.rmd ](./ex1.rmd)
#### Render R Markdown document
##### Render it in R:
```R
> library(rmarkdown)
> rmarkdown::render('ex1.rmd')
> # or
> rmarkdown::render("ex1.rmd", output_format = "pdf_document")`
```
###### Common output_format options
- "html_document"
- "pdf_document"
- "word_document"
- "all" (renders all formats specified in the YAML header)

##### Render outside R:
```sh
Rscript -e "rmarkdown::render('ex1.rmd')"
```

#### Sample output
- [ex1.pdf](./ex1.pdf)

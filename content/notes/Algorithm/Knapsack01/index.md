---
title: "Knapsack01"
subtitle: ""
date: 2025-08-09T14:08:19+08:00
lastmod: 2025-08-09T14:08:19+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Algorithm', 'DP']
categories: ['IT']

resources:
- name: featured-image
  src: images/Knapsack_Problem_Illustration.png
# - name: featured-image-preview
#   src: featured-image-preview.jpg

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

<!-- ![Knapsack Problem](./images/Knapsack_Problem_Illustration.svg) -->
<!---->
## Fastest way

```java
public int knapsack01(int n, int W, int[] weights, int[] values) {
  int[] dp = new int[W+1];
  for (int i = 0; i < n; i++) {
    for (int j = W; j >= weights[i]; j--) {
      dp[j] = Math.max(dp[j], dp[j - weights[i]] + values[i]);
    }
  }
  return dp[W];
}
```

![Dynamic Programming Illuastration](./images/Knapsack_problem_dynamic_programming.gif)

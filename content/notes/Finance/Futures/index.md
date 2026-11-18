---
title: "Futures"
subtitle: ""
date: 2026-08-16T01:16:27+08:00
lastmod: 2026-08-16T11:32:26+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Futures']
categories: ['Finance']

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

期货市场把“价格风险”从不愿承担的人转移给愿意承担的人，同时通过多空双方不断交易形成价格发现。


## 套期保值 —— 转移价格风险

- 实物持有者（望涨），未来要卖实物（怕跌） → 卖出期货 → 空头套期保值
- 现金持有者（望跌），未来要买实物（怕涨） → 买入期货 → 多头套期保值
- 通过期货盈亏抵消现货价格变化造成的损益
- 目的不是赚取期货投机利润，而是降低价格风险、锁定未来价格附近的收益/成本
- 不一定最终进行实物交割，通常可以在到期前平仓

## 投机 —— 承担价格风险并参与价格发现

- 看涨 → 买入期货 → 上涨后卖出平仓 → 获利
- 看跌 → 卖出期货 → 下跌后买入平仓 → 获利
- 做空期货通常不需要借入实物
- 多空双方的交易形成期货市场价格
- 大量投机者根据各自掌握的信息和判断进行交易，帮助形成价格发现
- 期货价格又会反过来影响现货市场的价格预期和定价

## 套利 —— 利用价格关系的不合理，赚取价差回归

- 利用同一种或相关标的在不同市场、不同合约、不同时间上的价格差异，同时买入便宜的、卖出贵的，赚取价格差
- 核心不是判断“涨还是跌”，而是判断两个价格之间的相对关系不合理
- 套利者通常同时建立方向相反的头寸，因此整体对价格涨跌方向不敏感，主要赚取价差回归带来的收益
- 大量套利者的交易会使不合理的价格差缩小，帮助不同市场、不同合约之间的价格保持合理关系，提高市场定价效率
- 期货相对于现货的价差能否回归正常水平

**NOTE:** 
- 投机者：我认为黄金会涨 → 买黄金期货
- 套利者：我不管黄金涨跌，我认为期货相对于现货太贵 → 买现货 + 卖期货

## 全球期货市场四大类交易产品

### 利率类期货（Interest Rate Futures）

SOFR (Secured Overnight Financing Rate) 有担保隔夜融资利率, 美联储用来代替
伦敦同业拆借利率（LIBOR）的美元基准参考利率

### 股票类期货（Equity Futures）

股指期货

### 大宗商品期货（Commodity Futures）

原油期货，天然气，金/银/铜，大豆，小麦，玉米，棉花，螺纹钢，糖，咖啡，PVC

### 其他

外汇期货（Forex Futures), 股市波动率期货（VIX Futures，又叫恐慌指数期货）

1993年黑色星期三，索罗斯做空英镑/马克汇率，英镑马克脱钩

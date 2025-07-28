---
date: '2025-06-11T07:47:02+08:00'
draft: true
title: 'Conda Memo'
tags: ['conda', 'python']
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

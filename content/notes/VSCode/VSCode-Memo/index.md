---
title: "VSCode Memo"
subtitle: ""
date: 2026-05-28T16:34:26+08:00
lastmod: 2026-05-28T16:34:26+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['VSCode']
categories: ['IT', 'Editing']

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

## Shortcut keys

- Open commands: `<Command>+<Shift>+p`

## Settings

### Three tier settings

```mermaid
flowchart TB
A["Defalut Settings (builtin, read-only, defaultSettings.json)"]
B["Profile Settings (your active profile's settings.json)"]
C["Workspace Settings (project specific, .vscode/settings.json)"]

A --> |overriden by| B --> |overriden by| C
```

#### Default settings

- Read-only
- View via `Preferences: Open Default Settings (JSON)`
- Merged from
  - VS Code core defaults
  - Every installed extension's declared defaults (`package.json`)

Each extension ships with a package.json that declares its contributed
settings and their default values. When the extension is activated, VS Code
merges those into the live default settings layer.

For example, in the `defaultSettings.json`, you can see below settings injected
by Pylance extension.

```json
"python.analysis.typeCheckingMode": "off"  // Pylance's default
```

#### Profile settings

- Synced to GitHub account
- Open via `Preferences: Open User Settings (JSON)`

For example, to turn on type checking of Pylance, override the settings in
user profile `settings.json`.

```json
{
    "python.analysis.typeCheckingMode": "standard",
}
```

#### Workspace settings and workspace-only settings

- Open via `Preferences: Open Workspace Settings (JSON)`
- `.vscode/settings.json`
- Project specific settings:
  - `.vscode/extensions.json`: recommends extensions relevant to this
  project's language and tooling.
  - `.vscode/launch.json`: defines how to run and debug this specific
  application — its entry points, arguments, environment variables.
  - `.vscode/tasks.json`: defines build/run/test tasks for this project — its
  Makefile targets, test commands, etc.


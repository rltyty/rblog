---
title: "NeoVim Memo"
subtitle: ""
date: 2025-10-16T08:10:09+08:00
lastmod: 2025-10-16T08:10:09+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Vim', 'Neovim', 'Nvim', 'Memo']
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

markmap:
  initialExpandLevel:
    - 2     # only leaf node collapsed
---

<!--more-->
# VIM CHEAT SHEET

### 1. Reload vimrc
```
:so %           -- reload current file (so = source, % = current file)
```

### 2. Change file name
```
:Sex            -- split to open an Explorer window
R               -- Rename
change name and <CR>
```

### 3. Movement

#### 3.1 [Jumping to the start and end of a code block](<http://vim.wikia.com/wiki/Jumping_to_the_start_and_end_of_a_code_block>)

- `[[` : sections backward or to the previous '{' in the first column.
- `]]` : sections forward or to the next '{' in the first column.
- `[]` : sections backward or to the previous '}' in the first column.
- `][` : sections forward or to the next '}' in the first column.
- mnemonic: Same for `{`, diff for `}`, `[` backward, `]` forward.

#### 3.2 Jump by sentence

```
    )               forward, next sentence
    (               backward, previous sentence
```

#### 3.3 Jump by paragraph

```
    }               forward, next paragraph
    {               backward, previous paragraph
```

#### 3.4 Jump to marker

```
    mA              mark the current position to register A
    `A              jump to mark A in the current buffer
```

### 4. [Placeholder]

### 5. Windows
#### 5.1 Operate split windows
```
    <C-W> <C-V>     split the window vertically
    <C-W> <C-S>     split the window horizontally
    <C-W> _         maximize a window split horizontally
    <C-W> |         maximize a window split vertically
    <C-W> =         adjust split windows to equal size
    [N]<C-W> +/-    adjust current window height by [N] rows more/less
    [N]<C-W> </>    adjust current window width by [N] cols more/less
    <C-W> r         rotate split windows, can swap two split windows
```

#### 5.2 Close windows

```
    <C-W> c         close the current window
    <C-W> o         same to `:on[ly]`, close other windows except the current
    ZZ              same to `:x`, write if modified, then close the current
```

#### 5.3 Move a window to another tab
```
    :tab sp/vs      Duplicate current buffer in another tab
    <C-W> T         Move the current window to another tab
```

#### 5.4 Open N files in N windows

```
    vim -O <f1> <f2> ... <fN>  vertical splits (side by side) by vertical `|`
    vim -o <f1> <f2> ... <fN>  horizontal splits (stacked) by horizontal `-`
```

#### 5.5 Open N files in N tabs

```
    vim -p  <f1> <f2> ... <fN>
```

### 6. Editing remote files with `netrw`
- vim scp://rpi-lan//home/pi/tmp/a
Note: proto://<connect_string>/<abs_path>, double slashes needed
```
%               -- Create a new file
d               -- Create a directory
```

### 7. Insert output of external command
```
:read !date<cr>     -- Insert a date in the next line
:read !date<cr>kJ   -- Insert a date in the current line
:read !date +'\%a \%Y-\%m-\%d \%T \%Z'     (Note: '%' need to be escaped)
                    -- Insert a long format date in 24hr mode with weekday and
                       timezone
```

### 8. Vimscript
#### 8.1 line continuation
     Add a backslash in the next line make sure the backslash is the first
     non-white character.
     ```
     let a = "Hello,
        \world!
         \ This i
      \s a test of
     \ line continuation."
     echo a
     - Output:
     Hello, world! This is a test of line continuation.
     ```

### 9. Lua:
#### 9.1 `vim.o`, `vim.go`, `vim.bo`/`vim.wo`, `vim.g` and `vim.b`, etc.
```
set options: (set, setg, setl)
vim.o ~ vim.opt, vim.go ~ setg(lobal), vim.bo/vim.wo ~ setl(ocal)
set variables: (8 scopes, let b:/w:/t:/g:/l:/s:/a:/v:) and vim.env (see
expand-env and :let-environment)
e.g. vim.g.<var> = <val> ~ let g:<var> = <val>
     vim.env.FOO = 'bar'
     print(vim.env.TERM)
NOTE: vim.opt seems to be safer than vim.o, because it seems that some options
cannot be set by vim.o
```


### 10. Add my personal Nvim notes to Vim help doc system.
- Add a directory entry to `vim.runtimepath`, then the `doc` directory
  under it will be in the search list when typing :h <my topic>
- generate tags for `doc` by `:helptags doc`
- By default, `:help <topic>` opens the topic file in read-only mode,
  because `modifiable` option is set off by help. Turn it on by
  `set nomodifiable`.

### 11. Show current buffer file's full path: `<c-g>`

### 12. Neovim terminal mode
```
    <C-\> <C-N>     change to normal mode
    a/i/A/I ...     change to append/insert... mode
```

### 13. Enter Ex mode by `gQ`, exit the mode by `:vi`

### 14. In Ex mode, use `lua print(<api call>)` to quickly check command output.
#### 14.1 Example `lua print(vim.fn.expand('%'))`

### 15. Since 0.9, `:=<var>` will show variable value.

### 16. Char count `:s/,//gn`            count how many commas in a line

### 17. Remove all the trailing whitespaces for each line in file.
- `:%s/\s\+$//e`

### 18. Show man page about the word under the current cursor:
```
    `gK`    map('n', 'gK', '<Cmd>Man<CR>', {desc = 'Show man page for <cword>'})
    `K`     remap vim.lsp.buf.hover() by lsp
```

### 19. LSP
```
- Go to definition: `tagfunc` (`C-]` and other tag commands)
- Completion: `omnifunc`
- Format: `formatexpr`
  + vim.lsp.buf.format() - buf level format(`<leader>lf`)
  + `gq` - selection (expression) level format
  + `gw` - selection (expression) wrap according `textwidth`
- Hover:
  + vim.lsp.buf.hover()(`<leader>gh`, press twice to focus on the float win.)
- Show diagnostic message in a float window: `gl`
  + Map `gl` to `:lua vim.diagnostic.open_float()<CR>`
  + press `gl` twice, to focus on the float window, then select and yank
    message text.
- nvim-lspconfig:
  + default server configurations:
    + lspconfig/server_configurations/*.lua
    + can be called automatically by `mason-lspconfig` plugin
- Java (jdtls):
  + nvim-lspconfig:
    + nvim-lspconfig/lua/lspconfig/configs/jdtls.lua
    + nvim-lspconfig/doc/configs.md
    + nvim-lspconfig/doc/configs.txt
  + nvim-jdtls:
    + nvim-jdtls/README.md
    + nvim-jdtls/lua/jdtls.lua
    + nvim-jdtls/lua/jdtls/setup.lua
    + nvim-jdtls/plugin/nvim_jdtls.vim
  + LazyVim
    + LazyVim/lua/lazyvim/plugins/extras/lang/java.lua
```

### 20. <Cmd> :map-cmd
- This pseudokey begins a "command mapping", which executes the command without
changing modes. "<Cmd>...<CR>" can be used instead of ":...<CR>" in the {rhs}
of a mapping.

### 21. `<C-R><C-W>` insert the word under the cursor. See `h:<C-R>`

### 22. Debug Neovim instance in Neovim. See `:h osv` and
- https://github.com/nanotee/nvim-lua-guide?tab=readme-ov-file#tips-2

### 23. To see last command output like `:!mvn test`

    `g<`

### 24. Quickly switch between current and last buffer

    `<C-6>`

### 25. Draw a table, especially add a column on the right side of a file

    ┌──────────────────────────────────────────────────────┐
    │               C Operator precedence table            │
    │               operator                associativity  │
    │   ()  []  ->  .                           L          │
    │   !   ~   ++  --  - (type) * & sizeof     R          │
    │   *   /   %                               L          │
    │   +   -                                   L          │
    │   <<  >>                                  L          │
    │   <   <=   >  >=                          L          │
    │   ==  !=                                  L          │
    │   &                                       L          │
    │   ^                                       L          │
    │   |                                       L          │
    │   &&                                      L          │
    │   ||                                      L          │
    │   ?:                                      R          │
    │   assignments                             R          │
    │   ,                                       L          │
    └──────────────────────────────────────────────────────┘
    Note: To draw a table, espectially a column on the right side (meaning
    the cursor needs to be positioned where there is no actual character.)
    Two options need to be set, `:set ve=block`, `:set nosol` (virtualedit,
    nostartofline)
    Another method is to make use of `column -t` to pretty print,
    visual select some lines and add <some character> at the end of each
    line by `:norm A <some character>` and then makes it align like a table
    by `:! column -t`. If the whole file is to be edited, add "%" after ":"
    for each command.

See [How to insert a column on the right side of a file][1]

### 26. Visual block edit

#### insert a column ((<j>+1) rows) of text

```
    <C-v><j>jI<text>
```
  **Note**: If the block spans short lines that do not extend into the block,
  the text is not inserted in that line.

#### append a column of text after block selection, use `A` instead of `I`

  **Note**:
  `<C-v><j>j$A<text>` append text to the end of each line in the block

#### user a character <c> to fill a rectangle of (<j>+1) x (<l>+1) size.
```
    <C-v><j>j<l>lr<c>
```
  **Note**:
`r`: replace with

#### change a column of A to B, use `c` command.

Change `LIST` to `ARRAY`

```
    <C-V>8jt_cARRAY<Esc>
```

```
    LIST_BOOLEAN                ARRAY_BOOLEAN
    LIST_BYTE                   ARRAY_BYTE
    LIST_CHARACTER              ARRAY_CHARACTER
    LIST_SHORT                  ARRAY_SHORT
    LIST_INTEGER      -->       ARRAY_INTEGER
    LIST_LONG                   ARRAY_LONG
    LIST_FLOAT                  ARRAY_FLOAT
    LIST_DOUBLE                 ARRAY_DOUBLE
    LIST_STRING                 ARRAY_STRING
```

Change `_XXXX` to `FOO`

```
    A<Space><Space><Esc><C-V>8jT_cFOO<Esc>
```

```
    LIST_BOOLEAN                LIST_FOO
    LIST_BYTE                   LIST_FOO
    LIST_CHARACTER              LIST_FOO
    LIST_SHORT                  LIST_FOO
    LIST_INTEGER      -->       LIST_FOO
    LIST_LONG                   LIST_FOO
    LIST_FLOAT                  LIST_FOO
    LIST_DOUBLE                 LIST_FOO
    LIST_STRING                 LIST_FOO
```

#### Bonus: Change `FOO` in the 2nd column to `1`~`9`

```
    v8j:'<,'>s/_\w\+\ze\s*$/\="_".(line(".")-line("'<")+1)/
```

```
    LIST_BOOLEAN                LIST_1
    LIST_BYTE                   LIST_2
    LIST_CHARACTER              LIST_3
    LIST_SHORT                  LIST_4
    LIST_INTEGER                LIST_5
    LIST_LONG                   LIST_6
    LIST_FLOAT                  LIST_7
    LIST_DOUBLE                 LIST_8
    LIST_STRING                 LIST_9
```

**NOTE**:
- `\=`: switches to expression evaluation
- `line(".")`: current line number being substituted 
- `line("'<")`: line number of the start of the visual selection
- `\ze\s*$`: the `\ze` sets the end of match, ensuring it only replace the
   suffix at the end of the line (i.e. the second column)

### 27. `tpope/vim-surround`
#### Builtin surrounding characters `<`, `t`, `a` (see `:h surround`)
```c
#include "unistd.h"
// cs"<       % < will trigger a prompt for a tag name to insert
#include <hello>unistd.h</hello>

// cs"t       % t also represents a tag, same to <
#include <hello>unistd.h</hello>

// cs"a       % a represents angle
#include <unistd.h>
```

### 28. Type a strikethrough letter `a̶b̶c̶ X̶Y̶Z̶`
- By appending the Unicode "long strike overlay combining character" ('\u0336')
- `<letter><CTRL-v>u0336`

### 29. Registers

#### 10 Types:
- 1. The unnamed register ""
- 2. 10 numbered registers "0 to "9
- 3. The small delete register "-
- 4. 26 named registers "a to "z or "A to "Z
- 5. Three read-only registers ":, "., "%
- 6. Alternate buffer register "#
- 7. The expression register "=
- 8. The selection registers "* and "+
- 9. The black hole register "_
- 10. Last search pattern register "/

#### Ex1. Copy a selection to "1, paste "1 to the target position
```
"1yiw           -- Copy the word at the current cursor to "1
                -- Move to the target position
                -- Method 1: change to insert mode and
<C-R>1          -- Paste "1, <C-R> {register}: Insert the contents of a
                --                             numbered or named register.
"1p(P)          -- Method 2: Just paste (p: after cursor, P: before cursor)
```

#### Ex2. Evaluate an expression and put the result in the target position
```
12345 * 56789 = 701060205       -- suppose the cursor is at 1
yf9A<Space><C-R>=<C-R>"<CR>     -- yank the expression and prepare to append
                                -- text at the end of line (after "= "), then
                                -- call expression register, paste the yanked
                                -- expression and press <Enter> to append the
                                -- result.
1 + sqrt(2) = 2.414214
yf)A<Space><C-R>=<C-R>"<CR>

sin(3.14159 / 6) = 0.5
yf)A<Space><C-R>=<C-R>"<CR>
```

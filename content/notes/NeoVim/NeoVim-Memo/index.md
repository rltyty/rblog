---
title: "NeoVim Memo"
subtitle: ""
date: 2025-10-16T08:10:09+08:00
lastmod: 2026-06-03T16:39:38+08:00
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
# VIM CHEAT SHEET

### 1. Reload `vimrc`

- `:so %` : reload current file (`so` = source, `%` = current file)

### 2. Change file name

- `:Sex` : split to open an Explorer window
- `R`    : Rename and press `<Enter>` to confirm

### 3. Movement

#### 3.1 [Jumping to the start and end of a code block](<http://vim.wikia.com/wiki/Jumping_to_the_start_and_end_of_a_code_block>)

- `[[` : sections backward or to the previous '{' in the first column.
- `]]` : sections forward or to the next '{' in the first column.
- `[]` : sections backward or to the previous '}' in the first column.
- `][` : sections forward or to the next '}' in the first column.
- mnemonic: Same for `{`, diff for `}`, `[` backward, `]` forward.

#### 3.2 Jump by sentence

- `)` : forward, next sentence
- `(` : backward, previous sentence

#### 3.3 Jump by paragraph

- `}` : forward, next paragraph
- `{` : backward, previous paragraph

#### 3.4 Jump to marker

- `mA` : mark the current position to register A
- `` `A `` : jump to mark A in the current buffer

### 4. [Place holder]

### 5. Windows

#### 5.1 Maximize the current window and resume the previous split structure.

- `<C-W> _`         maximize a window split horizontally
- `<C-W> |`         maximize a window split vertically
- `<C-W> T`         move the current window to another tab
- `<C-W> <C-V>`     split the window vertically
- `<C-W> <C-S>`     split the window horizontally

#### 5.2 Rotate split windows

- `<c-w>r` : can be used to swap two splited windows

#### 5.3 Resize windows

- `<C-W> =`         : to equal size
- `[N]<C-W> +/-`    : adjust height by [N] lines
- `[N]<C-W> </>`    : adjust width by [N] rows

#### 5.4 Duplicate current buffer in another tab

- `:tab sp`
- `:tab vs`

#### 5.5 Just close the new tab to resume

- `ZZ`
- `<C-W> c`

#### 5.6 Open N files

##### 5.6.1 In N windows horizontally

```bash
vim -O[N] <f1> <f2> ... <fN>
```

##### 5.6.2 In N windows vertically (stacked)

```bash
vim -o[N] <f1> <f2> ... <fN>
```

##### 5.6.3 In N tabs

```bash
vim -p[N] <f1> <f2> ... <fN>
```

### 6. Editing remote files with `netrw`

- `vim scp://rpi-lan//home/pi/tmp/a`
  - Note: `proto://<connect_string>/<abs_path>`, double slashes needed
- `%` : Create a new file
- `d` : Create a directory

### 7. Insert output of external command

- `:read !date<cr>`   : Insert a date in the next line
- `:read !date<cr>kJ` : Insert a date in the current line
- `:read !date +'\%a \%Y-\%m-\%d \%T \%Z'` : Insert a long format date in 24hr mode with weekday and
  timezone (Note: '%' need to be escaped)

### 8. Vimscript

#### 8.1 Line continuation

- Add a backslash in the next line make sure the backslash is the first
non-white character.
  ```
  let a = "Hello,
  \world!
   \ This i
  \s a test of
  \ line continuation."
  echo a    " Output: Hello, world! This is a test of line continuation.
  ```

### 9. Lua

#### 9.1 Set Vim/Neovim builtin options

- Vimscript set command: `set`, `setg[lobal]`, `setl[ocal]`
- Lua equivalent: `vim.opt`, `vim.opt_global`, `vim.opt_local`
- Obsolete Lua equivalent: ~~`vim.o`, `vim.go`, `vim.bo|wo`~~
  ```
  To set a boolean toggle:
  Vimscript: `set number`
  Lua:       `vim.opt.number = true`,
             `vim.o.number = true`

  To set a list option:
  Vimscript: `set wildignore=*.o,*.a,__pycache__`
             `vim.opt.wildignore = { '*.o', '*.a', '__pycache__' }`
             `vim.o.wildignore = '*.o,*.a,__pycache__'`

  To replicate the behavior of |:set+=|:
  Vimscript: `set wildignore+=*.pyc,node_modules`
  Lua:       vim.opt.wildignore:append { "*.pyc", "node_modules" }
             vim.o.wildignore = vim.o.wildignore .. ',*.pyc,node_modules'

  To set a map-style option:
  Vimscript: `set listchars=space:_,tab:>~`
  Lua:       `vim.opt.listchars = { space = '_', tab = '>~' }`
             `vim.o.listchars = 'space:_,tab:>~'`
  ```

- Modify options via `vim.opt` methods
  | Vimscript          | Lua                                | Description      |
  |--------------------|------------------------------------|------------------|
  | `set {option}+=val` | `vim.opt.{option}:append(val)`    | add to end       |
  | `set {option}^=val` | `vim.opt.{option}:prepend(val)`   | add to start     |
  | `set {option}-=val` | `vim.opt.{option}:remove(val)`    | remove value     |
  | `set {option}=val`  | `vim.opt.{option} = val`          | assign/overwrite |
  | `set {option}&`     | `vim.opt.{option} = nil`          | reset to default |

  **NOTE:**
  a. Always use `vim.opt` and `vim.opt_*` over `vim.o`. `vim.go` and
  `vim.bo|wo`
  b.
  ```lua
  vim.opt.formatoptions:append('n')                   -- ✅
  vim.opt.formatoptions = vim.opt.formatoptions + 'n' -- ✅, vim.opt creates `__add()` metamethod in metatable
  vim.opt.formatoptions = vim.opt.formatoptions .. 'n'-- ❌, not a str concat
  ```

- Get a close look at option type information

  ```lua
  vim.opt.formatoptions:append('n')         -- add a flag
  vim.opt.formatlistpat:append('\\|foo')    -- plain string concatenation
  vim.opt.listchars:append({ tab = '>-' })  -- add/update an entry

  -- `formatoptions`: string option with flaglist semantics
  :lua print(vim.inspect(vim.api.nvim_get_option_info2('formatoptions', {})))
  {
    allows_duplicates = true,
    commalist = false,
    default = "tcqj",
    flaglist = true,
    ...
    name = "formatoptions",
    type = "string",
    ...
  }

  -- formatlistpat: plain string option, without commalist or flaglist semantics
  :lua print(vim.inspect(vim.api.nvim_get_option_info2('formatlistpat', {})))
  {
    allows_duplicates = true,
    commalist = false,
    default = "^\\s*\\d\\+[\\]:.)}\\t ]\\s*",
    flaglist = false,
    ...
    name = "formatlistpat",
    type = "string",
    ...
  }

  -- listchars: dict-style string option, with commalist and no duplicates semantics
  :lua print(vim.inspect(vim.api.nvim_get_option_info2('listchars', {})))
  {
    allows_duplicates = false,
    commalist = true,
    default = "tab:> ,trail:-,nbsp:+",
    flaglist = false,
    ...
    name = "listchars",
    type = "string",
    ...
  }
  ```

#### 9.2 Custom variable scopes

- Vimscript: `let b:|w:|t:|g:|l:|s:|a:|v:`
- Lua equivalent: only cover the first 4 `vim.b|w|t|g`, the latter 4 are more
  Vimscript-specific scoping concepts

  ```
  Vimscript: `let g:<var> = <val>`
  Lua:       `vim.g.<var> = <val>`
  ```

#### 9.3 Environment variable

- `vim.env`, compare `h: expand-env` and `:h let-environment`

  ```
  Vimscript: `let $PATH = $PATH . ":/usr/local/bin"`
  Lua      : `vim.env.PATH = vim.env.PATH .. ":/usr/local/bin"`

  Vimscript: `echo $PATH`
  Lua      : `print(vim.env.PATH)`
  ```

### 10. Add my personal Nvim notes to Vim help doc system.
- Add a directory entry to `vim.runtimepath`, then the `doc` directory
  under it will be in the search list when typing :h `<my topic>`
- generate tags for `doc` by `:helptags doc`
- By default, `:help <topic>` opens the topic file in read-only mode,
  because `modifiable` option is set off by help. Turn it on by
  `set nomodifiable`.

### 11. Show current buffer file's full path: `<c-g>`

### 12. Neovim terminal mode

- `<C-\> <C-N>` : change to normal mode
- `a/i/A/I ...` : change to append/insert... mode

### 13. Enter Ex mode by `gQ`, exit the mode by `:vi`

### 14. In Ex mode, use `lua print(<func call>)` to check command output.

- `lua print(vim.fn.expand('%'))`

### 15. Since 0.9, `:=<var>` will show variable value.

### 16. Char count `:s/,//gn` count how many commas in a line

### 17. Remove all the trailing white spaces for each line in file.

- `:%s/\s\+$//e`

### 18. Show man page about the word under the current cursor:

- `gK` : `map('n', 'gK', '<Cmd>Man<CR>', {desc = 'Show man page for
<cword>'})`
- `K`  : remap `vim.lsp.buf.hover()` by lsp

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

### 20. `<Cmd>` :map-cmd

- This pseudo key begins a "command mapping", which executes the command without
changing modes. `<Cmd>...<CR>` can be used instead of `:...<CR>` in the
`{rhs}` of a mapping.

### 21. `<C-R><C-W>` insert the word under the cursor. See `h:<C-R>`

### 22. Debug Neovim instance in Neovim. See `:h osv`

### 23. To see last command output like: `g<`

### 24. Quickly switch between current and last buffer: `<C-6>`

### 25. Draw a table, especially add a column on the right side of a file

```txt
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
```

    See [How to insert a column on the right side of a file][1]

### 26. Visual block edit

#### 26.1 Insert a column (`N`+1 rows) of text

- `<C-v><N>jI<text>`
- **Note**: If the block spans short lines that do not extend into the block,
the text is not inserted in that line.

#### 26.2 Append a column of text after block selection, use `A` instead of `I`

```
<C-v><N>j$A<text>   append text to the end of each line in the block
```

#### 26.3 Use a character `<c>` to fill a rectangle of (`M`+1) x (`N`+1) size

- `<C-v><M>j<N>lr<c>` : `r` replace with

#### 26.4 Surround each line with double quotes and append a comma for each

```
V4j:normal I"
V4j:normal A",
```

```txt
# From

pytest>=8.0.0
pytest-html>=4.0.0
ruff
mypy
build

# To

"pytest>=8.0.0",
"pytest-html>=4.0.0",
"ruff",
"mypy",
"build",
```

#### 26.5 Change a column from A to B, use `c` command.

##### 26.5.1 Change prefix

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

##### 26.5.2 Change suffix

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

##### 26.5.3: Change suffix dynamically

```
v8j:'<,'>s/_\w\+\ze\s*$/\="_".(line(".")-line("'<")+1)/
```

```
LIST_BOOLEAN                LIST_1
LIST_BYTE                   LIST_2
LIST_CHARACTER              LIST_3
LIST_SHORT                  LIST_4
LIST_INTEGER      -->       LIST_5
LIST_LONG                   LIST_6
LIST_FLOAT                  LIST_7
LIST_DOUBLE                 LIST_8
LIST_STRING                 LIST_9
```

```
NOTE:
- `\=`: switches to expression evaluation
- `line(".")`: current line number being substituted
- `line("'<")`: line number of the start of the visual selection
- `\ze\s*$`: the `\ze` sets the end of match, ensuring it only replace the
   suffix at the end of the line (i.e. the second column)
```

### 27. `tpope/vim-surround`

#### 27.1 Builtin surrounding characters `<`, `t`, `a` (see `:h surround`)

```c
#include "unistd.h"
// cs"<       % < will trigger a prompt for a tag name to insert
#include <hello>unistd.h</hello>

// cs"t       % t also represents a tag, same to <
#include <hello>unistd.h</hello>

// cs"a       % a represents angle
#include <unistd.h>
```

#### 27.2 Surround the whole line by `()`

```
yss)
```

```
# From
A == B

# To
(A == B)
```

### 28. Type a strike through letter `a̶b̶c̶ X̶Y̶Z̶`

- By appending the Unicode "long strike overlay combining character" (`\u0336`)
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

#### Copy a selection to "1, paste "1 to the target position

```
"1yiw           # Copy the word at the current cursor to "1
                # Move to the target position
                # Method 1: change to insert mode and

<C-R>1          # Paste "1, <C-R> {register}: Insert the contents of a
                #                             numbered or named register.

"1p(P)          # Method 2: Just paste (p: after cursor, P: before cursor)
```

#### Evaluate an expression and put the result in the target position

```
12345 * 56789 = 701060205       # suppose the cursor is at 1

yf9A<Space><C-R>=<C-R>"<CR>     # yank the expression and prepare to append
                                # text at the end of line (after "= "), then
                                # call expression register, paste the yanked
                                # expression and press <Enter> to append the
                                # result.

1 + sqrt(2) = 2.414214
yf)A<Space><C-R>=<C-R>"<CR>

sin(3.14159 / 6) = 0.5
yf)A<Space><C-R>=<C-R>"<CR>
```

### 30. Treesitter

#### Folding

```
zR      # Open all folds
zM      # Close all folds
zo      # Open fold under cursor
zc      # Close fold under cursor
za      # Toggle fold under cursor
zO      # Open fold + all nested folds under cursor
zr      # Opens folds one level at a time (increments foldlevel by 1)
```

#### Fix latex parser installation on Raspberry Pi 3B+

```txt
The LaTeX treesitter grammar generates a 10MB+ `parser.c` file, requiring
~2.7GB virtual memory to compile — exceeding Pi 3B+'s 1GB RAM.

If the latex parser is needed on Pi, temporarily enlarge swap before compiling
(reverts to original size on reboot):

sudo swapoff /var/swap
sudo fallocate -l 3G /var/swap
sudo mkswap /var/swap
sudo swapon /var/swap

free -h     # verify RAM and swap sizes

Then install via `:TSInstall latex` or `vim6` to trigger automatic installation.

After compilation, reboot to shrink swap back to protect SD card from wear.

Or

sudo fallocate -l 2048M /var/swap
sudo mkswap /var/swap
sudo swapon /var/swap
```

### 31. Insert a long repeated string

- DO NOT use [count] in insert mode:

  ```vim
  1000000ia<ESC>    " ❌
  ```
  This repeats the insertion 1M times individually -- very slow.

- Instead, use `repeat()` which generates the string in memory first,
  then inserts it as a single operation:

  ```vim
  :put =repeat('a', 1000000)    " ✅

  ```

### 32. Use `vim.fn.expand '%'` in key mapping

- Any Lua code concatenated into a key map string
  e.g., `.. vim.fn.expand('%') ..` → evaluated once at creation time ❌
- Inside a Lua function() → evaluated at key-press time ✅
- `expand('%')` inside a Vimscript string passed to execute → evaluated at key press time ✅

- E.g. `lsp/jdtls.lua:230`

  - Change from

    ```lua
    map(
      { 'n' },
      '<leader>cjB',
      '<Cmd>Javap ' .. ' -v ' .. vim.fn.expand '%' .. '<CR>',
      { noremap = true, desc = 'JavaP: view class bytecode (VERBOSE)' }
    )
    ```

    to

    ```lua
    map(
      { 'n' },
      '<leader>cjB',
      function()
        vim.cmd({ cmd = 'Javap', args = { '-v', vim.fn.expand('%') } })
      end,
      { noremap = true, desc = 'JavaP: view class bytecode (VERBOSE)' }
    )
    ```

  - Change from

    ```lua
    map(
      { 'n' },
      '<leader>cjD',
      ':Cfr ' .. vim.fn.expand '%' .. ' ',
      { noremap = true, desc = 'Cfr: Decompile Java class (args)' }
    )
    ```

    to

    ```lua
    map(
      { 'n' },
      '<leader>cjD',
      function()
        local path = vim.fn.expand '%'
        vim.api.nvim_feedkeys(':Cfr ' .. path .. ' ', 'n', false)
      end,
      { noremap = true, desc = 'Cfr: Decompile Java class (args)' }
    )
    ```

# Hugo site content management


## Markdown Editing

### Math typing

#### Use `pandoc` as markdown handler for strict math-typesetting

```yaml
markup:
  defaultMarkdownHandler: "pandoc"
```

#### Display-mode (Block-mode)

$$
e = mc^2
$$

#### Inline-mode

This is an inline formula $y = \sqrt{x}$.

### Enable Math Typesetting

[A brief guide to setup KaTeX](https://github.com/adityatelange/hugo-PaperMod/blob/exampleSite/content/posts/math-typesetting.md)

## Install a theme

```sh
git submodule add --depth=1 https://github.com/dillonzq/LoveIt themes/LoveIt
```

## Update a theme

```sh
git submodule update --remote --merge themes/LoveIt
git commit -m "Update LoveIt theme"

# to update all submodules at once
git submodule update --remote --merge
```



## Build and deploy site

```sh
hugo [-D]                   # build
hugo [-D] server            # build and launch local server
hugodeploy [-D] <site>      # build and deploy to remote server (my personal
                            # utility)

```

## New content

```sh
hugo new content --kind chapter notes/apue/ch1-overview

```

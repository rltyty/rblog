## How Git hooks work

- `.git/hooks/` is a local directory inside your `.git` folder.
- Git does not track this directory in commits — it’s intentionally local to
  allow developers to have private hooks.
- You can create or modify pre-commit locally.
- Other collaborators won’t get your hooks when they clone or pull the repo.

## Track by myself

- Copy all the hooks under .git/hooks to hooks and then commit to upstream.
- Need to copy from hooks to .git/hooks after every new clone.

# ZPico

The minuscule zsh package manager. No frills, no bloat, just 4 kB of 100% Zsh code, providing complete package management for your Zsh environment.

Zsh package managers are abundant, but most are bloated, slow or have excessive requirements. On top of that, more than a few have been abandoned for years. Zpico does not seek to be the best of the best, rather to balance functionality against a tiny, fast footprint.

## Installation

Requires `git`.

```
curl -sL --create-dirs https://raw.githubusercontent.com/thornjad/zpico/main/zpico.zsh -o $HOME/.local/lib/zpico/zpico.zsh
```

Then add `source $HOME/.local/lib/zpico/zpico.zsh` to your `.zshrc` and reload your shell.

_This is the recommended installation path, but you can put it wherever you want._

## Usage

### Add packages

`zpico add <package-repo> [[source:<source>] [branch:<branch>] [use:<glob>]]`

This command downloads and initializes a given package. If the package has already been download, it initializes only. 

The required argument `package-repo` is the package's repo in `<group>/<project>` format (supports Gitlab subgroups with `source:gitlab`).

The optional argument `source:` determines the source domain to get the package from. Currently supports `github`, `gitlab`,  `framagit` and the special `local` (see [Local packages](#local-packages) below). If omitted, defaults to `source:github`.

The optional argument `branch` specifies the Git branch to use. If omitted, uses the default branch for the package (typically `master`, `main` or `trunk`).

The optional argument `use` specifies the file (or file pattern) to use.

#### Other URL

Zpico can also load packages from arbitrary URLs.

`zpico add <package-url> [branch:<branch>]`

The optional argument `branch` works the same as specified above.

#### Local packages

`zpico add <package-path> source:local [branch:<branch>]`

The optional argument `branch` works the same as specified above.

### Other commands

Precede all commands with `zpico`.

| command    | description                                                             |
|------------|-------------------------------------------------------------------------|
| update     | update all installed packages                                           |
| selfupdate | update Zpico. Requires `curl`. Alternatively, reinstall Zpico to update |
| clean      | remove all packages currently installed                                 |
| help       | print help text                                                         |
| version    | print version info                                                      |

### Customize package installation path

The default package installation path is `~/.local/share/zpico/`. Customize this by setting `ZP_PLUGIN_HOME` prior to loading Zpico in your `~/.zshrc`.

## Example

```
# ~/.zshrc
source ~/.local/lib/zpico/zpico.zsh

# Packages
zpico add nocttuam/autodotenv
zpico add zdharma/zsh-diff-so-fancy
zpico add thornjad/vero source:gitlab
```

## Uninstall

```
rm -rf ~/.local/lib/zpico ~/.local/share/zpico
```

Replace paths with the correct ones if you've customized them, then remove any Zpico-related commands from your `~/.zshrc`.

## License

Copyright (c) 2021-2023 Jade Michael Thornton

See [LICENSE](./LICENSE) for terms (it's the ISC license).

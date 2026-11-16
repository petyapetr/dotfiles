# dotfiles

This includes my configuration for zsh, git, terminal emulators and other stuff.

WIP: tools automatic download (Homebrew and WSL)

## Requirements

- `make`

## Install

1. Clone this repo into your home directory.

1. To set up all of the files as symlinks in your home directory, just run this:

	```bash
	make all
	```

### Micro

Install `micro`, `fzf`, and `bat` with your system's package manager, then run:

```sh
make micro-plugins
```

This links `micro/settings.json` and `micro/bindings.json` into
`${XDG_CONFIG_HOME:-$HOME/.config}/micro` and installs `filemanager`, `quoter`,
and `fzfinder`. `Ctrl-p` opens the fuzzy file picker with a `bat` preview.
On systems that call `bat` `batcat`, provide a `bat` executable on your `PATH`.

`make micro` only links the config and is included in `make all`. Existing
files are moved to `*.backup.*` beside the links. Re-running it leaves the
links alone. Plugins, backups, buffer history, and undo data stay local.

These targets work on macOS and Linux, including WSL. After cloning this repo
on another system, run `make micro-plugins` there too.

### WSL Add-ons

To set up wezterminal on wsl, run this:

```bash
make wezterm-wsl
```

## Node

To manage node js `vite+` should be used. Prior it used to be set up with `ni` and `fnm`.

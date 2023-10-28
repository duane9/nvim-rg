# nvim-rg

nvim-rg allows you to run ripgrep from Neovim or Vim and shows the results in a
quickfix window.

It was developed for use on macOS with Neovim. On Neovim, it runs
asynchronously. On Vim, it runs synchronously.

## Usage

Search recursively in {directory} (which defaults to the current directory) for
the {pattern}.

    :Rg [options] {pattern} [{directory}]

When run without arguments, you will be prompted for a pattern, directory, and
files pattern.

    :Rg

Or

    <leader>rg

To search for the word under the cursor use:

    <leader>rw

## Installation

This plugin requires ripgrep and works on macOS. Install ripgrep:

    brew install ripgrep

Install this plugin using [vim-plug](https://github.com/junegunn/vim-plug) (or
your favorite package manager):

```vim
Plug 'duane9/nvim-rg'
```

## Configuration

Specify a custom path (not required):

```vim
" Default is 'rg --vimgrep'
let g:rg_path = '<custom-rg-path-goes-here>'
```

Also, see `:help nvim-rg`.


## License

Copyright (c) Duane Hilton. Distributed under the same terms as Vim/Neovim. See
`:help license`.

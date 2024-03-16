# nvim-rg

nvim-rg allows you to run ripgrep from Neovim or Vim and shows the results in a
quickfix window. It was developed for use on macOS with Neovim. On Neovim, it runs
asynchronously.

## Usage

Search recursively in {directory} (which defaults to the current directory) for
the {pattern}.

    :Rg [options] {pattern} [{directory}]

When run without arguments, you will be prompted for a pattern, directory, and
file type.

    :Rg

Or

    <leader>rg

To search for the word under the cursor use:

    <leader>rw

## Installation

Install ripgrep:

    brew install ripgrep

Install this plugin using [vim-plug](https://github.com/junegunn/vim-plug) (or
your favorite plugin manager):

```vim
Plug 'duane9/nvim-rg'
```

## Configuration

Specify a custom base command. By default, `rg_command` is set to `rg --vimgrep`:

```vim
let g:rg_command = 'rg --vimgrep'
```


## Docs

See `:help nvim-rg`.

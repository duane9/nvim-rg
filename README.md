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

By default, `rg_run_async` is set to `1` to allow this plugin to run asynchronously on Neovim. If you want to run it synchronously, set `rg_run_async` to `0`:

```vim
" Change to 0 to run synchronously
let g:rg_run_async = 1
```

## Docs

See `:help nvim-rg`.

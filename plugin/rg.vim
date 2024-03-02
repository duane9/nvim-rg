" nvim-rg
" Author: Duane Hilton <https://github.com/duane9/>
" Version: 1.0.3

if !exists("rg_command")
  let rg_command = "rg --vimgrep"
endif

if !exists("default_dir")
  let default_dir = "./"
endif

" Change to 0 if you don't want the command to run asynchronously on Neovim
if !exists("rg_run_async")
  let rg_run_async = 1
endif

let s:chunks = [""]
let s:error = 0
let s:rg_job = 0

function! s:ProcessLines(lines)
  let l:lines_copy = copy(a:lines)
  " Remove trailing empty line
  if len(l:lines_copy) > 1 && l:lines_copy[-1] == ""
    let l:lines_copy = l:lines_copy[0:-2]
  endif
  " Remove leading relative path
  call map(l:lines_copy, 'substitute(v:val, "^\\.[\\/\\\\]", "", "")')
  return l:lines_copy
endfunction

function! s:Alert(msg)
  echohl WarningMsg | echomsg a:msg | echohl None
endfunction

function! s:ShowResults(data, title)
  call setqflist([])
  call setqflist([], 'r', {'context': 'file_search', 'title': a:title})
  caddexpr a:data
  copen
  let s:chunks = [""]
endfunction

function! s:HasQuote(item)
  return len(matchstr(a:item, '^.*"$')) || len(matchstr(a:item, "^.*'$"))
endfunction

function! s:NotOption(item)
  return len(a:item) && a:item[0] != '-'
endfunction

function! s:IsOption(item)
  return len(a:item) && a:item[0] == '-'
endfunction

function! s:HasDirectory(cmd)
  let l:options = [
  \ '-t',
  \ '--type',
  \ '-T',
  \ '--type-not',
  \ '-r',
  \ '--replace',
  \ '--max-filesize',
  \ '-m',
  \ '--max-count',
  \ '-d',
  \ '--max-depth',
  \ '-M',
  \ '--max-columns',
  \ '--ignore-file',
  \ '--iglob',
  \ '-g',
  \ '--glob',
  \ '-f',
  \ '--file',
  \ '-E',
  \ '--encoding',
  \ '-A',
  \ '--after-context',
  \ '-B',
  \ '--before-context'
  \ ]
  let l:cmd_parts = split(a:cmd)
  let l:has_dir = 0
  if s:HasQuote(l:cmd_parts[-1])
    let l:has_dir = 0
  elseif len(l:cmd_parts) > 1 && s:HasQuote(l:cmd_parts[-2]) && s:NotOption(l:cmd_parts[-1])
    let l:has_dir = 1
  elseif len(l:cmd_parts) > 3 &&
  \ index(l:options, l:cmd_parts[-4]) >= 0 &&
  \ s:NotOption(l:cmd_parts[-1])  &&
  \ s:NotOption(l:cmd_parts[-2]) &&
  \ s:NotOption(l:cmd_parts[-3])
    let l:has_dir = 1
  elseif len(l:cmd_parts) > 2 &&
  \ s:IsOption(l:cmd_parts[-3]) &&
  \ index(l:options, l:cmd_parts[-3]) == -1 &&
  \ s:NotOption(l:cmd_parts[-1]) &&
  \ s:NotOption(l:cmd_parts[-2])
    let l:has_dir = 1
  elseif len(l:cmd_parts) == 2 &&
  \ s:NotOption(l:cmd_parts[-1]) &&
  \ s:NotOption(l:cmd_parts[-2])
    let l:has_dir = 1
  endif
  return l:has_dir
endfunction

function! s:RgEvent(job_id, data, event) dict
  let l:msg = "Error: Pattern " . "- " . self.pattern . " -" . " not found"
  if a:event == "stdout"
    let s:chunks[-1] .= a:data[0]
    call extend(s:chunks, a:data[1:])
  elseif a:event == "on_stderr"
    let s:error = 1
    call s:Alert(msg)
  elseif a:event == "exit"
    if s:error isnot 0
      let s:error = 0
      return
    endif
    if s:rg_job == 0
      let s:chunks = [""]
      return
    endif
    let s:rg_job = 0
    if s:chunks[0] == ""
      call s:Alert(l:msg)
      return
    endif
    call s:Alert("")
    let s:chunks = s:ProcessLines(s:chunks)
    call s:ShowResults(s:chunks, self.cmd)
  endif
endfunction

function! s:RunCmd(cmd, pattern)
  " Stop any long-running jobs before starting a new one
  if s:rg_job isnot 0
    call jobstop(s:rg_job)
    let s:rg_job = 0
    call s:Alert("Search interrupted. Please try your search again.")
    return
  endif
  " Run async if Neovim
  if has("nvim") && g:rg_run_async isnot 0
    call s:Alert("Searching...")
    let l:opts = {
    \ "on_stdout": function("s:RgEvent"),
    \ "on_stderr": function("s:RgEvent"),
    \ "on_exit": function("s:RgEvent"),
    \ "pattern": a:pattern,
    \ "cmd": a:cmd
    \ }
    let s:rg_job = jobstart(a:cmd, l:opts)
    return
  endif
  " Run w/o async if Vim
  let l:cmd_output = system(a:cmd)
  if l:cmd_output == ""
    let l:msg = "Error: Pattern " . "- " . a:pattern . " -" . " not found"
    call s:Alert(l:msg)
    return
  endif
  call s:ShowResults(l:cmd_output, a:cmd)
endfunction

function! s:RunRg(cmd)
  if len(a:cmd) > 0
    let l:cmd_options = g:rg_command . " " . a:cmd . " " . g:default_dir
    " check if cmd contains directory; don't use default_dir if it does
    if s:HasDirectory(a:cmd)
      let l:cmd_options = g:rg_command . " " . a:cmd
    endif
    call s:RunCmd(l:cmd_options, a:cmd)
    return
  endif
  let l:pattern = input("Search for pattern: ")
  if l:pattern == ""
    return
  endif
  echo "\r"
  let l:startdir = input("Start searching from directory: ", "./")
  if l:startdir == ""
    return
  endif
  echo "\r"
  let l:ftype = input("File type (optional): ", "")
  if l:ftype != ""
    let l:ftype = " -t " . l:ftype
  endif
  echo "\r"
  let l:cmd = g:rg_command . l:ftype . " '" . l:pattern . "' " . l:startdir
  call s:RunCmd(l:cmd, l:pattern)
endfunction

command! -nargs=? -complete=file Rg call s:RunRg(<q-args>)
map <leader>rg :Rg<CR>
" Use Rg to search for word under cursor
map <leader>rw :Rg <cword><CR>

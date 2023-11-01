" nvim-rg
" Author: Duane Hilton <https://github.com/duane9/>
" Version: 0.9.4

" Path to rg
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

function! s:Alert(msg)
  echohl WarningMsg | echomsg a:msg | echohl None
endfunction

function! s:ShowResults(data)
  call setqflist([])
  caddexpr a:data
  copen
  let s:chunks = [""]
endfunction

function! s:RgEvent(job_id, data, event) dict
  let msg = "Error: Pattern " . self.pattern . " not found"
  if a:event == "stdout"
    let s:chunks[-1] .= a:data[0]
    call extend(s:chunks, a:data[1:-2])
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
      call s:Alert(msg)
      return
    endif
    call s:Alert("")
    call s:ShowResults(s:chunks)
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
    let opts = {
    \ "on_stdout": function("s:RgEvent"),
    \ "on_stderr": function("s:RgEvent"),
    \ "on_exit": function("s:RgEvent"),
    \ "pattern": a:pattern
    \ }
    let s:rg_job = jobstart(a:cmd, opts)
    return
  endif
  " Run w/o async if Vim
  let cmd_output = system(a:cmd)
  if cmd_output == ""
    let msg = "Error: Pattern " . a:pattern . " not found"
    call s:Alert(msg)
    return
  endif
  call s:ShowResults(cmd_output)
endfunction

function! s:RunRg(cmd)
  if len(a:cmd) > 0
    let cmd_options = g:rg_command . " " . a:cmd . " " . g:default_dir
    let cmd_parts = split(a:cmd)
    if len(cmd_parts) > 1
      if cmd_parts[-1][0] != '-' && cmd_parts[-2][0] != '-'
        " cmd contains directory; don't use default_dir
        let cmd_options = g:rg_command . " " . a:cmd
      endif
    endif
    call s:RunCmd(cmd_options, "")
    return
  endif
  let pattern = input("Search for pattern: ")
  if pattern == ""
    return
  endif
  echo "\r"
  let startdir = input("Start searching from directory: ", "./")
  if startdir == ""
    return
  endif
  echo "\r"
  let ftype = input("File type (optional): ", "")
  if ftype != ""
    let ftype = " -t" . ftype
  endif
  echo "\r"
  let cmd = g:rg_command . ftype . " '" . pattern . "' " . startdir
  call s:RunCmd(cmd, pattern)
endfunction

command! -nargs=? -complete=file Rg call s:RunRg(<q-args>)
map <leader>rg :Rg<CR>
" Use Rg to search for word under cursor
map <leader>rw :Rg <cword><CR>

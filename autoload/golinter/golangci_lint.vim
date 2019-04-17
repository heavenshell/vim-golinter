" File: golinter.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-golinter
" Description: Vim plugin for Golinter
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

let s:qflist = []

function! s:callback(ch, msg) abort
  try
    let issues = json_decode(a:msg)
    for issue in issues['Issues']
      let pos = issue['Pos']
      call add(s:qflist, {
        \ 'filename': pos['Filename'],
        \ 'lnum': pos['Line'],
        \ 'col': pos['Column'],
        \ 'text': printf('[%s] %s', issue['FromLinter'], issue['Text']),
        \ })
    endfor
  catch
    echohl Error | echomsg a:msg | echohl None
  endtry
endfunction

function! s:exit_callback(ch, msg) abort
  let Callback = function('golinter#setqflist', [s:qflist])
  call Callback()
endfunction

function! golinter#golangci_lint#run(bufnum, args) abort
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif
  let name = bufname(bufnr('%'))
  let file = fnamemodify(name, ':p')

  let cmd = 'golangci-lint run --out-format json '
  if len(a:args) > 0
    let cmd .= join(a:args, ' ')
  endif

  let s:qflist = []
  " Golangci_lint does not support STDIN
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
        \ 'in_io': 'file',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

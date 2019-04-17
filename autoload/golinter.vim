" File: golinter.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-golinter
" Description: Vim plugin for Golinter
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

let g:golinter_lints = get(g:, 'golinter_lints', [{'cmd': 'golangci_lint'}])
let s:event_queue = []
let s:event_timer = -1
let s:notifier = ''

function! s:sort(i1, i2) abort
  return a:i1['lnum'] == a:i2['lnum'] ? 0 : a:i1['lnum'] > a:i2['lnum'] ? 1 : -1
endfunction

function! s:add_event_queue(delay, bufnum) abort
  if index(s:event_queue, a:bufnum) != -1
    return
  endif

  if s:event_timer != -1
    call timer_stop(s:event_timer)
    let s:event_timer = -1
  endif

  call add(s:event_queue, a:bufnum)

  let s:event_timer = timer_start(
    \ a:delay,
    \ function('s:send_event')
    \ )
endfunction

function! s:send_event(timer) abort
  for bufnum in s:event_queue
    if !bufexists(l:bufnum)
      continue
    endif
    for lint in g:golinter_lints
      if has_key(lint, 'cmd')
        let cmd = printf('golinter#%s#run', lint['cmd'])
        let args = []
        if has_key(lint, 'args')
          let args = lint['args']
        endif
        let Callback = function(cmd, [bufnum, args])
        call Callback()
      endif
    endfor
  endfor
  let s:event_queue = []
endfunction

function! golinter#setqflist(qflist) abort
  let qflist = sort(a:qflist, 's:sort')
  if s:notifier == ''
    call setqflist(qflist, 'r')
  else
    let Callback = function(s:notifier, [qflist])
    call Callback()
  endif
endfunction

function! golinter#register_notifer(notifier) abort
  let s:notifier = a:notifier
endfunction

function! golinter#run(...) abort
  let delay = len(a:000) ? a:1 : 0
  let bufnum = bufnr('%')

  call s:add_event_queue(delay, bufnum)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

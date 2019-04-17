" File: golinter.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-golinter
" Description: Vim plugin for Golinter
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_golinter')
  finish
endif

if !has('channel') || !has('job')
  echoerr '+channel and +job are required for golinter.vim'
  finish
endif

command! -buffer Golinter :call golinter#run()
noremap <silent> <buffer> <Plug>(Golinter) :Golinter <CR>

let b:loaded_golinter = 1

let &cpo = s:save_cpo
unlet s:save_cpo


" Vim compiler file for Python
" Compiler:	Python
" Maintainer: André Alexandre Aguiar

if exists("current_compiler")
  finish
endif
let current_compiler = "python"

let s:cpo_save = &cpo
set cpo&vim

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet errorformat=%E\ %#File\ \"%f\"\\,\ line\ %l%.%#,%Z%m,%-G\ %#%p^%.%#
CompilerSet makeprg=python3

let &cpo = s:cpo_save

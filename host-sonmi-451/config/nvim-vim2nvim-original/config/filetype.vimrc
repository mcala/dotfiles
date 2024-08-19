" Filetype settings
filetype on

" Make cuda and PFUNIT fortran files display fortran syntax.
autocmd BufNewFile,BufRead *.cuf set filetype=fortran
autocmd BufNewFile,BufRead *.pf set filetype=fortran

" Makefiles use tabs instead of spaces.
autocmd BufNewFile,BufRead make.sys set filetype=make
autocmd Filetype make setlocal noexpandtab

"Git commits
autocmd Filetype gitcommit setlocal spell textwidth=72 colorcolumn=72

"diff
au VimEnter * if &diff | execute 'windo set wrap' | endif

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

" latex
autocmd Filetype tex,latex,plaintex call pencil#init({'wrap' :'soft', 'autoformat' : 0}) |  call lexical#init() | call litecorrect#init()

" Markdown
"autocmd BufNewFile,BufRead *.markdown set filetype=markdown.pandoc
"autocmd Filetype markdown,mkd,md,markdown.pandoc call pencil#init({'wrap' :'soft', 'autoformat' : 0}) | call lexical#init() | call litecorrect#init()
"autocmd Filetype markdown,mkd,md,markdown.pandoc call lexical#init() | call litecorrect#init()

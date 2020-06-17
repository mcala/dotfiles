" MAPPINGS
" Remap leader and : to more convienent keys.
let mapleader=","
nnoremap ; :
:inoremap jk <Esc>

" netrwc
nnoremap <silent> <leader>n :Vexplore<cr>

" Gets rid of search highlighting when you find what you need.
nnoremap <silent> <leader><space> :nohlsearch<cr>

" Window mappsing.
" Use <ctrl>+hjkl to move around.
" Use <leader>w to open vertical split.
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Autocenter movement commands
nnoremap G Gzz
nnoremap n nzz
nnoremap N Nzz
nnoremap } }zz
nnoremap { {zz
nnoremap <C-o> <C-o>zz

" COMMANDS
" Strip (t)railing whitespace throughout file.
nnoremap <leader>s :%s/\s\+$//<cr>

" Unset line numbers and blank characters for easier copy and paste
nnoremap <leader>c :set nu!<cr>:set rnu!<cr>:set list!<cr>

" Reset vim's current directory to pwd. Used mostly when moving to programming
" directories using marks to allow navigation to other files
nnoremap <leader>d :lcd %:p:h<cr>

set pastetoggle=<F3>

" Wiki/Writing Settings
let g:vimwiki_list = [{'path': '~/Dropbox/memory/', 'syntax': 'markdown', 'ext': '.md'}]
set wildmenu
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'ruby'] 
" Combines all lines not separated by return into one soft wrapped paragraph
nnoremap <silent> Q vipJ
" No concealing
let g:pencil#conceallevel = 0
let g:markdown_syntax_conceal = 0
let g:vimwiki_conceallevel = 0

"Would be nice if this worked in vimwiki files
":inoremap <Tab> <C-x><C-f>

"Toggle Goyo -> leader WRITE
nnoremap <silent> <Leader>W :Goyo<cr>

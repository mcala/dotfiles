" MAPPINGS
" Remap leader and : to more convienent keys.
let mapleader=","
let maplocalleader=","
nnoremap ; :
:inoremap jk <Esc>

" netrwc
nnoremap <silent> <leader>n :Vexplore<cr>

" Gets rid of search highlighting when you find what you need.
nnoremap <silent> <leader><space> :nohlsearch<cr>

" Window mappings
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
nnoremap <leader>c :set nu!<cr>:set rnu!<cr>:set list!<cr>:GitGutterToggle<cr>

" Reset vim's current directory to pwd. Used mostly when moving to programming
" directories using marks to allow navigation to other files
nnoremap <leader>d :lcd %:p:h<cr>

" Combines all lines not separated by return into one soft wrapped paragraph
nnoremap <silent> Q vipJ

set pastetoggle=<F3>

" Plain Text Project Managment
" Project Index
nnoremap <leader>p :e /Users/mcala/Dropbox/5_management/index.md<cr>
" Today's journal entry: Need to figure out how to use evaluation from zsh in vim
"nnoremap <leader>j :e ~/Dropbox/5_management/journal/$(date "+%Y.%m.%d.md)<cr>

"Toggle Goyo -> leader WRITE
nnoremap <silent> <leader>W :Goyo<cr>

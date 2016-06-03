" Andrew McAllister's .vimrc
"GENERAL
" Dealing with compatibility
set nocompatible
set encoding=utf-8

" Pathogen plugins
filetype off
execute pathogen#infect()
filetype plugin indent on

" Security measure.
set modelines=0

" AESTHETICS
" You only use free source fortran, so this doesn't bother with checking for
" fixed format. Must be before syntax. 
:let fortran_free_source=1
:let fortran_more_precise=1
" syntax highlighting
syntax enable
set background=dark
colorscheme solarized
" These may be necessary for supercomputers to work with solarized. 
" Keep until you know for sure
"let g:solarized_visibility = "high"
"let g:solarized_contrast = "high"
"let g:hybrid_use_Xresources = 1

" Airline settings
let g:airline_powerline_fonts=1
let g:airline_theme='solarized'
" Disable bufferline (since already shown in airline)
let g:bufferline_echo=0

" Filetype settings
" Make cuda fortran files display fortran syntax.
" Makefiles use tabs instead of spaces.
if has ("autocmd")
    filetype on
    autocmd BufNewFile,BufRead *.cuf set filetype=fortran
    autocmd BufNewFile,BufRead make.sys set filetype=make
    autocmd Filetype make setlocal noexpandtab
    autocmd Filetype gitcommit setlocal spell textwidth=72 
    autocmd Filetype latex setlocal spell 
    filetype plugin indent on
endif

" Draw colored column at 85 characters for textwidth purposes.
set textwidth=80
set colorcolumn=80
set wrap

" How to draw invisible characters.
set list
set listchars=tab:▸\ ,eol:¬,trail:.

" SETTINGS

" Tab settings.
"set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Visual aspects of vim.
set laststatus=2            " Always have bottom status (airline)
set noshowmode "            " Don't show normal vim status (have airline)
set number
set relativenumber

" Searching
" case: all lowercase: no case. mixed case: will have case.
" inc: incremental search
" hl: highlight search
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch               " Show matching brackets briefly by jumping to them.

" Replacing, have g be default (global and local).
set gdefault

" Backing up and history.
set history=100
set undolevels=1000
au FocusLost * :wa
set undofile
set undodir=~/.vim/undo
set nobackup
set swapfile

" Don't redraw the window each time a macro is used.
set lazyredraw

" Fixes backspace and movement with j and k.
set backspace=2
nnoremap j gj
nnoremap k gk

" These are LLNL specific backspace commands as far as I know. However, they
" do not affect other machines.
set t_kb=
fixdel

" Use hidden buffers
set hidden

" MAPPINGS
" Remap leader and : to more convienent keys.
let mapleader=","
nnoremap ; :
:imap jk <Esc>

" Leader commands for saving and quitting.
nmap <leader>s :w<cr>
nmap <leader>q :wq<cr>
imap <leader>s <Esc>:w<cr>i
imap <leader>q <Esc>:wq<cr>

" Gets rid of search highlighting when you find what you need.
nnoremap <silent> <leader><space> :nohlsearch<cr>

" Changes the bracket matching to use tab.
nnoremap <tab> %
vnoremap <tab> %

" Window mappsing.
" Use <ctrl>+hjkl to move around.
" Use <leader>w to open vertical split.
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Autocenter movement commands
nmap G Gzz
nmap n nzz
nmap N Nzz
nmap } }zz
nmap { {zz
nmap <C-o> <C-o>zz

" COMMANDS
" Strip (t)railing whitespace throughout file.
nmap <leader>t :%s/\s\+$//<cr>

" Unset line numbers and blank characters for easier copy and paste
nmap <leader>c :set nu!<cr>:set rnu!<cr>:set list!<cr>

" Reset vim's current directory to pwd. Used mostly when moving to programming
" directories using marks to allow navigation to other files
nmap <leader>d :lcd %:p:h<cr>

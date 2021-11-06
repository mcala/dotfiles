" Python
" python3 problems? Remember to use :CheckHealth command in Neovim to figure
" out what the issue is
let g:python3_host_prog = '/Users/mcala/anaconda3/envs/py3/bin/python'

" use system clipboard rather than */+ register
set clipboard+=unnamedplus

set modelines=0
set omnifunc=

" You only use free source fortran, so this doesn't bother with checking for fixed format. Must be before syntax.
:let fortran_free_source=1
:let fortran_more_precise=1

" How to draw invisible characters.
set list
set listchars=tab:▸\ ,eol:¬,trail:.

"Tab settings.
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Line Numbers
set number
set relativenumber

" Searching
" case: all lowercase: no case. mixed case: will have case.
set ignorecase
set smartcase
set showmatch               " Show matching brackets briefly by jumping to them.

"Central swap file location
set swapfile
set directory=$HOME/.config/nvim/swapfiles/

" Undo files
set undofile
set undodir=$HOME/.config/nvim/undofiles/
set undolevels=10000
au FocusLost * :wa

" Don't redraw the window each time a macro is used.
set lazyredraw

" Fixes backspace and movement with j and k.
set backspace=2
nnoremap j gj
nnoremap k gk

" Use hidden buffers
set hidden

" netrw
" Get rid of banner
let g:netrw_banner = 0
" Show as tree style listing
let g:netrw_liststyle = 3
" Open files with  enter in _previous_ split
let g:netrw_browse_split = 4
" Keep window size at 20% 
let g:netrw_winsize = 20

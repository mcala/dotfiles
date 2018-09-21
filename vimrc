" Andrew McAllister's .vimrc


" Python
let g:python3_host_prog = '/Users/mcala/anaconda3/envs/neovim/bin/python'

" use system clipboard rather than */+ register
set clipboard+=unnamedplus

" Pathogen plugins
filetype off
"execute pathogen#infect()
filetype plugin indent on

" Security measure.
set modelines=0

" AESTHETICS
" You only use free source fortran, so this doesn't bother with checking for
" fixed format. Must be before syntax.
:let fortran_free_source=1
:let fortran_more_precise=1

" syntax highlighting
set background=dark
"set termguicolors
"let g:quantum_black=1
"let g:quantum_italics=1
colorscheme solarized
highlight SpellBad cterm=bold ctermfg=red

" Airline settings
let g:airline#extensions#ale#enabled=1
let g:airline_powerline_fonts=1
let g:airline_theme='solarized'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space="\ua0"

" Disable bufferline (since already shown in airline)
let g:bufferline_echo=0

let g:lexical#spelllang = ['en_us']

" pandoc syntax options
let g:pandoc#syntax#conceal#use = 0

" Filetype settings
" Make cuda fortran files display fortran syntax.
" Makefiles use tabs instead of spaces.
if has ("autocmd")
    filetype on
    autocmd BufNewFile,BufRead *.cuf set filetype=fortran
    autocmd BufNewFile,BufRead *.pf set filetype=fortran
    autocmd BufNewFile,BufRead make.sys set filetype=make
    autocmd BufNewFile,BufRead *.markdown set filetype=markdown.pandoc
    autocmd Filetype make setlocal noexpandtab
    autocmd Filetype gitcommit setlocal spell textwidth=72
    autocmd Filetype tex setlocal spell textwidth=90 colorcolumn=90 wrap
    autocmd Filetype plaintex call pencil#init({'wrap' : 'soft', 'autoformat' : 0}) | call lexical#init()
    autocmd Filetype latex setlocal spell textwidth=90 colorcolumn=90 wrap
    autocmd Filetype markdown,mkd,md,markdown.pandoc call pencil#init({'wrap' :'soft', 'autoformat' : 0}) | call lexical#init() | call litecorrect#init()
endif



" Draw colored column at 80 characters for textwidth purposes.
set textwidth=80
set colorcolumn=80
let g:pencil#textwidth = 80

" How to draw invisible characters.
set list
set listchars=tab:▸\ ,eol:¬,trail:.

" SETTINGS

"Tab settings.
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Visual aspects of vim.
set noshowmode "            " Don't show normal vim status (have airline)
set number
set relativenumber

" Searching
" case: all lowercase: no case. mixed case: will have case.
set ignorecase
set smartcase
set showmatch               " Show matching brackets briefly by jumping to them.

"Central swap file location
set directory^=$HOME/.vim/swapfiles//

" Backing up and history.
set undolevels=1000
au FocusLost * :wa
set undofile
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

" Use hidden buffers
set hidden

" MAPPINGS
" Remap leader and : to more convienent keys.
let mapleader=","
nnoremap ; :
:inoremap jk <Esc>

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

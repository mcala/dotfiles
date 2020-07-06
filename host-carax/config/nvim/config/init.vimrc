call plug#begin('~/.config/nvim/plugged')
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dhruvasagar/vim-table-mode'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'vim-pandoc/vim-pandoc' 
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'dkarter/bullets.vim'
Plug 'donRaphaco/neotex', { 'for': ['tex','latex'] }
Plug 'junegunn/goyo.vim', { 'for' : ['markdown', 'tex', 'latex'] }

call plug#end() 

" Old plugins
"Plug 'reedes/vim-pencil'
"Plug 'reedes/vim-lexical'
"Plug 'reedes/vim-litecorrect'
"Plug 'iCyMind/NeoSolarized'
"Plug 'brettanomyces/nvim-editcommand' -- Never really used this
"Plug 'neomake/neomake'

" pandoc syntax options
let g:pandoc#filetypes#handles = [ "pandoc", "markdown", "rst", "textile", "extra"]
let g:pandoc#filetypes#pandoc_markdown = 1
let g:pandoc#syntax#conceal#use = 0 " Show syntax
let g:pandoc#syntax#style#emphases = 1

let g:pandoc#modules#enabled = ["formatting", "toc", "spell", "folding", "keyboard"]
let g:pandoc#modules#disabled = ["command"]

let g:pandoc#keyboard#enabled_submodules = ["checkboxes"]

" Folding
let g:pandoc#folding#mode = 'relative'
let g:pandoc#folding#level = 2
let g:pandoc#folding#fdc = 0

" Old thesis bibliography. Not in use at the moment.
"let g:pandoc#biblio#sources = 'g'
"let g:pandoc#biblio#bibs = '/Users/mcala/Documents/writing/thesis/bibliography'
"let g:pandoc#completion#bib#mode = 'fallback'

" LaTeX
let g:tex_flavor = "latex"
let g:neotex_pdflatex_alternative = 'lualatex'
let g:neotex_latexdiff = 'lualatex'

" syntax highlighting
set termguicolors
colorscheme challenger_deep

"set background=dark
"colorscheme NeoSolarized
"let g:neosolarized_bold = 1
"let g:neosolarized_italic = 1
"let g:neosolarized_underline = 1
"
highlight SpellBad cterm=bold ctermfg=red

" nvim-editcommand
let g:editcommand_prompt = '>'

" Airline settings
set noshowmode
let g:airline_powerline_fonts=1
let g:airline_theme='challenger_deep'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#ale#enabled=1

" Disable bufferline (since already shown in airline)
let g:bufferline_echo=0

" Reedes Plugins
let g:pencil#textwidth = 80
let g:lexical#spelllang = ['en_us']

"GoYo
let g:goyo_width = 100  "default 80
let g:goyo_height = "100%" "default 80%
let g:goyo_linenr = 0 "(default: 0)

" :q straight from goyo
function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

" Bullets.vim
let g:bullets_enabled_file_types = [ 'pandoc', 'markdown', 'md', 'text']

" FZF Stuff
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

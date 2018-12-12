" pandoc syntax options
let g:pandoc#syntax#conceal#use = 0
let g:pandoc#syntax#style#emphases = 1
let g:pandoc#modules#enabled = ["formatting", "toc", "spell", "command"]
let g:pandoc#modules#disabled = ["folding"]

" At the moment, issue with python
"let g:pandoc#biblio#sources = 'g'
"let g:pandoc#biblio#bibs = '/Users/mcala/Documents/writing/thesis/bibliography'
"let g:pandoc#completion#bib#mode = 'fallback'

" LaTeX
let g:tex_flavor = "latex"
let g:neotex_pdflatex_alternative = 'lualatex'
let g:neotex_latexdiff = 'lualatex'


" syntax highlighting
set termguicolors
set background=dark
colorscheme NeoSolarized
let g:neosolarized_bold = 1
let g:neosolarized_italic = 1
let g:neosolarized_underline = 1
highlight SpellBad cterm=bold ctermfg=red

" nvim-editcommand
let g:editcommand_prompt = '>'

" Airline settings
set noshowmode
let g:airline_powerline_fonts=1
let g:airline_theme='solarized'
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

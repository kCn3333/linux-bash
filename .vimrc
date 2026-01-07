" --- YAML & K8s tweaks ---

" Optional: highlight the current line
" set cursorline

" Show line numbers for easier navigation
set number

" Show invisible characters (tabs, trailing spaces)
set list
set listchars=tab:▸\ ,trail:·

" Enable folding based on indentation - great for long K8s manifests
set foldmethod=indent
" Start with all folds open
set foldlevel=99

" Specific settings for YAML files
autocmd FileType yaml setlocal cursorcolumn

" Optional: faster scrolling and better redraw
set ttyfast
set lazyredraw

filetype plugin on

filetype indent on

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

autocmd BufRead,BufNewFile * match Error /\s\+$/

set autoindent

syntax on

set backspace=indent,eol,start


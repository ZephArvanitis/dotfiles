" We don't care about vi
set nocompatible

" VUNDLE/BUNDLE THINGS
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
" let Vundle manage Vundle
Bundle 'gmarik/vundle'
Bundle 'jcf/vim-latex'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'petRUShka/vim-opencl'
" Bundle 'Floobits/floobits-vim'
set updatetime=100 " Will write the swap file and also update the web UI every 100 ms
" Haskell joy
Bundle 'Haskell-Conceal'
Bundle 'indenthaskell.vim'
Bundle 'lukerandall/haskellmode-vim'
Bundle 'gibiansky/vim-latex-objects'
let g:haddock_browser='open'
Bundle 'scrooloose/Syntastic'
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_haskell_checkers=["hlint"]

" Make CtrlP work...maybe
set runtimepath^=~/.vim/bundle/ctrlp.vim

" Essentially allow plugins?
filetype indent plugin on
" Syntax highlighting
syntax on
" Line numbers
set number
" Indentation!
set smartindent
" Stop highlighting all matches in searches
set nohlsearch
" Folding stuff
set foldmethod=indent
set foldminlines=3
" Tabs are 4 spaces instead of 8
set expandtab
set tabstop=4
set shiftwidth=4
" Smart case for searches
set ignorecase
set smartcase
set incsearch
" Keep five lines around the current cursor position
set scrolloff=5
" Set up nice tabbing
map <C-h> :tabp<CR>
map <C-l> :tabn<CR>
map <C-t> :tabnew 
set autochdir
" Spell-checking. 
au! BufEnter,BufRead *.txt set spell
" Line wrapping!
set textwidth=75
" Shortcuts
" Delete forward in insert mode with C-d
imap <C-d> <ESC>lxi
" Move around quickly with the arrow keys (not in insert mode)
map <Up> 10k
map <Down> 10j
map <Left> 10h
map <Right> 10l

" Map space to : for ease of use
map <SPACE> :

" Deal with non-zero history
set history=1000

" Set the look of vim
set background=dark
colo ron

" LaTeX things
if has('macunix')
    let g:Tex_ViewRule_pdf='Skim'
endif
au BufRead,BufNewFile *.tex source ~/.vim/tex.vim

" Haskell things
au BufRead,BufNewFile *.hs source ~/.vim/haskell.vim

" Enable FHiCL syntax highlighting
au BufRead,BufNewFile *.fcl set syntax=fcl
au BufRead,BufNewFile *.fcl set nospell

set wildignore=*.o,*.obj,*.hi,*.pdf,*.log,*.aux,*.out

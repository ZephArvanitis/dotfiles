" We don't care about vi
set nocompatible

" VUNDLE/BUNDLE THINGS
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle
Plugin 'gmarik/vundle'
Plugin 'lervag/vimtex'
let g:vimtex_view_method = 'skim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'petRUShka/vim-opencl'
" Rust
Plugin 'rust-lang/rust.vim'
" Haskell joy
Plugin 'Haskell-Conceal'
Plugin 'indenthaskell.vim'
Plugin 'lukerandall/haskellmode-vim'
Plugin 'gibiansky/vim-latex-objects'
let g:haddock_browser='open'
Plugin 'tpope/vim-markdown'
Plugin 'scrooloose/Syntastic'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'tmhedberg/SimpylFold'
call vundle#end()
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
" Python checking/autopep8 formatting
let g:syntastic_python_checkers = ['python', 'flake8', 'pylint']
au FileType python setlocal formatprg=autopep8\ -
" autocmd FileType python setlocal foldenable foldmethod=syntax
autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<
let g:SimpylFold_docstring_preview = 2
map <F2> :lprev<CR>
map <F3> :lnext<CR>
" Make CtrlP work...maybe
set runtimepath^=~/.vim/bundle/ctrlp.vim
filetype indent plugin on

" NON-BUNDLE STUFF
" Syntax highlighting
syntax on
" Backspace through indents, newlines, and past where I started editing.
set backspace=indent,eol,start
" Line numbers
set number
" Indentation!
set smartindent
set cindent
" Stop highlighting all matches in searches
set nohlsearch
" Folding stuff
set foldmethod=indent
set foldminlines=3
set foldignore=
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
colo koehler

" LaTeX things
" au BufRead,BufNewFile *.tex source ~/.vim/tex.vim

" Enable mpr syntax highlighting
au BufRead,BufNewFile *.mpr set syntax=mpr
au BufRead,BufNewFile *.mpr set nospell

" Enable maeff syntax highlighting
au BufRead,BufNewFile *.maeff set syntax=maeff
au BufRead,BufNewFile *.maeff set nospell

" Force markdown syntax highlighting on .md
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Don't wrap text in .dict files
au! BufEnter,BufRead *.dict set nowrap

set wildignore=*.o,*.obj,*.hi,*.pdf,*.log,*.aux
set listchars=tab:>-,trail:~,extends:>,precedes:<
set list

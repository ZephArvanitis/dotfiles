" We don't care about vi
set nocompatible


" VUNDLE/BUNDLE THINGS
" As of 2020-07-04, I'm moving to vim-plug, which seems to be the
" community-favored alternative. For now (and regardless of the fact that
" I version control this stuff), I'm commenting out my old vundle config.
" filetype off
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()
" " let Vundle manage Vundle
" Plugin 'gmarik/vundle'
" Plugin 'lervag/vimtex'
" let g:vimtex_view_method = 'skim'
" Plugin 'tpope/vim-surround'
" Plugin 'tpope/vim-repeat'
" Plugin 'petRUShka/vim-opencl'
" " Rust
" Plugin 'rust-lang/rust.vim'
" " Haskell joy
" Plugin 'Haskell-Conceal'
" Plugin 'indenthaskell.vim'
" Plugin 'lukerandall/haskellmode-vim'
" Plugin 'gibiansky/vim-latex-objects'
" let g:haddock_browser='open'
" Plugin 'tpope/vim-markdown'
" Plugin 'scrooloose/Syntastic'
" Plugin 'vim-scripts/indentpython.vim'
" Plugin 'tmhedberg/SimpylFold'
" call vundle#end()

" vim-plug: automatically clone the plugin if it's not already present.
" This is nice for setting up on new instances of servers etc.
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" Get plugins! Run :PlugInstall to get them when initializing a new system
call plug#begin()
" General utility plugins. Thanks tpope!
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
" Commenting out code
Plug 'tpope/vim-commentary'
" Better folding
Plug 'tmhedberg/SimpylFold'
" Handy status line at the bottom of vim
Plug 'itchyny/lightline.vim'
" Add brackets etc. in pairs
Plug 'jiangmiao/auto-pairs'
" Color schemes!
Plug 'flazz/vim-colorschemes'

" Git configuration
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" File navigation/matching (TODO: learn to use fzf)
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'

" Specific file types
" LaTeX
Plug 'gibiansky/vim-latex-objects'
Plug 'lervag/vimtex'
let g:vimtex_view_method = 'skim'
" Rust
Plug 'rust-lang/rust.vim'
" Markdown
Plug 'plasticboy/vim-markdown' " Not sure this is needed??
" js/react files
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
" Python
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" Plug 'scrooloose/Syntastic'
" Plug 'vim-scripts/indentpython.vim'

" Worth looking into in the future with bandwidth:
" liuchengxu/vista.vim
" sheerun/vim-polyglot
" ycm-core/YouCompleteMe -> requires switching from vim to macvim??

" Older things I'm not bothering with now, based on low expected utility
" Open Computing languages (*.cl)??
" Plug 'petRUShka/vim-opencl'
" Haskell
" Plug 'Haskell-Conceal'
" Plug 'indenthaskell.vim'
" Plug 'lukerandall/haskellmode-vim'
" let g:haddock_browser='open'
call plug#end()

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

" Map the more common ctrl-/ to comment out a block in vim-commentary
map <C-/> gc

" Deal with non-zero history
set history=1000

" Set the look of vim
" set background=dark
colorscheme zenburn
let g:lightline = {'colorscheme': 'wombat'}
" Other  favorites:
"   dark: zenburn, PaperColor, OceanicNext, Monokai, wombat
"   light: sol-term, PaperColor (depends on background=dark/light)

" LaTeX things
" au BufRead,BufNewFile *.tex source ~/.vim/tex.vim

" Enable js/typescript highlighting in tsx files
au BufRead,BufNewFile *.tsx set syntax=javascript
" Frontend development
au BufNewFile,BufRead *.js, *.html, *.css, *.ts, *.tsx
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

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

" Virtualenv support for ycm
" py << EOF
" import os
" import sys
" if 'VIRTUAL_ENV' in os.environ:
"   project_base_dir = os.environ['VIRTUAL_ENV']
"   activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"   execfile(activate_this, dict(__file__=activate_this))
" EOF

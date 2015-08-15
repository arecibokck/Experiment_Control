syntax enable
set background=dark
colorscheme solarized
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set modelines=1
filetype plugin indent on
set autoindent
set number
set showcmd
set nocursorline
set wildmenu
set showmatch
set laststatus=2
set showtabline=2
"let g:jedi#force_py_version=3
let g:pymode_rope=0
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set encoding=utf-8
set t_Co=256
set guifont=Menlo\for\Powerline:h12
let g:Powerline_symbols='fancy'
autocmd VimEnter * NERDTree | wincmd p
execute pathogen#infect() 
autocmd filetype c nnoremap <F6> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype cpp nnoremap <F7> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
nmap <F8> :TagbarToggle<CR>
autocmd FileType python nnoremap <buffer> <F9> :exec '!Python' shellescape(@%, 1) <cr>
"autocmd FileType python call SetpythonOptions()
"function! SetpythonOptions()
"setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab makeprg=python-xdebug\ %
"    :call tagbar#autoopen(0)
"endfunction

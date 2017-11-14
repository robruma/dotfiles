set nocompatible
set expandtab
set smarttab
set autoindent
set smartindent
set shiftwidth=2
set softtabstop=2
set tabstop=2
set backspace=indent,eol,start
set spell spelllang=en_us
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
call pathogen#helptags()
syntax on
let g:solarized_termcolors=256
let g:solarized_termtrans=1
let g:solarized_visibility='high'
set background=dark
set laststatus=2
colorscheme solarized
filetype plugin indent on
let g:ale_completion_enabled=1
let g:airline#extensions#ale#enabled=1
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%l/%L
set statusline+=%{fugitive#statusline()}
set completeopt+=preview
let g:vebugger_leader='<C-d>'
map <F8> :VBGstepOver<CR>
map <F7> :VBGstepIn<CR>
map <S-F8> :VBGstepOut<CR>
map <F9> :VBGcontinue<CR>
map <C-F8> :VBGtoggleBreakpointThisLine<CR>
map <C-F8><C-F8> :VBGeval
vmap <C-F8><C-F8> :VBGevalSelectedText
let g:jedi#use_tabs_not_buffers=1
let g:go_highlight_functions=1
let g:go_highlight_methods=1
let g:go_highlight_fields=1
let g:go_highlight_types=1
let g:go_highlight_operators=1
let g:go_highlight_build_constraints=1
let g:go_version_warning=0
let g:vim_markdown_folding_disabled=1
hi Search cterm=NONE ctermfg=grey ctermbg=red
map <C-t> :Tab block<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-j> :%!python -m json.tool<CR>
map! <F2> <C-R>=strftime('%c')<CR>
if has("autocmd")
  autocmd BufRead,BufNewFile *.pp set filetype=puppet
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd BufReadPost Jenkinsfile set syntax=groovy
  autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
endif
silent !rm -rf ~/.vim/bundle/syntastic/ ~/.vim/bundle/vdebug/ ~/.vim/bundle/vim-javacomplete2/ > /dev/null 2>&1
silent !make -C ~/.vim/bundle/vimproc.vim/ > /dev/null 2>&1
silent !command -v pylint >/dev/null 2>&1 || { echo >&2 "Warning: pylint not installed"; }

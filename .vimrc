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
let g:syntastic_puppet_checkers=['puppet', 'puppetlint']
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%l/%L
set statusline+=%{fugitive#statusline()}
let g:syntastic_check_on_open=1
let g:syntastic_echo_current_error=1
let g:syntastic_enable_signs=1
let g:syntastic_auto_jump=1
let g:syntastic_auto_loc_list=1
let g:syntastic_loc_list_height=1
let g:go_highlight_functions=1
let g:go_highlight_methods=1
let g:go_highlight_fields=1
let g:go_highlight_types=1
let g:go_highlight_operators=1
let g:go_highlight_build_constraints=1
let g:go_version_warning=0
let g:vim_markdown_folding_disabled=1
"let g:syntastic_puppet_puppetlint_args='--fix'
"let g:syntastic_mode_map = { 'mode': 'active', 'active_filetypes': ['ruby', 'puppet'], 'passive_filetypes': [] }
hi Search cterm=NONE ctermfg=grey ctermbg=red
map <C-t> :Tab block<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-j> :%!python -m json.tool<CR>
map! <F2> <C-R>=strftime('%c')<CR>
"let g:syntastic_debug=17
if has("autocmd")
  autocmd BufRead,BufNewFile *.pp set filetype=puppet
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd FileType java setlocal omnifunc=javacomplete#Complete
  autocmd FileType java setlocal shiftwidth=4
  autocmd FileType java setlocal softtabstop=4
  autocmd FileType java setlocal tabstop=4
  autocmd BufReadPost Jenkinsfile set syntax=groovy
endif
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)
nmap <F5> <Plug>(JavaComplete-Imports-Add)
imap <F5> <Plug>(JavaComplete-Imports-Add)
nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)

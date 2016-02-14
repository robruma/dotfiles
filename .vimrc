set nocompatible
set expandtab
set smarttab
set autoindent
set smartindent
set shiftwidth=2
set softtabstop=2
set tabstop=2
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
"let g:syntastic_puppet_puppetlint_args='--fix'
"let g:syntastic_mode_map = { 'mode': 'active', 'active_filetypes': ['ruby', 'puppet'], 'passive_filetypes': [] }
hi Search cterm=NONE ctermfg=grey ctermbg=red
map t :Tab block<CR>
map j :%!python -m json.tool<CR>
"let g:syntastic_debug=17
if has("autocmd")
  autocmd BufRead,BufNewFile *.pp set filetype=puppet
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  "autocmd FileType python setlocal shiftwidth=4 tabstop=4
endif

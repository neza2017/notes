set nocompatible
set backspace=indent,eol,start
set nu
set updatetime=100

if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set expandtab
set tabstop=4
set shiftwidth=4

" Resize split 
noremap <S-J>  :res +5<CR>
noremap <S-K>    :res -5<CR>
noremap <S-H>  :vertical resize -5<CR>
noremap <S-L> :vertical resize +5<CR>

" set encoding
"set colorcolumn=110
"highlight ColorColumn ctermbg=darkgray
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" highlight search
set hlsearch
noremap <F8> :nohl<CR>
inoremap <F8> :nohl<CR>a

"copy to system clipboard
noremap <Leader>y  "+y
noremap <Leader>yy "+yy
noremap <Leader>p  "+p

"search select
vnoremap <c-f> y/\V<C-R>=escape(@",'/\')<CR><CR>
nnoremap <c-f> yiw/\V<C-R>=escape(@",'/\')<CR><CR>

call plug#begin('~/.vim/plugged')

"auto complete codes
Plug 'ycm-core/YouCompleteMe'

" Grammer
Plug 'w0rp/ale'

""" rst support
""Plug 'Rykka/riv.vim'
""Plug 'Rykka/InstantRst'
""
""" schema color
""Plug 'morhetz/gruvbox'
""
Plug 'preservim/nerdtree'
""
""" simplefold
""Plug 'tmhedberg/SimpylFold'
""
" Jump
Plug 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}
""
""Plug 'vim-airline/vim-airline'
""
""" Auto comment
""Plug 'preservim/nerdcommenter'
""
""" Powerful but charged o ^ o
""" Plug 'codota/tabnine-vim'
""
""" Git runtime
""Plug 'airblade/vim-gitgutter'
""Plug 'tpope/vim-fugitive'
""

" vim proc
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'shougo/vimshell.vim'

call plug#end()

" ale linter
let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_delay = 500
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20

let g:ale_echo_cursor = 1
let g:ale_completion_enabled = 1
let g:ale_sign_column_always = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:syntastic_python_flake8_args='--ignore=E501'
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'python': ['flake8'],
\   'zsh':['shell'],
\   'cpp':['clang-format'],
\   'go':['golangci-lint'],
\}

 let g:ale_fixers={
 \ 'cpp': ['clang-format'],
 \ 'go' : ['gofmt'],
 \ 'python': ['remove_trailing_lines', 'trim_whitespace'],
 \}

" YouCompleteMe
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings = 1
let g:ycm_global_ycm_extra_conf = '~/.ycm_c-c++_conf.py'
let g:ycm_semantic_triggers =  {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }
let g:ycm_filetype_whitelist = {
			\ "c":1,
			\ "cpp":1,
			\ "objc":1,
            \ "go":1,
            \ "python":1,
			\ "sh":1,
			\ "zsh":1,
            \ "cmake":1,
            \ "md":1,
            \ "vim":1,
			\ }
let g:ycm_auto_hover=""
map <c-g>  :YcmCompleter GoToDefinitionElseDeclaration<CR>
map <c-r>  :YcmCompleter GoToReferences<CR>
nmap <leader>d <plug>(YCMHover)

"noremap <c-n> :LeaderfMru<cr>


let g:Lf_ShowDevIcons = 0

"let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }

let g:Lf_ShortcutF = "<leader>ff"
noremap <leader>fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap <leader>fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
noremap <leader>ft :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>

"noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg --current-buffer -e %s ", expand("<cword>"))<CR>
"noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
" search visually selected text literally
"xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>
"noremap go :<C-U>Leaderf! rg --recall<CR>

" should use `Leaderf gtags --update` first
"let g:Lf_GtagsAutoGenerate = 1
"let g:Lf_Gtagslabel = 'native-pygments'
"noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
"noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
"noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
"noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>

nmap <F2> :NERDTreeToggle<cr>
nnoremap <space> :
vnoremap <space> :


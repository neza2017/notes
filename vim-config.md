# vim config

## 编译 vim 8.2
```bash
git clone https://github.com/vim/vim.git
cd vim
./configure --enable-python3interp --with-x --prefix=/usr/local
make -j
sudo make install
```
the output of `./src/vim --version` should looks like this, make `+python3` and  `+clipboard` is enabled
```txt
/src/vim --version
VIM - Vi IMproved 8.2 (2019 Dec 12, compiled Apr 26 2021 10:46:06)
Included patches: 1-2811
Compiled by cyf@cyf-laptop
Huge version without GUI.  Features included (+) or not (-):
+acl               -farsi             +mouse_sgr         +tag_binary
+arabic            +file_in_path      -mouse_sysmouse    -tag_old_static
+autocmd           +find_in_path      +mouse_urxvt       -tag_any_white
+autochdir         +float             +mouse_xterm       -tcl
-autoservername    +folding           +multi_byte        +termguicolors
-balloon_eval      -footer            +multi_lang        +terminal
+balloon_eval_term +fork()            -mzscheme          +terminfo
-browse            -gettext           +netbeans_intg     +termresponse
++builtin_terms    -hangul_input      +num64             +textobjects
+byte_offset       +iconv             +packages          +textprop
+channel           +insert_expand     +path_extra        +timers
+cindent           +ipv6              -perl              +title
+clientserver      +job               +persistent_undo   -toolbar
+clipboard         +jumplist          +popupwin          +user_commands
+cmdline_compl     +keymap            +postscript        +vartabs
+cmdline_hist      +lambda            +printer           +vertsplit
+cmdline_info      +langmap           +profile           +virtualedit
+comments          +libcall           -python            +visual
+conceal           +linebreak         +python3           +visualextra
+cryptv            +lispindent        +quickfix          +viminfo
+cscope            +listcmds          +reltime           +vreplace
+cursorbind        +localmap          +rightleft         +wildignore
+cursorshape       -lua               -ruby              +wildmenu
+dialog_con        +menu              +scrollbind        +windows
+diff              +mksession         +signs             +writebackup
+digraphs          +modify_fname      +smartindent       +X11
-dnd               +mouse             -sound             +xfontset
-ebcdic            -mouseshape        +spell             -xim
+emacs_tags        +mouse_dec         +startuptime       +xpm
+eval              -mouse_gpm         +statusline        +xsmp_interact
+ex_extra          -mouse_jsbterm     -sun_workshop      +xterm_clipboard
+extra_search      +mouse_netterm     +syntax            -xterm_save
   system vimrc file: "$VIM/vimrc"
     user vimrc file: "$HOME/.vimrc"
 2nd user vimrc file: "~/.vim/vimrc"
      user exrc file: "$HOME/.exrc"
       defaults file: "$VIMRUNTIME/defaults.vim"
  fall-back for $VIM: "/usr/local/share/vim"
Compilation: gcc -c -I. -Iproto -DHAVE_CONFIG_H -g -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 
Linking: gcc -L/usr/local/lib -Wl,--as-needed -o vim -lSM -lICE -lXpm -lXt -lX11 -lXdmcp -lSM -lICE -lm -ltinfo -ldl -L/usr/lib/python3.8/config-3.8-x86_64-linux-gnu -lpython3.8 -lcrypt -lpthread -ldl -lutil -lm -lm 
```

---

## 设置 vim 8.2 为默认
```bash
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/vim 40
```
查询 `vim` 相关的软链接
```bash
$ update-alternatives --query vim
Name: vim
Link: /usr/bin/vim
Status: auto
Best: /usr/local/bin/vim
Value: /usr/local/bin/vim

Alternative: /usr/bin/vim.basic
Priority: 30

Alternative: /usr/local/bin/vim
Priority: 40
```
设置默认 vim
```bash
$ sudo update-alternatives --config vim
There are 2 choices for the alternative vim (providing /usr/bin/vim).

  Selection    Path                Priority   Status
------------------------------------------------------------
* 0            /usr/local/bin/vim   40        auto mode
  1            /usr/bin/vim.basic   30        manual mode
  2            /usr/local/bin/vim   40        manual mode

Press <enter> to keep the current choice[*], or type selection number
```

---

## 安装 `Terminator`
```bash
sudo apt-get install terminator
```
`Terminator`常用快捷键盘
| 快捷键 | 含义 |
|-------|-----|
| ctrl+shift+o | 横向切分窗口 |
| ctrl+shift+e | 纵向切分窗口 |
| alt+方向键    | 在窗口间调整 |
| ctrl+shift+方向键 | 调整当前窗口大小 |
| ctrl+alt+上下方向键 | 在 ubuntu workspace 间切换 |

---

## vim 基础配置
```vim
set nocompatible
set backspace=indent,eol,start
set nu
set updatetime=100

syntax on

" 使用空格代替冒号
nnoremap <space> :
vnoremap <space> :

" 打开文件时自动定位到上次打开的位置
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set expandtab
set tabstop=4
set shiftwidth=4

" set encoding
set colorcolumn=110
highlight ColorColumn ctermbg=darkgray
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8

" split window
nnoremap <c-s> :split<CR>
nnoremap <c-l> :vsplit<CR>

" shift+方向键，调整 split windows 的大小 
noremap <S-Down>  :res +10<CR>
noremap <S-Up>    :res -10<CR>
noremap <S-Left>  :vertical resize -10<CR>
noremap <S-Right> :vertical resize +10<CR>

" Ctrl+方向键，在 split windows 间切换
nnoremap <C-Down> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>
nnoremap <C-Left> <C-W><C-H>

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
```

这个配置的常用快捷键如下
| 快捷键 | 含义 |
|-------|-----|
|ctrl+s | 横向分屏 |
|ctrl+l | 纵向分屏 |
|ctrl+方向键   | 在 split window 间切换 |
|shift+方向键  | 调整 split window 的大小 |
| `<Leader>`y | vim 中选择的内容拷贝到系统粘贴板 |
| `<Leader>`yy | vim 中当前的行拷贝到系统粘贴板 |
| `<Leader>p` | 从系统粘贴板中复制内容到 vim |
|ctrl+f | 全文查询选择的单词，按 `n` 跳转到下一个单词 |

**默认的 `<Leader>` 键为字符`\`**

---

## 安装`VIM`插件管理 [plug](https://github.com/junegunn/vim-plug)

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

---

## 使用 `vim-plug` 安装插件
`~/.vimrc` 的最后添加如下内容: 

```vim
call plug#begin('~/.vim/plugged')

"auto complete codes
Plug 'ycm-core/YouCompleteMe'

" Grammer
Plug 'w0rp/ale'

Plug 'preservim/nerdtree'

Plug 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension'}

call plug#end()
```
编译 `YouCompleteMe`
```bash
cd ~/.vim/plugged/YouCompleteMe
python3 install.py --clang-completer --go-completer
```

---

# 插件配置
`~/.vimrc` 中添加如下内容:
```vim
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
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
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
map <c-g>  :YcmCompleter GoToDefinitionElseDeclaration<CR>
map <c-r>  :YcmCompleter GoToReferences<CR>

" Leaderf
let g:Lf_WindowPosition = 'popup'
let g:Lf_ShowDevIcons = 0
let g:Lf_PreviewInPopup = 1

noremap  <c-n>  :Leaderf mru<cr>

" NERDTree
nmap <F2> :NERDTreeToggle<cr>

```

这个配置的常用快捷键如下
| 快捷键 | 含义 |
|-------|-----|
|`<Leader>f` | 模糊搜索文件 |
|ctrl+n | 最近编辑过的文件
|`<F2>` | 打开或关闭 `NERDTree` |
|ctrl+g | 调整到函数定义 |
|ctrl+r | 查找所有引用 |
|ctrl+o | 回到跳转前的位置 |

在 `<Leaderf>` 的搜索文件的过程中，可以使用 `Tab` 在输入文件名查找合使用方向键查找间快速切换

## ycm_c_c++_conf.py
```python

import os
import ycm_core

flags = [
  '-Wall',
  '-Wextra',
  '-Werror',
  '-Wno-long-long',
  '-Wno-variadic-macros',
  '-fexceptions',
  '-ferror-limit=10000',
  '-DNDEBUG',
  '-std=c99',
  '-xc',
  '-isystem/usr/include/',
  ]

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', ]

def FlagsForFile( filename, **kwargs ):
  return {
  'flags': flags,
  'do_cache': True
  }

```

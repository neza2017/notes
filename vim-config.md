# vim config

## 编译 vim 8.2
```bash
git clone https://github.com/vim/vim.git
cd vim
./configure --enable-python3interp --with-x
make -j
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

## 设置 vim 8.2 为默认
```bash
sudo cp ./src/vim /usr/local/bin/
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

## vim 基础配置
```vim
set nocompatible
set nu
set updatetime=100

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
nnoremap <c-v> :vsplit<CR>

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
```

这个配置的常用快捷键如下
| 快捷键 | 含义 |
|-------|-----|
|ctrl+s | 横向分屏 |
|ctrl+v | 纵向分屏 |
|ctrl+方向键   | 在 split window 间切换 |
|shift+方向键  | 调整 split window 的大小 |




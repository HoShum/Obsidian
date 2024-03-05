"let mapleader=" "

"回到普通模式
inoremap jk <Esc>
vnoremap jk <Esc>
"普通模式快速移动光标"
nnoremap J 5j
nnoremap K 5k
nnoremap W 5w
nnoremap B 5b
nnoremap <C-h> ^
nnoremap <C-l> $
"插入模式快速移动光C
inoremap <C-h> <ESC>^i
inoremap <C-l> <ESC>$a
"显示模式快速移动光标
vnoremap <C-n> 5j
vnoremap <C-p> 5k
"普通模式进入显示模式
nnoremap vv viw
nnoremap vk v$
nnoremap vj v^


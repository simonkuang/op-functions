set nocompatible
"source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin

if has("mswin")
    set diffexpr=MyDiff()
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction
endif

highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue

" set font
"set guifont=YaHei\ Consolas\ Hybrid\ 12
"set guifontwide=YaHei\ Consolas\ Hybrid\ 12
set guifont=Consolas:w6:h10.3
set guifontwide="Microsoft Yahei":w6:h10.3
set fileformat=unix

" set color scheme
if ! has("gui_running")
    set t_Co=256
endif

"colors peaksea
"colors oceandeep
"colorscheme lucius
colorscheme molokai
"let g:molokai_original = 1

" feel free to choose :set background=light for a different style
set background=dark
set hlsearch

set nobackup
set nowritebackup

" 记住上次代开位置
autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" |
            \ endif

syntax on

set backspace=2
set ruler
set showmatch
set showmode

set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab

" expand tab to spaces
set expandtab

set autoindent
set smartindent
set cindent
set cinoptions=:0,g0,t0,(0,Ws,m1

set hlsearch
set incsearch
set smartcase
compiler gcc

set textwidth=80

"highlight rightMargin ctermfg=lightblue
"match rightMargin /.\%>79v/
set colorcolumn=80

" ctags
set tags=tags;
set autochdir

" status line
set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P

set number
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

" jump to previous building error
map <F3> :cp<CR>

" jump to next building error
map <F4> :cn<CR>

" run make command
map <F5> :make<CR>

" run make clean command
map <F6> :make -s clean<CR>

" alt .h .cpp
map <F7> :A<CR>

nnoremap <silent> <F8> :TlistToggle<CR>
map <F10> :NERDTreeToggle<CR>
imap <F10> <ESC> :NERDTreeToggle<CR>

" F11 toggle paste mode
set pastetoggle=<F11>

" F12 Grep
nnoremap <silent> <F12> :Grep<CR>

" remove trailing spaces
function! RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0'
        normal m`
        silent! :%s/\s\+$//e
        normal ``
    endif
endfunction

" apply gnu indent rule for system headers
"function! GnuIndent()
"    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
"    setlocal shiftwidth=2
"    setlocal tabstop=8
"endfunction

" fix inconsist line ending
function! FixInconsistFileFormat()
    if &fileformat == 'unix'
        silent! :%s/\r$//e
    endif
endfunction

" custom indent: no namespace indent, fix template indent errors
function! CppNoNamespaceAndTemplateIndent()
    let l:cline_num = line('.')
    let l:cline = getline(l:cline_num)
    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
        let l:pline_num = prevnonblank(l:pline_num - 1)
        let l:pline = getline(l:pline_num)
    endwhile
    let l:retv = cindent('.')
    let l:pindent = indent(l:pline_num)
    if l:pline =~# '^\s*template\s*<\s*$'
        let l:retv = l:pindent + &shiftwidth
    elseif l:pline =~# '^\s*template\s*<.*>\s*$'
        let l:retv = l:pindent
    elseif l:pline =~# '\s*typename\s*.*,\s*$'
        let l:retv = l:pindent
    elseif l:pline =~# '\s*typename\s*.*>\s*$'
        let l:retv = l:pindent - &shiftwidth
    elseif l:cline =~# '^\s*>\s*$'
        let l:retv = l:pindent - &shiftwidth
    elseif l:pline =~# '^\s*namespace.*'
        let l:retv = 0
    endif
    return l:retv
endfunction
autocmd FileType cpp setlocal indentexpr=CppNoNamespaceAndTemplateIndent()

filetype plugin indent on

augroup filetype
    autocmd! BufRead,BufNewFile *.proto set filetype=proto
    autocmd! BufRead,BufNewFile *.thrift set filetype=thrift
    autocmd! BufRead,BufNewFile *.pump set filetype=pump
    autocmd! BufRead,BufNewFile BUILD set filetype=blade
augroup end

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
            \ if line("'\"") > 0 && line ("'\"") <= line("$") |
            \ exe "normal g'\"" |
            \ endif

autocmd BufEnter /usr/include/c++/* setfiletype cpp
autocmd BufEnter /usr/include/* call GnuIndent()
autocmd BufWritePre * call RemoveTrailingSpace()
autocmd BufWritePre * call FixInconsistFileFormat()
autocmd BufEnter *
            \ if &filetype == 'make' |
            \   colorscheme murphy |
            \ else |
            \   colorscheme molokai|
            \ endif

function SetLogHighLight()
    highlight LogFatal ctermbg=red guifg=red
    highlight LogError ctermfg=red guifg=red
    highlight LogWarning ctermfg=yellow guifg=yellow
    highlight LogInfo ctermfg=green guifg=green
    syntax match LogFatal "^F\d\+ .*$"
    syntax match LogError "^E\d\+ .*$"
    syntax match LogWarning "^W\d\+ .*$"
    " syntax match LogInfo "^I\d\+ .*$"
endfunction

autocmd BufEnter *.{log,INFO,WARNING,ERROR,FATAL} call SetLogHighLight()

"autocmd BufEnter *.log match DiffAdd '\%>1024v.*'

" auto insert gtest header inclusion for test source file
autocmd BufNewFile *_test.{cpp,cxx,cc} :normal i#include "gtest/gtest.h"

" locate project dir by BLADE_ROOT file
functio! FindProjectRootDir()
    let rootfile = findfile("BLADE_ROOT", ".;")
    " in project root dir
    if rootfile == "BLADE_ROOT"
        return ""
    endif
    return substitute(rootfile, "/BLADE_ROOT$", "", "")
endfunction

" auto insert gtest header inclusion for test source file
function! s:InsertHeaderGuard()
    let fullname = expand("%:p")
    let rootdir = FindProjectRootDir()
    if rootdir != ""
        let path = substitute(fullname, "^" . rootdir . "/", "", "")
    else
        let path = expand("%")
    endif
    let varname = toupper(substitute(path, "[^a-zA-Z0-9]", "_", "g"))
    exec 'norm O#ifndef ' . varname
    exec 'norm o#define ' . varname
    exec 'norm o#pragma once'
    exec '$norm o#endif // ' . varname
endfunction

autocmd BufNewFile *.{h,hpp} call <SID>InsertHeaderGuard()

"autocmd FileType python set complete+=k~/.vim/syntax/python.vim isk+=.,(

" auto encoding detecting
set fileencodings=ucs-bom,utf-8-bom,utf-8,cp936,gb18030,ucs,big5
let g:fencview_autodetect = 1

" set term encoding according to system locale
"let &termencoding = substitute($LANG, "[a-zA-Z_-]*\.", "", "")

" support gnu syntaxt
let c_gnu = 1

" show error for mixed tab-space
let c_space_errors = 1
"let c_no_tab_space_error = 1

" don't show gcc statement expression ({x, y;}) as error
let c_no_curly_error = 1

" hilight extra spaces at end of line
syn match Error '\s\+$'

" show tab as --->
" show trailing space as -
set listchars=tab:>-,trail:-
"set listchars=trail:-
set list

function! Blade(...)
    let l:old_makeprg = &makeprg
    setlocal makeprg=blade
    execute "make" . join(a:000)
    let &makeprg=old_makeprg
endfunction

command! -nargs=* Blade call Blade('<args>')

" taglist
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

" winmanager
let g:winManagerWindowLayout='FileExplorer|TagList'
nmap mm :WMToggle<cr>

" minibuffer
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1

" neocomplcache
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
   \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <expr><CR>  (pumvisible() ? "\<C-y>":'') . "\<C-f>\<CR>X\<BS>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><C-h> pumvisible() ? neocomplcache#close_popup()."\<C-h>" : "\<C-h>"
" inoremap <expr><BS> pumvisible() ? neocomplcache#close_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1
"inoremap <expr><CR>  (pumvisible() ? "\<C-e>":'') . (&indentexpr != '' ? "\<C-f>\<CR>X\<BS>":"\<CR>")
"inoremap <expr><C-h> pumvisible() ? neocomplcache#cancel_popup()."\<C-h>" : "\<C-h>"
"inoremap <expr><BS> pumvisible() ? neocomplcache#cancel_popup()."\<C-h>" : "\<C-h>"

" Enable omni completion.
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
"if !exists('g:neocomplcache_omni_patterns')
"    let g:neocomplcache_omni_patterns = {}
"endif
"let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
"let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

" full screen for gvim
if has('gui_running') && has('win32')
  map <F11> :call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
  imap <F11> :call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
  au GUIEnter * simalt ~x
endif

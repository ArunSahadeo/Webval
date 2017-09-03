" ============================================================================
" File:        webval.vim
" Description: HTML and CSS validation using the W3C Validator API
" Maintainer:  Arun Sahadeo <arunjamessahadeo@gmail.com>
" License:     GPLv2+ -- look it up.
" Notes:       Requires vim-rest-console as a dependency.
"
" ============================================================================

if exists('g:loaded_webval') || &cp
    finish
endif

let g:loaded_webval = 1

" Section: CSS validate method

function! CSS_Val(css)
    if &ft != "css"
        return
    endif
    echo "This is a CSS file"
endfunction

" Section: HTML validate method

function! HTML_Val(html)
    if &ft != "html"
        return
    endif
    echo "This is a HTML file"
endfunction

let fileType = &ft

command ValiCSS call CSS_Val(fileType)
command ValiHTML call HTML_Val(fileType)

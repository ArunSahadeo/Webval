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

function! CSS_Val(css, file)
    let file = a:file
    if &ft != "css"
        return
    endif
    echo "The filename is " . file
endfunction

" Section: HTML validate method

function! HTML_Val(html, file)
    let validFTs = ["html", "php"]
    let file = a:file
    if index(validFTs, &ft) == -1
        return
    endif
    echo "The filename is " . file
endfunction

let fileType = &ft
let fileName = expand('%:t')

command ValiCSS call CSS_Val(fileType, fileName)
command ValiHTML call HTML_Val(fileType, fileName)

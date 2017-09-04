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

" Section: Find PHP site

function! FindPHPSite(php)
    let PHPSites = systemlist("cat /etc/hosts | awk '!/adobe/ && /127.0.0.1/' | awk '{print $2}'")
    let file = a:php
    echo PHPSites
    " Get status code from site
    let statusCode = {}
    for PHPSite in PHPSites
        let statusCode = execute "! curl -I " . PHPSite . "/" . file . " | head -1 | grep -P '\d{3}'"
        if statusCode != 404
            echo PHPSite
        break
    endfor
endfunction

" Section: CSS validate method

function! CSS_Val(css, file)
    let file = a:file
    if &ft != "css"
        return
    endif
    if has('macunix')
        execute '! bash -c "cat ' . file . ' | pbcopy "'
    else
        execute '! bash -c "cat ' . file . ' | xclip "'
    endif
endfunction

" Section: HTML validate method

function! HTML_Val(html, file)
    let validFTs = ["html", "htm", "php"]
    let file = a:file
    if index(validFTs, &ft) == -1
        return
    endif
    "if &ft == "php"
    "    FindPHPSite()
    "endif
    execute '!open ' . file
endfunction

let fileType = &ft
let fileName = expand('%:t')

command ValiCSS call CSS_Val(fileType, fileName)
command ValiHTML call HTML_Val(fileType, fileName)
command ValiPHP call FindPHPSite(fileName)

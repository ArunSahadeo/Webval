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
    " Get status code from site
    for PHPSite in PHPSites
        let statusCode = system('curl -sI ' . PHPSite . '/' . file . ' | head -1 | grep -oP "\d{3}"')
        if statusCode != 200
            continue
        else
            return PHPSite
        break
        endif
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
    if &ft == "php"
        let LAMPSite = FindPHPSite(file)
        let BaseName = system("basename " . file . " .php")
        system("wget -O " . BaseName . ".html " . LAMPSite . "/" . file)
        let fileContents = ""
        if has('macunix')
            let fileContents = system("cat " . BaseName . ".html | pbcopy && rm " . BaseName . ".html")
        elseif has('unix')
            let fileContents = system("cat " . BaseName . ".html | xclip && rm " . BaseName . ".html")
        endif
        let s:htmlFile = fileContents 
    endif
    if has('macunix')
        execute "!pbpaste > " . BaseName. ".html"
    elseif has('unix')
        execute "!pbpaste > " . BaseName. ".html"
    endif
endfunction

let fileType = &ft
let fileName = expand('%:t')

command ValiCSS call CSS_Val(fileType, fileName)
command ValiHTML call HTML_Val(fileType, fileName)

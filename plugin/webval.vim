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
        elseif statusCode == 200
            return PHPSite
        else
            continue
        endif
    endfor
endfunction

" Section: CSS validate method

function! CSS_Val(file)
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

function! HTML_Val(file, basename)
    let validFTs = ["html", "htm", "php"]
    let file = a:file
    let BaseName = a:basename
    if index(validFTs, &ft) == -1
        return
    endif
    if &ft == "php"
        let LAMPSite = FindPHPSite(file)
        execute "!wget -O ". BaseName . ".html " . LAMPSite . "/". file
    endif
    execute '!curl -H "Content-Type: text/html; charset=utf-8" --data-binary @' . BaseName . '.html "https://validator.w3.org/nu/?out=json" > ' . BaseName . '.json'
    let HTMLErrors = systemlist("jq '.messages[] | select( .type | startswith(\"error\"))|.message' < " . BaseName . ".json")
    let HTMLErrorLines = systemlist("jq '.messages[] | select( .type | startswith(\"error\"))|.lastLine'" . BaseName . ".json")
    echo HTMLErrors
    "echo HTMLErrorLines
endfunction

let fileName = expand('%:t')
let BaseName = expand('%:r')

command ValiCSS call CSS_Val(fileName)
command ValiHTML call HTML_Val(fileName, BaseName)

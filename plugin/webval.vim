" ============================================================================
" File:        webval.vim
" Description: HTML and CSS validation using the W3C Validator API
" Maintainer:  Arun Sahadeo <arunjamessahadeo@gmail.com>
" License:     GPLv2+ -- look it up.
" Notes:       Requires jq to be installed and available on your $PATH
"
" ============================================================================

if exists('g:loaded_webval') || &cp
    finish
endif

let g:loaded_webval = 1

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

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

function! CSS_Val(file, basename)
    let file = a:file
    let basename = a:basename
    if &ft != "css"
        return
    endif
    execute "!curl -sF \"file=@" . file . "; type=text/css\" -F output=json warning=0 profile=css3 \"https://jigsaw.w3.org/css-validator/validator\" > " . basename . ".json"
    let CSSErrors = systemlist("jq '.cssvalidation.errors[] | .message' < " . basename . ".json")
    let CSSErrorLines = systemlist("jq '.cssvalidation.errors[] | .line' < " . basename . ".json")
    let counter = 0
     if len(CSSErrors) > 0
         for CSSError in CSSErrors
             echoerr "Found on line " . CSSErrorLines[counter] . " " . CSSError
             let counter += 1
         endfor
     endif
endfunction

" Section: HTML validate method

function! HTML_Val(file, basename)
    let validFTs = ["html", "htm", "xhtml", "php"]
    let file = a:file
    let BaseName = a:basename
    let LAMPSite = ""
    if index(validFTs, &ft) == -1
        return
    endif
    if &ft == "php"
        let commonBaseNames = ["index", "contact"] 
        let currentPath = getcwd()
        let pathComponent = ""
        if match(currentPath, "wp-content") != -1
            echoerr "Sorry, we do not support Wordpress"
            return
        endif
        
        if index(commonBaseNames, BaseName) != -1
            let serverAlias = system("./vhost-find.sh | tail -n1")
            let LAMPSite = "http://" . serverAlias 
        else
            let LAMPSite = FindPHPSite(file)
        endif

        if len(LAMPSite) > 0
            execute "!wget -O " . BaseName . ".html " . LAMPSite . "/" . file
        else
            return
        endif
    endif
    execute '!curl -H "Content-Type: text/html; charset=utf-8" --data-binary @' . BaseName . '.html "https://validator.w3.org/nu/?out=json" > ' . BaseName . '.json'
    let HTMLErrors = systemlist("jq '.messages[] | select( .type | startswith(\"error\"))|.message' < " . BaseName . ".json")
    let HTMLErrorLines = systemlist("jq '.messages[] | select( .type | startswith(\"error\"))|.lastLine' < " . BaseName . ".json")
    let counter = 0
     if len(HTMLErrors) > 0
         for HTMLError in HTMLErrors
             echoerr "Found on line " . HTMLErrorLines[counter] . " " . HTMLError
             let counter += 1
         endfor
     else
         echom "You have no errors."
     endif
endfunction

let fileName = expand('%:t')
let BaseName = expand('%:r')

command ValiCSS call CSS_Val(fileName, BaseName)
command ValiHTML call HTML_Val(fileName, BaseName)

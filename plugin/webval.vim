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
    let LAMPSite = ""
    if index(validFTs, &ft) == -1
        return
    endif
    if &ft == "php"
        let commonPHPFiles = ["index.php", "header.php", "footer.php", "contact.php"]
        let currentPath = getcwd()
        if match(currentPath, "wp-content") != -1
            echoerr "Sorry, we do not support Wordpress"
            return
        endif
        let pathComponent = ""
        if index(commonPHPFiles, file) != -1
            let currentPath = getcwd()
            echo currentPath
            let projectRoot = ""
            let containingFolder = system("basename $(pwd)")
            let isProjectRoot = system("bash -c '[ -f " . currentPath . "/index.php ] && echo \"true\" || echo \"false\" | xargs'")
            if match(isProjectRoot, "true") == -1
                let projectRoot = system("bash -c 'findRoot=`[ -f index.php ] && echo \"true\" || echo \"false\"; while [ $findRoot == \"false\" ]; do cd .. if [ -f index.php ]; then echo $(pwd); break; fi; if [ $(pwd) == \"/\" ]; then break; fi;  done' ")
                if match(projectRoot, "wp-content") != -1
                    echoerr "Sorry, this plugin is not compatible with WordPress"
                    return
                endif
                let pathToFile = system("find " . projectRoot . " -type d -name '" . containingFolder . "'") 
                let pathComponent = system("echo " . pathToFile . " | cut -d '.' -f 2")
            else
                let projectRoot = currentPath
            endif
        else
            let LAMPSite = FindPHPSite(file)
        endif
        if len(LAMPSite) > 0
            execute "!wget -O ". BaseName . ".html " . LAMPSite . "/". file
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
     endif
endfunction

let fileName = expand('%:t')
let BaseName = expand('%:r')

command ValiCSS call CSS_Val(fileName)
command ValiHTML call HTML_Val(fileName, BaseName)

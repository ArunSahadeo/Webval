if !exists('g:webval_vhosts_dir')
    if isdirectory('/etc/apache2/sites-enabled/')
        let g:webval_vhosts_dir = '/etc/apache2/sites-enabled/'
    elseif isdirectory('/etc/nginx/sites-enabled/')
        let g:webval_vhosts_dir = '/etc/nginx/sites-enabled/'
    endif
endif

#!/usr/bin/env bash

for file in /etc/apache2/sites-enabled/*.conf; do
    printf "%s" "$(<${file})"
    if grep '/var/www/sample-lamp-site' "$file"; then
        serverAlias=`sed -n '/ServerAlias /p' "$file"`
        echo $serverAlias | cut -d " " -f2 
        break
    fi
done

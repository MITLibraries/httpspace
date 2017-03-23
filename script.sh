#!/bin/bash

# This will want to:
# get a community via packager and feed it to ruby
# get collections via that output
# get items via that output
# zip and restore/replace the items
# Actually I probably want to do this all in ruby: http://stackoverflow.com/questions/2232/calling-shell-commands-from-ruby
# Yes in fact: system calls are super easy - https://gist.github.com/JosephPecoraro/4069

cd files

for zip in *.zip
do
  dirname=`echo $zip | sed 's/\.zip$//'`
  if mkdir "$dirname"
  then
    if cd "$dirname"
    then
      unzip ../"$zip"
      cd ..
      # rm -f $zip # Uncomment to delete the original zip file
    else
      echo "Could not unpack $zip - cd failed"
    fi
  else
    echo "Could not unpack $zip - mkdir failed"
  fi
done

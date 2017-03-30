#!/bin/bash

# This expects to be invoked as `./import_items /directory/with/your/zip/files/`.

if [ -e restore_errors.txt ] ; then
  rm restore_errors.txt
fi
touch restore_errors.txt

if [ -e successful_imports.txt ] ; then
  rm successful_imports.txt
fi
touch successful_imports.txt

for file in "$1"*.zip; do
  if /home/dspace/dspace.mit.edu/bin/dspace packager -u -r -f -t AIP -e m31@mit.edu $file ; then
  echo "$file" restored
  echo "$file" >> successful_imports.txt
else
  echo "$file" >> restore_errors.txt
fi
done

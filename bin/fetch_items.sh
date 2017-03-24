#!/bin/bash

# This expects to be invoked as `./fetch_items < file_with_one_handle_per_line.txt`.
# It will either fetch the item package or, if it fails, write the bad handle
# to errors.txt to allow for manual follow-up.

if [ -e fetch_errors.txt ] ; then
  rm fetch_errors.txt
fi
touch fetch_errors.txt

while read line; do
  if /home/dspace/dspace.mit.edu/bin/dspace packager -d -t METS -e m31@mit.edu -i "$line" "$line".zip ; then
    echo "$line" gotten
  else
    echo "$line" >> fetch_errors.txt
  fi
done

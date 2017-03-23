#!/bin/sh

# This expects to be invoked as `./fetch_items < file_with_one_handle_per_line.txt`.
# It will either fetch the item package or, if it fails, write the bad handle
# to errors.txt to allow for manual follow-up.

if [ -e errors.txt ] ; then
  rm errors.txt
fi
touch errors.txt

while read line; do
  if /home/dspace/dspace.mit.edu/bin/dspace packager -d -t METS -e m31@mit.edu -i "$line" "$line".zip ; then
    echo "$line" gotten
  else
    echo "$line" >> errors.txt
  fi
done

#!/bin/bash

# This expects to be invoked as `./import_metadata /directory/with/your/provenance/files/`.

if [ -e metadata_errors.txt ] ; then
  rm metadata_errors.txt
fi
touch restore_errors.txt

if [ -e metadata_successes.txt ] ; then
  rm metadata_successes.txt
fi
touch metadata_successes.txt

for file in "$1"*.csv; do
  if yes | /home/dspace/dspace.mit.edu/bin/dspace metadata-import -f $file -e m31@mit.edu ; then
  echo "$file" metadata restored
  echo "$file" >> metadata_successes.txt
else
  echo "$file" >> metadata_errors.txt
fi
done

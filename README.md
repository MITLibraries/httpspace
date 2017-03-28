# README.md

These files let us fetch all the OpenCourseWare DSpace packages; update their
http://ocw.mit.edu URLs to https; and replace them.

We can't do it as a continuous process, because the dspace and bash commands
need to run on the servers, but the servers don't have ruby. So here are the
steps:

* [on dspace] Get the OCW collection as a CSV file:
  * `sudo su - dspace`; `/home/dspace/dspace.mit.edu/bin/dspace metadata-export -f test.csv -i $handle -a`
  * $handle = 1721.1/33971 on dspace-test
* [on local] scp that csv file to the dev machine
* HttpSpace::get_handles(csvfile)
* HttpSpace::initialize_provenance(csvfile)
* scp the newly generated file of handles (item_handles.txt) back to the server
* [on dspace] Fetch all items with those handles: ./bin/fetch_items.sh < item_handles.txt
  * This will be over a thousand items. Check first to ensure you have enough free disk space on both machines.
* [on local] scp the item files from server to dev
* HttpSpace::process_items(directory)

  HEY YOU TEST PROVENANCE BEFORE CONTINUING
* scp new item files from dev to server
* [on dspace] Import all your new files:
  * ./import_items /directory/with/your/zip/files/

## Troubleshooting

Make sure permissions are set right on the server. (In particular, you're scping as yourself but operating commands as dspace.)

## to do
- provenance does not write automatically; you need to
  - Problems:
    - The ID is not the handle, nor is it in the file, nor is it the filename
    - You may have broken one of them with the import
    - You can import provenance according to the command line, BUT it discards
      previous provenance records
  --> Therefore:
    you need to actually edit an existing provenance.csv file as you go
    whee
    you need to export that metadata file WITH PROVENANCE
- HttpSpace should catch errors in file IO, write them, and continue

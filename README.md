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
* scp files/new* and provenance_*.csv from dev to server
* [on dspace] Import all your new files:
  * `./import_items /directory/with/your/zip/files/`
* Import new metadata:
  * `./import_metadata /directory/with/your/provenance/files/`

## Troubleshooting

Make sure permissions are set right on the server. (In particular, you're scping as yourself but operating commands as dspace.)

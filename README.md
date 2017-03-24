# README.md

These files let us fetch all the OpenCourseWare DSpace packages; update their
http://ocw.mit.edu URLs to https; and replace them.

We can't do it as a continuous process, because the dspace and bash commands
need to run on the servers, but the servers don't have ruby. So here are the
steps:

* Get the OCW collection as a CSV file:
  * /home/dspace/dspace.mit.edu/bin/dspace metadata-export -f test.csv -i $handle
  * $handle = 1721.1/33971 on dspace-test
* scp that csv file to the dev machine
* HttpSpace::get_handles(csvfile)
* scp the newly generated file of handles (item_handles.txt) back to the server
* Fetch all items with those handles: ./bin/fetch_items.sh << item_handles.txt
  * This will be over a thousand items. Check first to ensure you have enough free disk space on both machines.
* scp the item files from server to dev
* HttpSpace::process_items(directory)
* scp new item files from dev to server
* Import all your new files:
  * ./import_items /directory/with/your/zip/files/

## Troubleshooting

Make sure permissions are set right on the server. (In particular, you're scping as yourself but operating commands as dspace.)

## to do
- provenance does not write automatically; you need to
- track which ones you actually change and only update those

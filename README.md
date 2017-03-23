# README.md

These files let us fetch all the OpenCourseWare DSpace packages; update their
http://ocw.mit.edu URLs to https; and replace them.

We can't do it as a continuous process, because the dspace and bash commands
need to run on the servers, but the servers don't have ruby. So here are the
steps:

* Get the OCW collection as a CSV file: /home/dspace/dspace.mit.edu/bin/dspace metadata-export -f test.csv -i $handle
  * $handle = 1721.1/33971 on dspace-test
* scp that csv file to the dev machine
* Parse out handles (ruby)
* scp the newly generated file of handles (item_handles.txt) back to the server
* Fetch all items with those handles: ./bin/fetch_items.sh << item_handles.txt
* scp the item files from server to dev
* traverse, replace, edit mets, zip up
* scp new item files from dev to server
# use bash and packager to import all files in a directory
  - is it a problem that the filename ends up being changed?
  - [dspace]/bin/dspace packager -r -f -t AIP -e <eperson> <AIP-file-path>
  - see if you can run it in noninteractive mode, or else autosupply the y<enter> when it prompts
  - provenance does not write automatically; you need to

## Troubleshooting

Make sure permissions are set right on the server. (In particular, you're scping as yourself but operating commands as dspace.)

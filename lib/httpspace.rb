require_relative "traversal"
require_relative "replacer"

#traversal = Traversal.new
#traversal.traverse

#replacer = Replacer.new
#replacer.update(traversal.candidates)

# Given a community handle....
# => Get the community
# => Unzip it
# =>  Parse its mets.xml to find its collection handles
# =>  For each collection handle...
#     => Get the collection
#     => Unzip it
#     => Parse its mets.xml to find its constituent item handles
#     => For each item handle...
#        => Get the item
#        => Unzip it
#        => Traverse it to find relevant files
#        => Replace their contents as needed
#        => Parse its mets.xml to find bitstreams with changed checksums
#        => Update the checksums
#        => Rezip it
#        => Restore/replace the item
#        => Delete now unneeded item directory and zip file
#     => Delete now unneeded collection directory and zip file
# => Delete now unneeded community directory and zip file

# Responsibilities of lib/*.rb files:
#   * traversal: find files which are candidates for being updated
#   * replacer: replace their http://ocw.mit.edu URLs with https URLs
#   * mets: parse and update mets files
#   * packager: interact with the DSpace packager command
#   * httpspace (this file): run the whole process

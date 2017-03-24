#!/usr/bin/ruby
require "CSV"
require "fileutils"
require_relative "mets"
require_relative "replacer"
require_relative "traversal"

##
# HttpSpace provides methods to govern the for the overall export/update/import
# process.
#
# These are the methods that should be exposed to bash scripts. HttpSpace calls
# out to other modules in order to perform the actual work.
module HttpSpace
  class << self
    ##
    # Given a CSV file of OCW collection metadata, records the item handles.
    def get_handles(csvfile)
      mycsv = CSV.read(csvfile, :headers=>true)
      handle_uris = mycsv['dc.identifier.uri']
      handles = handle_uris.reject { |x| x.nil? }.map { |x| x.sub('http://hdl.handle.net/', '') }
      File.open("item_handles.txt", "w") { |f|
        handles.each { |handle| f.puts(handle) }
      }
    end

    ##
    # Given a directory containing zipped OCW item files:
    # * unzips each file
    # * finds and replaces http://ocw.mit.edu links with https
    # * rezips the file
    # * deletes the temporary unzipped files
    def process_items(dirname)
      tempdir = File.join(dirname, 'temp')
      FileUtils.mkdir_p tempdir
      system("rm #{tempdir}/*")

      @replacer = Replacer.new

      Dir.glob("#{dirname}/*.zip") do |zipfile|
        system("unzip #{zipfile} -d #{tempdir}")
        Traversal.traverse(tempdir)
        @replacer.update(Traversal.candidates)
        metsfile = File.join(tempdir, 'mets.xml')
        if !File.exist?(metsfile)
          raise "No mets.xml in #{tempdir}"
        end
        METS.update_metadata(metsfile)
        thedir, thefile = File.split(zipfile)

        # Note that the file extension .zip is already included in thefile.
        system("zip -j #{thedir}/new_#{thefile} #{tempdir}/*")
        system("rm #{tempdir}/*")
      end
    end
  end

end

# Responsibilities of lib/*.rb files:
#   * traversal: find files which are candidates for being updated
#   * replacer: replace their http://ocw.mit.edu URLs with https URLs
#   * mets: parse and update mets files
#   * httpspace (this file): run the whole process

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
    # * rezips the file, if there were any changes
    # * deletes the temporary unzipped files
    def process_items(dirname)
      @tempdir = File.join(dirname, 'temp')
      FileUtils.mkdir_p @tempdir

      @csv_index = -1

      Dir.glob("#{dirname}/*.zip") do |zipfile|
        system("rm #{@tempdir}/*")

        system("unzip #{zipfile} -d #{@tempdir}")
        Traversal.traverse(@tempdir)
        Replacer.update(Traversal.candidates)

        handle_metsfile
        clean_up(zipfile)

        @csv_index += 1
        if @csv_index % 100 == 0
          start_csv
        end
        write_csv(METS.item_id, METS.provenance)
      end
    end

    private

      ##
      # Starts a CSV file to record new provenance metadata.
      def start_csv
        project_dir = File.dirname(File.dirname(__FILE__))
        @current_csv = File.join(project_dir, "provenance_#{@csv_index}.csv")
        system("touch #{@current_csv}")
        CSV.open(@current_csv, "wb") do |csv|
          csv << ["id", "dc.description.provenance[en]"]
        end
      end

      def write_csv(id, provenance)
        CSV.open(@current_csv, "a") do |csv|
          csv << ["#{id}", "#{provenance}"]
        end
      end

      ##
      # Zips the working files into a new archive if there were any changes and
      # then deletes the working files.
      def clean_up(zipfile)
        # We're only going to rezip the file if we've replaced links. This
        # will let us import *.zip back into dspace later without any wasted
        # effort.
        if Replacer.links_processed > 0
          thedir, thefile = File.split(zipfile)

          # Note that the file extension .zip is already included in thefile.
          system("zip -j #{thedir}/new_#{thefile} #{@tempdir}/*")
        end
        system("rm #{@tempdir}/*")
      end

      ##
      # Updates item metadata (or dies if it can't find any).
      def handle_metsfile
        metsfile = File.join(@tempdir, 'mets.xml')
        if !File.exist?(metsfile)
          raise "No mets.xml in #{@tempdir}"
        end

        METS.update_metadata(metsfile)
      end
  end

end

# Responsibilities of lib/*.rb files:
#   * traversal: find files which are candidates for being updated
#   * replacer: replace their http://ocw.mit.edu URLs with https URLs
#   * mets: parse and update mets files
#   * httpspace (this file): run the whole process

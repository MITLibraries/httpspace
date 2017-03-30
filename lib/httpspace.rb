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
    # Given that same file, create a stripped-down version with just id,
    # handle, and provenance. We'll use this to update provenance later.
    def initialize_provenance(csvfile)
      mycsv = CSV.read(csvfile, :headers=>true)
      @provenance_all = []
      mycsv.each { |row|
        @provenance_all << {"id" => row["id"],
                           "uri" => row["dc.identifier.uri"],
                           "provenance" => row["dc.description.provenance"]}
      }
    end

    ##
    # Given a directory containing zipped OCW item files:
    # * unzips each file
    # * finds and replaces http://ocw.mit.edu links with https
    # * rezips the file, if there were any changes
    # * deletes the temporary unzipped files
    # * records any files that could not be successfully processed
    def process_items(dirname)
      @tempdir = File.join(dirname, 'temp')
      FileUtils.mkdir_p @tempdir

      @csv_index = -1

      Dir.glob("#{dirname}/*.zip") do |zipfile|
        @zipfile = zipfile
        system("rm -f #{@tempdir}/*")

        begin
          system("unzip #{@zipfile} -d #{@tempdir}")

          Traversal.traverse(@tempdir)
          Replacer.update(Traversal.candidates)

          handle_metsfile
          clean_up
          update_csv

        rescue
          File.open("bad_zipfiles.txt", "a") { |f|
            f.puts(File.split(@zipfile)[1])
          }
          next
        end
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
          csv << ["id", "dc.description.provenance"]
        end
      end

      ##
      # Writes the object ID and an updated provenance statement to our current
      # CSV output file.
      def write_csv
        original_info = get_original_info
        updated_info = [
          original_info[:id],
          # Concatenate original and new provenance with dspace special
          # character.
          # If we try to import a csv file with just the updated provenance,
          # it will *overwrite*, not append, so we need to keep the original.
          original_info[:provenance] + "||" + METS.provenance
        ]
        CSV.open(@current_csv, "a") do |csv|
          csv << updated_info
        end
      end

      ##
      # Governs the start_csv and write_csv processes above..
      def update_csv
        # We limit the CSV files to 100 lines because dspace may choke if we
        # ask it to import too much metadata at a time.
        @csv_index += 1
        if @csv_index % 100 == 0
          start_csv
        end
        write_csv
      end

      ##
      # Gets the dspace ID and original provenance statement for the current file.
      def get_original_info
        file_id = File.basename(@zipfile, '.zip')
        @provenance_all.find { |obj|
          obj[:uri] == "http://hdl.handle.net/1721.1/#{file_id}"
        }
      end

      ##
      # Zips the working files into a new archive if there were any changes and
      # then deletes the working files.
      def clean_up
        # We're only going to rezip the file if we've replaced links. This
        # will let us import *.zip back into dspace later without any wasted
        # effort.
        if Replacer.links_processed > 0
          thedir, thefile = File.split(@zipfile)

          # Note that the file extension .zip is already included in thefile.
          system("zip -j #{thedir}/new_#{thefile} #{@tempdir}/*")
        end
        system("rm -f #{@tempdir}/*")
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

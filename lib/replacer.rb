require 'tempfile'
require 'fileutils'
require_relative 'helpers'

##
# Replaces http://ocw.mit.edu links with https and does recordkeeping about
# replacements.
module Replacer
  # Counts the links already processed.
  @links_processed = 0

  # For each file already processed, records the file path and a boolean of
  # whether the file was successfully processed.
  @files_processed = {}

  class << self
    attr_reader :links_processed

    ##
    # Given an array of file paths, replaces any instances of http://ocw.mit.edu
    # in those files with https://ocw.mit.edu.
    def update(files)
      reset_variables

      files.each do |filename|
        @files_processed[filename] = false
        @errors = false
        if File.file?(filename)
          begin
            temp_file = Tempfile.new('closed_courseware')
            @@current_filename = filename

            File.open(filename, 'r+') do |file|
              file.each_line do |line|
                begin
                  line = https_it(line)

                  temp_file.puts line
                rescue
                  @errors = true
                end
              end
            end

            FileUtils.mv(temp_file.path, filename)
            temp_file.close
            temp_file.unlink

            if !@errors
              @files_processed[filename] = true
            end
          ensure
            temp_file.close
            temp_file.unlink
          end
        end
      end
    end

    ##
    # Reports on the outcome of a replacement process: how many links have been
    # changed, and what (if any) files could not be processed.
    def notify
      puts "#@links_processed total links processed"

      bad_files = @files_processed.select { |k,v| !v }.keys
      if bad_files.length > 1
        puts "The following files could not be processed: "
        puts bad_files
      elsif bad_files.length == 1
        puts "The following file could not be processed:"
        puts bad_files
      else
        puts "All files processed; hooray!"
      end
    end

    def reset_variables
      @links_processed = 0
      @files_processed = {}
    end

    private
      def https_it(line)
        # Although the scope of this project is making OCW audio/video
        # links work, some of the links failing due to mixed content are
        # in fact calling out to YouTube or Internet Archive. They can be
        # trusted to have https, though, so let's do that.
        regexes = [/http:\/\/(ocw[0-9]*.mit.edu)/,
                   /http:\/\/([a-zA-Z0-9_]+.archive.org)/,
                   /http:\/\/([a-zA-Z0-9_]+.youtube.com)/]

        line = line.encode('UTF-8', :invalid => :replace)
        regexes.each do |regex|
          @links_processed += line.gsub(regex).count
          line.gsub!(regex, 'https://\1')
        end
        line
      end
  end
end

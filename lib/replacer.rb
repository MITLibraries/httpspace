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
            regex = /http:\/\/(ocw[0-9]*.mit.edu)/

            File.open(filename, 'r+') do |file|
              file.each_line do |line|
                begin
                  @links_processed += line.gsub(regex).count
                  subbed_line = line.gsub!(regex, 'https://\1')

                  # gsub returns nil if it doesn't make any substitutions. In that
                  # case, we want to use the original line.
                  temp_file.puts subbed_line ? subbed_line : line
                rescue
                  @errors = true
                end
              end
            end

            temp_file.close
            FileUtils.mv(temp_file.path, filename)
            if !@errors
              @files_processed[filename] = true
            end
          rescue
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
  end
end

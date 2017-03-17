require 'tempfile'
require 'fileutils'
require 'helpers'

class Replacer
  attr_reader :links_processed

  def initialize
    # This will track the links we have processed.
    @links_processed = 0
    # This will track all the files we have attempted to process, and also
    # whether or not we succeeded.
    @files_processed = {}

    # This will track whether we've already recorded that an index.htm file
    # has been changed. If we change it, we need to update the primary
    # bitstream, so we have to record what we've done. There is only one
    # primary bitstream per item, and we won't always need to change it.
    @index_file_recorded = false
  end

  def update(files)
    files.each do |filename|
      @files_processed[filename] = false
      if File.file?(filename)
        begin
          temp_file = Tempfile.new('closed_courseware')
          @current_filename = filename

          File.open(filename, 'r+') do |file|
            file.each_line do |line|
              # Execution of the code block will implicitly return the last line,
              # which is then used as the replacement pattern. The processed
              # variable must be incremented *first* or it will be returned and
              # we will change URLs into numbers.
              subbed_line = line.gsub!('http://ocw.mit.edu') {
                @links_processed += 1; 'https://ocw.mit.edu';
              }

              # gsub returns nil if it doesn't make any substitutions. In that
              # case, we want to use the original line.
              temp_file.puts subbed_line ? subbed_line : line

              # If we haven't yet recorded that we've changed an index file,
              # but we just changed *this* file, maybe this is an index file
              # we want to change; let's see.
              if !@index_file_recorded && !!subbed_line
                record_index_file
              end
            end
          end

          temp_file.close
          FileUtils.mv(temp_file.path, filename)
          @files_processed[filename] = true
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end

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

  # If we've changed a file that is a primary bitstream, make sure to update
  # the changelog, so that we will know later if we need to update the
  # primary bitstream record in dspace.
  def record_index_file
    components = File.split(@current_filename)
    if components[1] == 'index.htm' && File.basename(components[0]) == 'contents'
      File.open(INDEX_FILE_RECORD, 'a') { |f| f.puts @current_filename }
      @index_file_recorded = true
    end
  end

  def initialize_index_file
    File.open(INDEX_FILE_RECORD, 'w') { |file| file.truncate(0) }
  end
end

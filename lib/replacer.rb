require 'tempfile'
require 'fileutils'

class Replacer
  attr_reader :links_processed

  def initialize
    # This will track the links we have processed.
    @links_processed = 0
    # This will track all the files we have attempted to process, and also
    # whether or not we succeeded.
    @files_processed = {}
  end

  def update(files)
    files.each do |filename|
      @files_processed[:filename] = false
      begin
        temp_file = Tempfile.new('closed_courseware')

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
          end
        end

        temp_file.close
        FileUtils.mv(temp_file.path, filename)
        @files_processed[:filename] = true
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    puts @links_processed.to_s + ' link' + (@links_processed == 1 ? '' : 's') + ' processed. You so fancy!'
  end

end

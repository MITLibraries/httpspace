require 'uri'

class Parser
  attr_reader :processed

  def initialize
    @processed = 0
  end

  def update(files)
    files.each do |filename|
      File.open(filename) do |file|
        file.each_line do |line|
          # Execution of the code block will implicitly return the last line,
          # which is then used as the replacement pattern. The processed
          # variable must be incremented *first* or it will be returned and
          # we will change URLs into numbers.
          line.gsub!('http://ocw.mit.edu') {
            @processed += 1; 'https://ocw.mit.edu';
          }
        end
      end

    end
    puts @processed.to_s + ' links processed. You so fancy!'
  end

end

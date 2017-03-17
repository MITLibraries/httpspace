require 'helpers'

class Traversal

  def initialize
    @counts = Hash[FILETYPES.map {|filetype| [filetype, []]}]
  end

  # Find all the files of types that we care about.
  def traverse(path='./files')
    begin
      Dir.foreach(path) do |file|
        if file == '.' or file == '..'
          next
        elsif File.directory?(File.join(path, file))
          traverse(File.join(path, file))
        else
          filetype = File.extname(file).downcase.tr('.', '')
          if FILETYPES.include?(filetype)
            @counts[filetype] << File.join(path, file)
          end
        end
      end
    rescue
      puts path
    end
  end

  def count(filetype)
    if !FILETYPES.include?(filetype)
      raise 'Invalid file type'
    end
    @counts[filetype].length
  end

  def candidates
    @counts.values.flatten
  end

end

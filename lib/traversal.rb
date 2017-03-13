require 'helpers'
class Traversal

  def initialize
    @counts = Hash[FILETYPES.map {|filetype| [filetype, 0]}]
  end

  def traverse(path='./files')
    Dir.foreach(path) do |file|
      if file == '.' or file == '..'
        next
      elsif File.directory?(File.join(path, file))
        traverse(File.join(path, file))
      else
        filetype = File.extname(file).downcase.tr('.', '')
        if FILETYPES.include?(filetype)
          @counts[filetype] += 1
        end
      end
    end
  end

  def count(filetype)
    if !FILETYPES.include?(filetype)
      raise 'Invalid file type'
    end
    @counts[filetype]
  end

end

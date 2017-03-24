require_relative 'helpers'

##
# Traverses a directory recursively to find any files that might need to be
# updated with https links.
module Traversal
  attr_reader :counts

  class << self
    ##
    # Given a directory path, recursively finds all the files of types that we
    # care about under that path.
    #
    # +path+ defaults to +./files+.
    def traverse(path='./files')
      initialize_counts

      # We break out the recursion into this private function in order to be
      # able to initialize the counts array *only as we enter the traversal*,
      # and not every time we recurse into a subdirectory.
      inner_traverse(path)
    end

    ##
    # Given a filetype, returns the number of files found of that filetype.
    def count(filetype)
      if !FILETYPES.include?(filetype)
        raise 'Invalid file type'
      end
      @counts[filetype].length
    end

    ##
    # Returns an array of the full paths to all the files of relevant types.
    # (If +traverse+ has not yet been run, this will be an empty array.)
    def candidates
      @counts.values.flatten
    end

    private
      def initialize_counts
        @counts = Hash[FILETYPES.map {|filetype| [filetype, []]}]
      end

      def inner_traverse(path)
        begin
          Dir.foreach(path) do |file|
            if file == '.' or file == '..'
              next
            elsif File.directory?(File.join(path, file))
              inner_traverse(File.join(path, file))
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
  end

end

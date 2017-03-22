require_relative "traversal"
require_relative "replacer"

traversal = Traversal.new
traversal.traverse

replacer = Replacer.new
replacer.update(traversal.candidates)

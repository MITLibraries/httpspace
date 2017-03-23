# The filetypes that the program will examine for OCW http links.
FILETYPES = ['htm', 'html', 'pdf', 'xml', 'css', 'js']

# The location of the file where we record which primary bitsteam files we
# have changed.
INDEX_FILE_RECORD = File.join(File.dirname(File.dirname(__FILE__)), 'index_file_record.txt')

# Where the packager command lives.
DSPACE_BIN_DIR = '/home/dspace/dspace.mit.edu/bin/dspace'

# The user who is running this process (may appear in dspace provenance records).
RESPONSIBLE_USER = 'm31@mit.edu'

WORKING_DIR = '/home/dspace/dspace.mit.edu/httpspace'

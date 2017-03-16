# Anything you define in Helpers will be automatically available to all tests
# via spec_helper.

module Helpers
  @@destination = File.join(File.dirname(__FILE__), 'testfiles', 'tmp')

  def setup_files
    @source = File.join(File.dirname(__FILE__), 'testfiles', '75804')
    FileUtils.copy_entry @source, @@destination
  end

  def teardown_files
    FileUtils.rm_r @@destination
  end

  def destination
    @@destination
  end
end

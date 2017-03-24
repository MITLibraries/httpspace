require 'benchmark'
require 'fileutils'
require "./lib/traversal"
require "./lib/replacer"
require "./lib/helpers"

RSpec.describe Replacer do
  before(:all) do
    @destination = destination
  end

  before(:each) do
    setup_files
  end

  after(:each) do
    teardown_files
  end

  it "finds all the http://ocw.mit.edu links in xml" do
    testfile = File.join(@destination, 'imsmanifest.xml')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(6)
  end

  it "finds all the http://ocw.mit.edu links in html" do
    testfile = File.join(@destination, '5-301-january-iap-2004/contents/index.htm')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(76)
  end

  it "finds all the http://ocw.mit.edu links in js" do
    testfile = File.join(@destination, '5-301-january-iap-2004/common/scripts/ocw-offline.js')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(1)
  end

  it "can take a list of files" do
    file1 = File.join(@destination, '5-301-january-iap-2004/contents/syllabus/index.htm')
    file2 = File.join(@destination, '5-301-january-iap-2004/contents/syllabus/index.htm.xml')
    Replacer.update([file1, file2])
    expect(Replacer.links_processed).to eq(82)
  end

  it "does not choke on non-files" do
    # As long as this doesn't throw an error, we're fine; no assertion needed.
    Replacer.update(['.', '..', @destination])
  end

  # This doesn't actually *test* anything, but it ensures that we're getting
  # notified about speed every time we run tests. This will help us decide the
  # correct DSpace import/export strategy.
  it "is not too slow" do
    testfiles = Dir.entries(File.join(@destination, '5-301-january-iap-2004/contents/labs'))
    usable_testfiles = testfiles.map { |file| File.join(@destination, '5-301-january-iap-2004/contents/labs', file) }
    num = usable_testfiles.length
    puts "Benchmarking #{num} files..."

    Benchmark.bm do |x|
      x.report {
        Replacer.update(usable_testfiles)
      }
    end
  end

end

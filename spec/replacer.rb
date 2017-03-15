require 'benchmark'
require 'fileutils'
require "./lib/replacer"
require "./lib/helpers"

RSpec.describe Replacer do
  before(:all) do
    @source = File.join(File.dirname(__FILE__), 'testfiles', '75804')
    @destination = File.join(File.dirname(__FILE__), 'testfiles', 'tmp')
    FileUtils.copy_entry @source, @destination
  end

  after(:all) do
    FileUtils.rm_r @destination
  end

  before(:each) do
    @replacer = Replacer.new
  end

  it "finds all the http://ocw.mit.edu links in xml" do
    testfile = File.join(@destination, 'imsmanifest.xml')
    @replacer.update([testfile])
    expect(@replacer.links_processed).to eq(6)
  end

  it "finds all the http://ocw.mit.edu links in html" do
    testfile = File.join(@destination, '5-301-january-iap-2004/contents/index.htm')
    @replacer.update([testfile])
    expect(@replacer.links_processed).to eq(76)
  end

  it "finds all the http://ocw.mit.edu links in js" do
    testfile = File.join(@destination, '5-301-january-iap-2004/common/scripts/ocw-offline.js')
    @replacer.update([testfile])
    expect(@replacer.links_processed).to eq(1)
  end

  it "can take a list of files" do
    file1 = File.join(@destination, '5-301-january-iap-2004/contents/syllabus/index.htm')
    file2 = File.join(@destination, '5-301-january-iap-2004/contents/syllabus/index.htm.xml')
    @replacer.update([file1, file2])
    expect(@replacer.links_processed).to eq(82)
  end

  it "does not choke on non-files" do
    # As long as this doesn't throw an error, we're fine; no assertion needed.
    @replacer.update(['.', '..', @destination])
  end

  it "is not too slow" do
    testfiles = Dir.entries(File.join(@destination, '5-301-january-iap-2004/contents/labs'))
    usable_testfiles = testfiles.map { |file| File.join(@destination, '5-301-january-iap-2004/contents/labs', file) }
    num = usable_testfiles.length
    puts "Benchmarking #{num} files..."

    Benchmark.bm do |x|
      x.report {
        @replacer.update(usable_testfiles)
      }
    end
  end

end

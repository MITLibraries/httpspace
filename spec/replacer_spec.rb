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
    testfile = File.join(@destination, 'mets.xml')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(1)
  end

  # Note that this file includes an http://ocw5.mit.edu link too
  it "finds all the http://ocw.mit.edu links in html" do
    testfile = File.join(@destination, 'bitstream_1024212.htm')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(80)
  end

  it "finds all the http://ocw.mit.edu links in js" do
    testfile = File.join(@destination, 'bitstream_1024119')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(7)
  end

  it "can take a list of files" do
    file1 = File.join(@destination, 'bitstream_1024119')
    file2 = File.join(@destination, 'bitstream_1024212.htm')
    Replacer.update([file1, file2])
    expect(Replacer.links_processed).to eq(87)
  end

  it "finds archive.org links" do
    testfile = File.join(@destination, 'bitstream_1023956.htm')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(1)
  end

  it "finds youtube.com links" do
    testfile = File.join(@destination, 'bitstream_1024105.css')
    Replacer.update([testfile])
    expect(Replacer.links_processed).to eq(1)
  end

  it "does not choke on non-files" do
    # As long as this doesn't throw an error, we're fine; no assertion needed.
    Replacer.update(['.', '..', @destination])
  end

  # This doesn't actually *test* anything, but it ensures that we're getting
  # notified about speed every time we run tests. This will help us decide the
  # correct DSpace import/export strategy.
  it "is not too slow" do
    testfiles = Dir.glob(File.join(@destination, '*.*'))
    usable_testfiles = testfiles.map { |file| file if File.file? file }
    num = usable_testfiles.length
    puts "Benchmarking #{num} files..."

    Benchmark.bm do |x|
      x.report {
        Replacer.update(usable_testfiles)
      }
    end
  end

end

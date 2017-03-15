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

end

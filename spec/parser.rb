require "./lib/parser"
require "./lib/helpers"

RSpec.describe Parser do
  it "finds all the http://ocw.mit.edu links in xml" do
    @parser = Parser.new
    testfile = File.join(File.dirname(__FILE__), '../files/75804-new/imsmanifest.xml')
    @parser.update([testfile])
    expect(@parser.processed).to eq(6)
  end

  it "finds all the http://ocw.mit.edu links in html" do
    @parser = Parser.new
    testfile = File.join(File.dirname(__FILE__), '../files/75804-new/5-301-january-iap-2004/contents/index.htm')
    @parser.update([testfile])
    expect(@parser.processed).to eq(76)
  end
end

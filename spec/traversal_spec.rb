require "./lib/traversal"
require "./lib/helpers"

RSpec.describe Traversal do
  before(:all) do
    setup_files
    @traversal = Traversal.new
    @traversal.traverse(destination)
  end

  after(:all) do
    teardown_files
  end

  it "tests the filetypes we require" do
    expect(FILETYPES.include?('htm')).to be true
    expect(FILETYPES.include?('html')).to be true
    expect(FILETYPES.include?('css')).to be true
    expect(FILETYPES.include?('js')).to be true
    expect(FILETYPES.include?('pdf')).to be true
    expect(FILETYPES.include?('xml')).to be true
    expect(FILETYPES.length).to eq(6)
  end

  it "finds all the .htm files" do
    expect(@traversal.count('htm')).to eq(10)
  end

  it "finds all the .html files" do
    # (there aren't actually any)
    expect(@traversal.count('html')).to eq(0)
  end

  it "finds all the .css files" do
    expect(@traversal.count('css')).to eq(13)
  end

  it "finds all the .js files" do
    expect(@traversal.count('js')).to eq(9)
  end

  it "finds all the .pdf files" do
    expect(@traversal.count('pdf')).to eq(24)
  end

  it "finds all the .xml files" do
    expect(@traversal.count('xml')).to eq(32)
  end

end

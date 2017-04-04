require "./lib/traversal"
require "./lib/helpers"

RSpec.describe Traversal do
  before(:all) do
    setup_files
    Traversal.traverse(destination)
  end

  after(:all) do
    teardown_files
  end

  it "tests the filetypes we require" do
    expect(FILETYPES.include?('htm')).to be true
    expect(FILETYPES.include?('html')).to be true
    expect(FILETYPES.include?('css')).to be true
    expect(FILETYPES.include?('js')).to be true
    expect(FILETYPES.include?('xml')).to be true
    expect(FILETYPES.include?('txt')).to be true
    expect(FILETYPES.include?('')).to be true
    expect(FILETYPES.length).to eq(7)
  end

  it "finds all the .htm files" do
    expect(Traversal.count('htm')).to eq(22)
  end

  it "finds all the .html files" do
    # (there aren't actually any)
    expect(Traversal.count('html')).to eq(0)
  end

  it "finds all the .css files" do
    expect(Traversal.count('css')).to eq(14)
  end

  it "finds all the .js files" do
    expect(Traversal.count('js')).to eq(0)
  end

  it "finds all the .xml files" do
    expect(Traversal.count('xml')).to eq(1)
  end

  it "finds all the .txt files" do
    expect(Traversal.count('txt')).to eq(34)
  end

  it "finds all the extensionless files" do
    expect(Traversal.count('')).to eq(29)
  end

  it "records the files" do
    expect(Traversal.candidates.length).to eq(100)
    # Check: all elements are distinct. If they're all different and we have
    # the number we expected, then we've just constucted a one-to-one and onto
    # mapping so we must have all the elements we expected. BOOM, using that
    # math degree.
    expect(Traversal.candidates.uniq).to eq(Traversal.candidates)
  end

end

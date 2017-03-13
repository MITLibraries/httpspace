require "./lib/traversal"

RSpec.describe Traversal do
  before(:all) do
    @traversal = Traversal.new
  end

  it "finds all the .htm files" do
    expect(@traversal.count('htm')).to eq(10)
  end
end

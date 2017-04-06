require "./lib/httpspace"

RSpec.describe HttpSpace do
  before(:all) do
    @testfile = File.join(testfile_directory, 'test.csv')
    @output_dir = File.dirname(__FILE__)
    HttpSpace.output_dir = @output_dir
    system("rm -f [%s]" % (File.join(@output_dir, "provenance_0.csv")))
    system("rm -f [%s]" % (File.join(@output_dir, "bad_zipfiles.txt")))
    system("rm -f [%s]" % (File.join(@output_dir, "item_handles.txt")))
    system("rm -f [%s]" % (File.join(@output_dir, "testfiles", "test_zip", "new*")))
  end

  it "writes handles properly given a CSV file" do
    outfile = File.join(@output_dir, "item_handles.txt")
    HttpSpace.get_handles(@testfile)
    expect(File.file?(outfile)).to be true
    content = "1721.1/34898\n1721.1/35849\n1721.1/35852\n1721.1/36897\n1721.1/85562\n"
    expect(File.read(outfile)).to eq(content)
    File.delete(outfile)
  end

  it "initializes provenance correctly" do
    # Open module so that we can access the provenance_all variable directly
    module HttpSpace
      class << self
          attr_reader :provenance_all
      end
    end

    HttpSpace.initialize_provenance(@testfile)
    # expected_provenance is defined in helpers.rb, because it's very long.
    expect(HttpSpace.provenance_all).to eq(expected_provenance)
  end

  it "creates a provenance file correctly after processing" do
    testfile = File.join(testfile_directory, 'test_only_one.csv')
    HttpSpace.initialize_provenance(testfile)
    HttpSpace.process_items(File.join(testfile_directory, "test_zip"))
    provenance_file = File.join(@output_dir, "provenance_0.csv")
    expect(File.file?(provenance_file)).to be true

    version1 = remove_timestamp expected_provenance_file
    version2 = remove_timestamp File.read(provenance_file)
    expect(version1).to eq(version2)
  end

  private
    ##
    # httpspace.rb generates timestamps for the provenance entry which will not
    # match the timestamp in the test data. Just remove them. The important
    # stuff to test is the rest of the data.
    def remove_timestamp(string)
      string.gsub(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/, '')
    end

end

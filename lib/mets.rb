require "date"
require "digest"
require "nokogiri"

##
# Utilities for parsing and editing mets.xml files.
module METS

  class << self
    attr_reader :provenance, :item_id

    ##
    # Given a filename for an item mets.xml, see if the files have changed; if so,
    # fix the size and checksum metadata. (Assumes that the referenced bitstreams
    # are in the same directory as the mets file.)
    def update_metadata(metsfile)

      @doc = Nokogiri::XML(File.read(metsfile))
      bitstreams = @doc.css('file')

      @provenance = <<-EOF.gsub(/^\s+/, '')
        OCW links updated to https by m31@mit.edu on %{date}
        No. of bitstreams updated: %{count}
      EOF

      @count = 0
      bitstreams.each do |bitstream|
        checksum = bitstream.attribute('CHECKSUM')
        bitstreampath = File.split(metsfile)[0]
        new_checksum, file_size = get_new_metadata(bitstreampath, bitstream)

        # You have to force both checksums to String, or else the equality test
        # will fail due to their different object types, even though the
        # representations look the same. If they differ, update the MODS and
        # PREMIS records.
        if checksum.to_s != new_checksum.to_s
          digest_node, size_node, original_name = get_premis_components(checksum)
          bitstream['CHECKSUM'] = digest_node.content = new_checksum.to_s
          bitstream['SIZE'] = size_node.content = file_size
          append_provenance(original_name, new_checksum, file_size)
          @count += 1
        end
      end

      date = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      @provenance = @provenance % {:date => date, :count => @count}
      set_item_id(metsfile)
      File.write(metsfile, @doc.to_xml)
    end

    private

      def append_provenance(original_name, new_checksum, file_size)
        @provenance << "#{original_name}: #{file_size} bytes, checksum: #{new_checksum} (MD5)"
      end

      ##
      # Given a checksum, returns the size, checksum, and file name components
      # of the PREMIS record associated with that checksum.
      def get_premis_components(checksum)
        # Get PREMIS components. It's easy to find the one with the MD5 hash
        # as we are blithely assuming no collisions. Finding the size node in
        # the same record...ugh, xpath.
        digest_node = @doc.xpath("//*[contains(text(), '#{checksum.to_s}')]")[0]
        size_node = digest_node.xpath(
            './ancestor::premis:objectCharacteristics',
            'premis' => 'http://www.loc.gov/standards/premis'
          ).xpath(
            './descendant::premis:size',
            'premis' => 'http://www.loc.gov/standards/premis')[0]
        original_name = digest_node.xpath(
            './ancestor::premis:object',
            'premis' => 'http://www.loc.gov/standards/premis'
          ).xpath(
            './descendant::premis:originalName',
            'premis' => 'http://www.loc.gov/standards/premis')[0].content

        [digest_node, size_node, original_name]
      end

      ##
      # Given a bitstream path and filename, returns its MD5 checksum and file
      # size.
      def get_new_metadata(bitstreampath, bitstream)
        bitfile = bitstream.css('FLocat')[0]['xlink:href']
        bitfilepath = File.join(bitstreampath, bitfile)

        [Digest::MD5.file(bitfilepath), File.size(bitfilepath)]
      end

      def set_item_id(metsfile)
        @item_id = @doc.css('mets')[0]['OBJID'].sub('hdl:', '')
      end
  end

end

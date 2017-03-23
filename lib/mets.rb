require "digest"
require "nokogiri"

class METS
  # should actually be module??
  # requires testing

  def parse_mets(filename, community=true)
    # Parses the mets.xml file from a DSpace community (if community=true) or
    # collection. Returns the IDs of its child objects (collections or items,
    # respectively).
    child_ids = []
    File.open(filename) { |f|
      @doc = Nokogiri::XML(f)
      if community
        selector = 'div[TYPE="DSpace COLLECTION"]'
      else
        selector = 'div[TYPE="DSpace ITEM"]'
      end

      children = @doc.css(selector)

      children.each do |child|
        child_ids << child.first_element_child['xlink:href']
      end
    }

    child_ids
  end

  def update_checksums(metsfile)
    # Given a METS file for an item, see if the checksums are correct, and fix
    # them if not. (Assumes that the referenced bitstreams are in the same
    # directory.)

    @doc = Nokogiri::XML(File.read(metsfile))
    bitstreams = @doc.css('file')

    bitstreams.each do |bitstream|
      checksum = bitstream.attribute('CHECKSUM')
      bitfile = bitstream.css('FLocat')[0]['xlink:href']
      bitfilepath = File.join(File.split(metsfile)[0], bitfile)
      new_checksum = Digest::MD5.file bitfilepath

      # You have to force both of them to strings, or else the equality test
      # will fail due to their different object types, even though the
      # representations look the same.
      if checksum.to_s != new_checksum.to_s
        puts bitfilepath
        bitstream['CHECKSUM'] = new_checksum.to_s
      end
    end

    File.write(metsfile, @doc.to_xml)
  end

end

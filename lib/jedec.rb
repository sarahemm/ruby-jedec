DIR = File.expand_path(File.dirname(File.expand_path(__FILE__)))
$:.unshift DIR
require 'jedec/fusedata'

class Jedec
  attr_reader :nbr_pins, :nbr_fuses, :security_fuse, :fuse_data
  STX = 0x02
  ETX = 0x03
  
  def initialize
    @fuse_data = FuseData.new
  end
  
  def initialize(filename)
    load(filename)
  end
  
  # load a JEDEC fuse file into this object
  def load(filename)
    @nbr_fuses = @nbr_pins = @calc_tx_checksum = 0
    @fuse_data = FuseData.new
    
    record_nbr = 0;
    File.open(filename).each_line('*').each { |line|
      tx_checksum_match = line.match(/(\002?[^\003]*\003?)/)
      tx_checksum_match[1].split("").each { |byte|
        @calc_tx_checksum += byte[0]
      }
      if(record_nbr == 0) then
        raise NotAJedecFile if line[0] != STX
        record_nbr += 1
        next
      end
      line.chomp! '*'
      line.strip!
      process_field(line[0].chr, line[1..-1])
      record_nbr += 1
    }
  end
  
  # process one JEDEC field
  def process_field(field_type, data)
    case field_type
      when 'G', 'N', 'U', 'E'
        # security fuses, notes, non-electrical user data, ETX
        # all ignored for now
      when 'C'
        # fuse checksum
        fuse_checksum_expected_match = data.match(/\A([A-F0-9]{4})\z/)
        raise SyntaxError if !fuse_checksum_expected_match
        fuse_checksum_expected = fuse_checksum_expected_match[1].to_i(16);
        raise FuseChecksumError if fuse_checksum_expected != @fuse_data.checksum
      when 'F'
        # fuse default
        fuse_default_match = data.match(/\A([01])\z/)
        raise SyntaxError if !fuse_default_match
        fuse_default = (fuse_default_match[1] == '0' ? 0 : 1)
        @fuse_data.set_fuse_default(fuse_default, @nbr_fuses)
      when 'G'
        # security fuse
        security_fuse_match = subfield_data.match(/\A(\d)\z/)
        raise SyntaxError if !security_fuse_match
        @security_fuse = security_fuse_match[1].to_i;
      when 'L'
        # binary fuse data
        fuse_data_match = data.match(/(\d+)\s+(.*)/ms)
        raise SyntaxError if !fuse_data_match
        fuse_base = fuse_data_match[1].to_i
        fuse_line = fuse_data_match[2]
        load_fuse_data(fuse_base, fuse_line)
        raise TooManyFuses if fuse_data.length > @nbr_fuses
      when 'Q'
        # value field
        subfield_type = data[0].chr
        subfield_data = data[1..-1]
        case subfield_type
          when 'F'
            # number of fuses
            nbr_fuses_match = subfield_data.match(/\A(\d+)\z/)
            raise SyntaxError if !nbr_fuses_match
            @nbr_fuses = nbr_fuses_match[1].to_i;
          when 'P'
            # number of pins
            nbr_pins_match = subfield_data.match(/\A(\d+)\z/)
            raise SyntaxError if !nbr_pins_match
            @nbr_pins = nbr_pins_match[1].to_i;
          else
            puts "Invalid Q subfield type: #{subfield_type}"
        end
      when "\003"
        # end of text, transmission checksum follows
        expected_tx_checksum = data.to_i(16)
        @calc_tx_checksum = @calc_tx_checksum % 2**16
        next if expected_tx_checksum == 0x0000  # dummy value meaning "no tx checksum"
        raise TransmissionChecksumError if expected_tx_checksum != @calc_tx_checksum
      else
        raise UnsupportedFieldType
    end
  end
  
  # fed a starting address and a long string of 0/1/other, load all 0/1s into the fuse data array
  def load_fuse_data(fuse_base, fuse_databits)
    databits = fuse_databits.split("")
    databits.delete_if { |bitdata| !"01".include?(bitdata)  }
    databits.map! { |bitdata| bitdata == '0' ? 0 : 1 }
    fuse_end = fuse_base + fuse_databits.length
    @fuse_data[fuse_base..fuse_end] = databits
  end
  
  class NotAJedecFile < StandardError
  end
   
  class TooManyFuses < StandardError
  end
  
  class FuseChecksumError < StandardError
  end
  
  class TransmissionChecksumError < StandardError
  end
  
  class UnsupportedFieldType < StandardError
  end
end
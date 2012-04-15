class Jedec
  class FuseData
    def initialize(fuse_data = Array.new)
      @fuse_data = fuse_data
    end
  
    def []=(element, value)
      @fuse_data[element] = value
      @data_dirty = true
    end
  
    def [](element)
      @fuse_data[element]
    end
  
    def length
      @fuse_data.length
    end
  
    def set_fuse_default(default, nbr_fuses)
      raise FuseDataAlreadyInitialized if @data_dirty
      @fuse_data.fill(default, 0, nbr_fuses)
      @data_dirty = true
    end
  
    # calculate a JEDEC fuse file checksum
    def checksum
      calc_checksum = 0
      byte_bit_nbr = 0
      @fuse_data.each { |bit|
        calc_checksum += 2**byte_bit_nbr if bit == 1
        byte_bit_nbr += 1
        byte_bit_nbr = 0 if byte_bit_nbr == 8
      }
      calc_checksum = calc_checksum % 2**16
      calc_checksum
    end
  
    # return fuse data as an array containing a specified number of bits per element
    def to_a(bits_per_element)
      out_array = Array.new
      for ptr in 0.step(@fuse_data.length, bits_per_element) do
        out_element = 0
        @fuse_data[ptr..ptr+bits_per_element-1].each { |bit|
          out_element = out_element << 1
          out_element |= 1 if bit == 1
        }
        out_array.push out_element
      end
      out_array
    end
  end
  
  class FuseDataAlreadyInitialized < StandardError
  end
end
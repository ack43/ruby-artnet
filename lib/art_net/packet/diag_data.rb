module ArtNet::Packet
  class DiagData < Base

    OPCODE = 0x2300

    def initialize
      # https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf#page=45
      @filler1 = 0
      @priority = 0x80
      @filler2 = 0
      @filler3 = 0
      @length = 0x80
      @data = nil
    end

    def unpack(data)
      protver, @filler1, @priority, @filler2, @filler3, @length = data.unpack 'nCCCCn'
      puts 'protver, @filler1, @priority, @filler2, @filler3, @length'
      puts [protver, @filler1, @priority, @filler2, @filler3, @length].inspect
      # @data = data[8..].unpack "Z#{@length}"
      puts data.inspect
      @data = data.unpack "@8Z#{@length}"
      puts '@data'
      puts @data.inspect
      check_version(protver)
    end

    def pack
      [ID, opcode, PROTVER, @filler1, @priority, @filler2, @filler3].pack("Z7xvnCCCC")
    end

  end
end

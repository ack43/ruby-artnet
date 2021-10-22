module ArtNet::Packet
  class Sync < Base

    OPCODE = 0x5200

    def initialize
      # https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf#page=61
      @aux1 = 0
      @aux2 = 0
    end

    def unpack(data, io = nil)
      @aux1, @aux2 = data.unpack 'CC'
      puts 'protver, @aux1, @aux2'
      puts [protver, @aux1, @aux2].inspect
      # check_version(protver)
    end

    def pack
      [ID, opcode, PROTVER, @aux1, @aux2].pack("Z7xvnCC")
    end

  end
end

module ArtNet::Packet
  class DMX < Base

    OPCODE = 0x5000

    attr_accessor :sequence, :physical, :universe, :channels

    def initialize
      @sequence = 0
      @physical = 0
      @channels = []
    end

    def unpack(data)
      protver, @sequence, @physical, @universe, length = data.unpack 'nCCvn'
      @channels = data.unpack "@8C#{length}C"
      final = @channels.pop
      check_version(protver)
      raise PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
    end

    def pack
      ([ID, opcode, PROTVER, sequence, physical, universe, channels.length] + channels).pack "Z7xvnCCvnC#{length}"
    end

    def length
      channels.length
    end

  end
end

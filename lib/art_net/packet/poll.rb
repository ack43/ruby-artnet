module ArtNet::Packet
  class Poll < Base

    OPCODE = 0x2000

    attr_accessor :talk_to_me, :priority

    def initialize
      @talk_to_me = 0
      @priority = 0
    end

    def unpack(data)
      protver, @talk_to_me, @priority, final = data.unpack 'nCCC'
      check_version(protver)
      raise PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
    end

    def pack
      [ID, opcode, PROTVER, @talk_to_me, @priority].pack("Z7xvnCC")
    end

  end
end

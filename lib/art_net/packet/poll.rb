module ArtNet::Packet
  class Poll < Base

    OPCODE = 0x2000

    attr_accessor :talk_to_me, :priority

    def initialize
      # https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf#page=24
      # @talk_to_me = 0 
      @talk_to_me = 0b0001_1110
      @priority = 0x80
    end

    def unpack(data)
      protver, @talk_to_me, @priority, final = data.unpack 'n C C C'
      puts 'protver, @talk_to_me, @priority, final'
      puts [protver, @talk_to_me, @priority, final].inspect
      check_version(protver)
      # TODO: check is `final` need?
      # raise ArtNet::PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil? 
    end

    def pack
      [ID, opcode, PROTVER, @talk_to_me, @priority].pack("Z7xvnCC")
    end

  end
end

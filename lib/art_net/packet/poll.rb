module ArtNet::Packet
  class Poll < Base

    OPCODE = 0x2000

    attr_accessor :talk_to_me, :priority

    # TODO: different class or module or enum
    #priority
    # 0x10 DpLow Low priority message.
    # 0x40 DpMed Medium priority message.
    # 0x80 DpHigh High priority message.
    # 0xe0 DpCritical Critical priority message.
    # 0xf0 DpVolatile Volatile message. Messages of this type are displayed
    # on a single line in the DMX-Workshop diagnostics
    # display. All other types are displayed in a list box.

    def initialize
      # https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf#page=24
      # @talk_to_me = 0 
      @talk_to_me = 0b0001_1100 # 0b0001_1110
      @priority = 0x80
    end

    def unpack(data, io = nil)
      @talk_to_me, @priority = data.unpack 'C C'
      # puts '@talk_to_me, @priority'
      # puts [@talk_to_me, @priority].inspect
      # TODO: check is `final` need?
      # raise ArtNet::PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil? 
    end

    def pack
      [ID, opcode, PROTVER, @talk_to_me, @priority].pack("Z7xvnCC")
    end

  end
end

module ArtNet::Packet
  class Address < Base

    OPCODE = 0x6000

    attr_accessor :netswitch, :short_name, :long_name, :swin, :swout, :subswitch, :command

    def initialize
      @netswitch = 0
      @short_name = ''
      @long_name = ''
      @swin = Array.new(4, 0x7f)
      @swout = Array.new(4, 0x7f)
      @subswitch = 0x7f
      @command = 0
    end

    def pack
      swvideo = 0
      [ID, opcode, PROTVER, netswitch, short_name, long_name, *swin, *swout, subswitch, swvideo, command].pack "Z7xvnCxZ18Z64C4C4CCC"
    end

  end
end

module ArtNet::Packet
  class Address < Base

    OPCODE = 0x6000

    attr_accessor :netswitch, :short_name, :long_name, :swin, :swout, :subswitch, :command, :swvideo

    def initialize
      @netswitch = 0x7f
      @short_name = ''
      @long_name = ''
      @swin = Array.new(4, 0x7f)
      @swout = Array.new(4, 0x7f)
      @subswitch = 0x7f
      @swvideo
      @command = 0
    end

    def unpack(data, io = nil)
      @netswitch, @short_name, @long_name, @swin, @swout, @subswitch, @swvideo, @command = data.unpack 'n Z18 Z64 C4 C4'
      #  n          C           C18       C64       C4     C4         C         C       C
      puts 'protver, @netswitch, @short_name, @long_name, @swin, @swout, @subswitch, @swvideo, @command'
      puts [protver, @netswitch, @short_name, @long_name, @swin, @swout, @subswitch, @swvideo, @command].inspect
      check_version(protver)
    end

    def pack
      # swvideo = 0
      # [ID, opcode, PROTVER, netswitch, short_name, long_name, *swin, *swout, subswitch, swvideo, command].pack "Z7xvnCxZ18Z64C4C4CCC"
      [ID, @opcode, PROTVER, @netswitch, @short_name, @long_name, *@swin, *@swout, @subswitch, @swvideo, @command].pack "Z7 x vnCxZ18Z64C4C4CCC"
    end

  end
end

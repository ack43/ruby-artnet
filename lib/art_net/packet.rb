require 'ipaddr'

module ArtNet

  class PacketFormatError < RuntimeError
  end

  module Packet

    ID = 'Art-Net'
    PROTVER = 14

    class Base

      def self.unpack(data)
        p = self.new
        p.unpack(data)
        p
      end

      def opcode
        TYPES.invert[self.class]
      end

      private

      def check_version(ver)
        raise PacketFormatError.new("Bad protocol version #{ver}") unless ver == PROTVER
      end

    end

    class OpPoll < Base

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
        [ID, opcode, PROTVER, @talk_to_me, @priority].pack("a7xvnCC")
      end

    end

    class OpPollReply < Base

      def unpack(data)
        @mac = []
        @swin = []
        @swout = []
        @port_types = []
        ip, versionh, versionl, @netswitch, @subswitch, @oem, @ubea, @status1, @manufacturer,
        @short_name, @long_name, @report, @ports, @port_types[0], @port_types[1], @port_types[2], @port_types[3],
        @input, @output, @swin[0], @swin[1], @swin[2], @swin[3], @swout[0], @swout[1], @swout[2], @swout[3],
        @swvideo, @swmacro, @swremote, @style, @mac[0], @mac[1], @mac[2], @mac[3], @mac[4], @mac[5],
        bind_ip, @bindIndex, @statis2, final = data.unpack 'L>xxCCCCvCCn Z18Z64Z64nC4 LLC4C4 CCCxxxCC6 LCCx26C'
        @ip = ::IPAddr.new(ip,  Socket::AF_INET)
        @firmware_version = "#{versionh}.#{versionl}".to_f
        @bind_ip = ::IPAddr.new(bind_ip,  Socket::AF_INET)
        raise PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
      end

      def node
        node = ArtNet::Node.new
        node.ip = @ip.to_s
        node.swin = @swin
        node.swout = @swout
        node.uni, node.subuni, node.mfg, node.shortname, node.longname, node.numports = 0,0, @manufacturer, @short_name, @long_name, @ports
        node
      end

    end

    class OpOutput < Base

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

    TYPES = {
      0x2000 => OpPoll,
      0x2100 => OpPollReply,
      0x5000 => OpOutput
    }

    def self.load(data)
      id, opcode = data.unpack 'Z7xS'
      raise PacketFormatError.new('Not an Art-Net packet') unless id === 'Art-Net'
      klass = TYPES[opcode]
      raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      return klass.unpack(data[10..-1])
    end

  end
end


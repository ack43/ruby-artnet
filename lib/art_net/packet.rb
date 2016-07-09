require 'ipaddr'

module ArtNet

  class PacketFormatError < RuntimeError
  end

  module Packet

    ID = 'Art-Net'
    PROTVER = 14

    class Base

      attr_writer :net_info

      def self.unpack(data, net_info)
        p = self.new
        p.unpack(data)
        net_info[4] = Time.now
        p.net_info = net_info
        p
      end

      def opcode
        TYPES.invert[self.class]
      end

      def type
        self.class.name.split('::').last
      end

      def sender_name
        @net_info[2]
      end

      def sender_ip
        @net_info[3]
      end

      def received_at
        @net_info[4]
      end

      private

      def check_version(ver)
        raise PacketFormatError.new("Bad protocol version #{ver}") unless ver == PROTVER
      end

    end

    class Poll < Base

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

    class PollReply < Base

      def unpack(data)
        @mac = []
        @swin = []
        @swout = []
        @port_types = []
        ip, versionh, versionl, @netswitch, @subswitch, @oem, @ubea, @status1, @manufacturer,
        @short_name, @long_name, @report, @ports, @port_types[0], @port_types[1], @port_types[2], @port_types[3],
        @input, @output, @swin[0], @swin[1], @swin[2], @swin[3], @swout[0], @swout[1], @swout[2], @swout[3],
        @swvideo, @swmacro, @swremote, @style, @mac[0], @mac[1], @mac[2], @mac[3], @mac[4], @mac[5],
        bind_ip, @bindIndex, @status2, final = data.unpack 'L>xxCCCCvCCn Z18Z64Z64nC4 LLC4C4 CCCxxxCC6 LCCx26C'
        @ip = ::IPAddr.new(ip,  Socket::AF_INET)
        @firmware_version = "#{versionh}.#{versionl}".to_f
        @bind_ip = ::IPAddr.new(bind_ip,  Socket::AF_INET)
        raise PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
      end

      def node
        node = ArtNet::Node.new
        node.ip = @ip.to_s
        node.mac = @mac.map{|b| '%02x' % b}.join(':')
        node.swin = @swin
        node.swout = @swout
        node.firmware_version = @firmware_version
        node.uni, node.subuni, node.mfg, node.shortname, node.longname, node.numports = 0,0, @manufacturer, @short_name, @long_name, @ports
        node
      end

    end

    class DMX < Base

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

    class Address < Base

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

    TYPES = {
      0x2000 => Poll,
      0x2100 => PollReply,
      0x5000 => DMX,
      0x6000 => Address
    }

    def self.load(data, sender)
      id, opcode = data.unpack 'Z7xS'
      raise PacketFormatError.new('Not an Art-Net packet') unless id === 'Art-Net'
      klass = TYPES[opcode]
      raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      packet = klass.unpack(data[10..-1], sender)
      return packet
    end

  end
end


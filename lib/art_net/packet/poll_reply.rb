module ArtNet::Packet
  class PollReply < Base

    attr_accessor :ip, :port, :vers_info, :firmware_version, :netswitch, :subswitch, :oem, :ubea, :status1, :manufacturer
    attr_accessor :short_name, :long_name, :report, :ports, :subswitch, :port_types
    attr_accessor :good_input, :good_output, :swin, :swout, :swvideo, :swmacro, :swremote, :style, :max
    attr_accessor :bind_ip, :bind_index, :status2
    
    
    # F*ckuck ArtNetPollReply
    def self.protver_check?; false; end
    def self.data_offset; 10; end
    OPCODE = 0x2100

    def unpack(data, io = nil)
      @io = io
      @opcode = OPCODE # TODO - get from packet data

      mac = []
      @port_types = []
      @good_input = []
      @good_output = []
      @swin = []
      @swout = []
      ip, @port, @vers_info, @netswitch, @subswitch, @oem, @ubea, @status1, @manufacturer,
      # N   v       n           C           C          n      C        C           n
      # @short_name, @long_name, @report, @ports, @port_types[0], @port_types[1], @port_types[2], @port_types[3],
      # #   Z18         Z64         Z64     n         C               C               C               C
      # @short_name, @long_name, @report, @ports, @port_types,
      # #   Z18         Z64         Z64     n         C4
      @short_name, @long_name, @report, @ports, 
      #   Z18         Z64         Z64     n         C4
      @port_types[0], @port_types[1], @port_types[2], @port_types[3],
      #       C             C               C               C
      # @input, @output, @swin[0], @swin[1], @swin[2], @swin[3], @swout[0], @swout[1], @swout[2], @swout[3],
      # #   V       V       C         C         C         C         C         C             C         C
      # @good_input, @good_output, @swin, @swout,
      # #   C4       C4    C4    C4
      @good_input[0], @good_input[1], @good_input[2], @good_input[3],
      #   C             C                   C               C
      @good_output[0], @good_output[1], @good_output[2], @good_output[3],
      #   C             C                       C             C
      @swin[0], @swin[1], @swin[2], @swin[3],
      #   C         C         C         C
      @swout[0], @swout[1], @swout[2], @swout[3],
      #   C       C            C           C
      @swvideo, @swmacro, @swremote, @style,
      # C           C         C   xxx   C
      mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
      # C       C       C        C       C       C 
      # bind_ip, @bindIndex, @status2, final = data.unpack 'NvvCCvCCn Z18Z64Z64nC4 C4C4C4C4 CCCxxxCa6'# VCCx26C' #TODO fix 3d realizzer error lenghth string
      bind_ip, @bind_index, @status2 = data.unpack 'NvnCCnCCn Z18Z64Z64nC4 C4C4C4C4 CCCxxxCC6 NCCx26' 
      # N         C          C    x26
      self.inspect
      @ip = IPAddr.new(ip,  Socket::AF_INET)
      @firmware_version = @vers_info ? "#{@vers_info>>8}.#{@vers_info&0xff}".to_f : "#{versionh}.#{versionl}".to_f
      @bind_ip = IPAddr.new(bind_ip,  Socket::AF_INET)
      @mac = ArtNet::MacAddr.new(mac)
      # TODO: check is `final` need?
      # raise ArtNet::PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
    end

    def node
      # node = ArtNet::Node.new
      node = ArtNet::Node.load @style
      node.ip = @ip.to_s
      node.mac = @mac
      node.swin = @swin
      node.swout = @swout
      node.firmware_version = @firmware_version
      node.uni, node.subuni, node.mfg, node.shortname, node.longname, node.numports = 0,0, @manufacturer, @short_name, @long_name, @ports
      node
    end

  end
end

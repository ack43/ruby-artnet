module ArtNet::Packet
  class PollReply < Base

    OPCODE = 0x2100

    def unpack(data)
      @swin = []
      @swout = []
      @port_types = []
      ip, versionh, versionl, @netswitch, @subswitch, @oem, @ubea, @status1, @manufacturer,
      @short_name, @long_name, @report, @ports, @port_types[0], @port_types[1], @port_types[2], @port_types[3],
      @input, @output, @swin[0], @swin[1], @swin[2], @swin[3], @swout[0], @swout[1], @swout[2], @swout[3],
      @swvideo, @swmacro, @swremote, @style, mac,
      bind_ip, @bindIndex, @status2, final = data.unpack 'NxxCCCCvCCn Z18Z64Z64nC4 VVC4C4 CCCxxxCa6 VCCx26C'
      @ip = IPAddr.new(ip,  Socket::AF_INET)
      @firmware_version = "#{versionh}.#{versionl}".to_f
      @bind_ip = IPAddr.new(bind_ip,  Socket::AF_INET)
      @mac = ArtNet::MacAddr.new(mac)
      raise PacketFormatError.new('Bad data for ' + self.class.to_s) unless final.nil?
    end

    def node
      node = ArtNet::Node.new
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

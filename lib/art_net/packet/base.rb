module ArtNet::Packet
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
      ArtNet::Packet.types.invert[self.class]
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
end

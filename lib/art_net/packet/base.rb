module ArtNet::Packet
  class Base

    attr_writer :net_info

    def self.unpack(data, net_info)
      p = self.new
      puts 'data.inspect'
      puts data.inspect
      puts 'p.inspect'
      puts p.inspect
      p.unpack(data)
      net_info[4] = Time.now
      p.net_info = net_info
      puts 'p.inspect after '
      puts p.inspect
      p
    end

    def opcode
      self.class.const_get('OPCODE')
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
      raise ArtNet::PacketFormatError.new("Bad protocol version #{ver}") unless ver == PROTVER
    end

  end
end

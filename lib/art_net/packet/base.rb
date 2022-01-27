module ArtNet::Packet
  class Base

    # TODO
    def inspect(full = false)
      attrs = full ? instance_variables : (instance_variables - [:@channels, :data])
      attributes_as_nice_string = attrs.collect { |name|
        if instance_variable_defined?(name)
          "#{name}: #{instance_variable_get(name)}"
        end
      }.compact.join(", ")
      "#<#{self.class} #{attributes_as_nice_string}>"
    end

    attr_accessor :io
    attr_accessor :raw_data
    def initialize(opcode = nil, io = nil)
      unless opcode.is_a?(Integer)
        io ||= opcode
        opcode = nil
      end
      @opcode = opcode
      @io = io
    end


    attr_writer :net_info

    def self.unpack(data, net_info)
      p = self.new
      # puts 'new packet'
      # puts 'data.inspect'
      # puts data.inspect
      p.unpack(data, self)
      if net_info
        net_info[4] ||= Time.now
        p.net_info = net_info
      end
      # puts 'p.inspect after '
      # puts p.inspect
      # puts ""
      # puts ""
      p
    end

    def pack
      puts "i can pack "
    end

    def opcode
      @opcode || self.class.const_get('OPCODE')
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

    # F*ckuck ArtNetPollReply
    def self.protver_check?; true; end
    def self.data_offset; 12; end

    private

    def check_version(ver)
      raise ArtNet::PacketFormatError.new("Bad protocol version #{ver}") unless ver == PROTVER
    end

  end
end

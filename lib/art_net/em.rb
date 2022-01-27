class ArtNet::EMServer < EM::Connection

  attr_reader :artnet

  def initialize
    @artnet = ArtNet::IO.new(false)
    puts "init emserver"
  end

  def receive_data(data)
    # puts "receive_data emserver"
    # puts data.inspect
    sender = Socket.unpack_sockaddr_in(get_peername)
    #TODO: sender_addrinfo and EM get_peername
    sender = ["AF_INET", sender[0], sender[1], sender[1]] 
    @artnet.process_data(data, sender)
    # EM.stop
  end

  def self.init_me(address = '0.0.0.0', port = ArtNet::IO::PORT, &block)
    puts "ArtNet::EMServer init_me (#{address}:#{port})"
    # @artnet = ArtNet::IO.new(false)
    # EM::open_datagram_socket('192.168.0.203', ArtNet::IO::PORT, self, &block)
    EM::open_datagram_socket(address, port, self, &block)
  end

  

  def self.test_me &block
    # EM::open_datagram_socket('192.168.0.203', ArtNet::IO::PORT, self) do |s|
    init_me do |s|
      s.artnet.on :poll do |data|
        puts "Artnet OpPoll"# - #{data[:packet].inspect} (#{data.inspect})"
      end
      s.artnet.on :dmx do |data|
        puts "Artnet DMX - #{data[:packet].sequence}"# - #{data[:packet].inspect} (#{data.inspect})"
      end
      s.artnet.on :message do |data|
        puts "Artnet msg - #{data[:packet] && data[:packet].opcode.to_s(16)}"
      end
      block.call(s) if block_given?
    end
  end

end
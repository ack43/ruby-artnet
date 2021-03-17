require 'async/io'

require 'ipaddr'
require 'socket'
module ArtNet
  class IO
    attr_reader   :rx_data, :local_ip, :netmask, :broadcast_ip, :port

    def initialize(options = {})
      @port    = options[:port] || 6454
      @network = options[:network] || "192.168.0.100" #"2.0.0.0"
      @netmask = options[:netmask] || "255.255.255.0"
      @broadcast_ip = get_broadcast_ip @network, @netmask
      @local_ip = get_local_ip @network
      setup_connection
      @rx_data = Hash.new() {|h, i| h[i] = Array.new(512, 0) }
      @nodes = {}
      @callbacks = {}
    end

    def process_events
      begin
        puts @udp.inspect
        # while (data = @udp.recvfrom_nonblock(65535))[0] do
        while (data = @udp.recvfrom(65535))[0] do
          process_rx_data(*data)
        end
      rescue Errno::EAGAIN
        # no data to process!
        return nil
      end
    end

    # send an ArtDmx packet for a specific universe
    # FIXME: make this able to unicast via a node instance method
    def send_update(uni, channels)
      p = Packet::DMX.new
      p.universe = uni
      p.channels = channels
      transmit p
    end

    # send an ArtPoll packet
    # normal process_events calls later will then collect the results in @nodes
    def poll_nodes
      # clear any list of nodes we already know about and start fresh
      @nodes.clear
      transmit Packet::Poll.new
    end

    def nodes
      @nodes.values
    end

    def node(ip)
      @nodes[ip]
    end

    def on(name, &block)
      @callbacks[name] = block
    end

    def transmit(packet, node=nil)
      if node.nil?
        @udp_bcast.send packet.pack, 0, @broadcast_ip, @port
      else
        @udp.send packet.pack, 0, node.ip, @port
      end
    end

    def reconnect(ip, netmask)
      @local_ip = ip
      @netmask = netmask
      @network = (IPAddr.new(@local_ip) & IPAddr.new(@netmask)).to_s
      @broadcast_ip = get_broadcast_ip @network, @netmask
      poll_nodes
    end

    private

    def callback(name, *args)
      method = @callbacks[name]
      method.call(*args) if method
    end

    # given a network, finds the local interface IP that would be used to reach it
    def get_local_ip(network)
      UDPSocket.open do |sock|
        sock.connect network, 1
        sock.addr.last
      end
    end

    # given a network, returns the broadcast IP
    def get_broadcast_ip(network, mask)
      (IPAddr.new(network) | ~IPAddr.new(mask)).to_s
    end

    def process_rx_data data, sender
      packet = Packet.load(data, sender)
      case packet
        when Packet::Poll
        when Packet::PollReply
          if packet.node != @nodes[sender[3]]
            @nodes[sender[3]] = packet.node
            callback :node_update, nodes
          end
        when Packet::DMX
          if @rx_data[packet.universe][0...packet.length] != packet.channels
            @rx_data[packet.universe][0...packet.length] = packet.channels
            callback :dmx, packet.universe, @rx_data[packet.universe]
          end
      end
      callback(:message, packet) if packet
    end

    def setup_connection
      @udp = UDPSocket.new
      @udp.bind "0.0.0.0", @port
      @udp_bcast = UDPSocket.new
      @udp_bcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

  end

end

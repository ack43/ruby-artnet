require 'async/io'

require 'ipaddr'
require 'socket'
module ArtNet
  class IO

    PORT = "6454"
    NETMASK = "255.255.255.0"
    attr_reader :sequence
    def up_sequence
      current = @sequence.clone
      @sequence = (@sequence % 255 + 1)
      current
    end
    attr_reader   :rx_data, :local_ip, :netmask, :broadcast_ip, :port

    def initialize(options = {})
      @port    = options && options[:port] || PORT
      @network = options && options[:network] || "192.168.0.100" #"2.0.0.0"
      @netmask = options && options[:netmask] || NETMASK
      @broadcast_ip = get_broadcast_ip @network, @netmask
      @local_ip = get_local_ip @network
      setup_connection(!options)
      @rx_data = Hash.new {|h, i| h[i] = Array.new(512, 0) }
      @nodes = {}
      @callbacks = {}
      @sequence = 1
    end

    def process_events(type = nil)
      begin
        # puts 'process_events'
        # while (data = @udp.recvfrom_nonblock(65535))[0] do
        while (data = @udp.recvfrom(65535))[0] do
          # puts 'process_rx_data'
          # puts data.inspect
          # raise "1`111"
          data = process_rx_data(*data)
          
          # puts 'process_rx_data after '
          return data
          # process_rx_data(*data)
        end
      rescue Errno::EAGAIN
        # no data to process!
        return nil
      end
    end

    # send an ArtDmx packet for a specific universe
    # FIXME: make this able to unicast via a node instance method
    def send_update(uni, channels, offset = 0)
      puts "send new dmx"
      packet = Packet::DMX.new(self)
      limit = channels.length+offset # TODO: limit as 512
      packet.universe = uni
      packet.channels = @rx_data[uni]
      packet.channels[offset...limit] = channels
      # puts "packet.inspect"
      # puts packet.inspect
      # puts packet.pack
      transmit packet
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
    
    def process_data data, sender
      # puts 'process_data'
      # puts data.inspect
      process_rx_data data, sender
    end

    private

    def callback(name, *args)
      method = @callbacks[name]
      method.call(*args) if method
    end

    # given a network, finds the local interface IP that would be used to reach it
    def get_local_ip(network)
      # puts 'Socket.ip_address_list'
      # puts Socket.ip_address_list.inspect
      # raise '111'
      #TODO: Socket.ip_address_list
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
      # raise "22222"
      packet = Packet.load(data, sender)
      callback_data = {
        sender: sender,
        packet: packet
      }
      case packet
      when Packet::Poll
        callback :poll, callback_data
      when Packet::PollReply
        if packet.node != @nodes[sender[3]]
          @nodes[sender[3]] = packet.node
          callback :node_update, callback_data.merge({
            node: packet.node, 
            nodes: nodes
          })
        end
      when Packet::DMX
        puts "dmx"
        if @rx_data[packet.universe][0...packet.length] != packet.channels
          @rx_data[packet.universe][0...packet.length] = packet.channels
          # callback :output, callback_data.merge({
          #   universe: packet.universe, 
          #   data: @rx_data[packet.universe]
          # })] #TODO

        end
        callback :dmx, callback_data.merge({
          universe: packet.universe, 
          data: @rx_data[packet.universe][0...packet.length]
        })

      when Packet::DiagData
        callback :diag_data, callback_data

      when Packet::Base
        puts "packet - #{packet.inspect}"
      when nil
        puts "unknown packet. class not found"
      else
        puts "some shit happens"
      end
      callback(:message, callback_data) if packet
    end

    def setup_connection(only_bcast = false)
      unless only_bcast
        @udp = UDPSocket.new
        @udp.bind "0.0.0.0", @port rescue false
      end
      @udp_bcast = UDPSocket.new
      @udp_bcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

  end

end

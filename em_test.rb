#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
require 'art_net'


def func1(step) 
  step %= 255
  step
end
def func2(step) 
  step %= 255
  step += 100
  step % 255
end
def func3(step) 
  step %= 255
  step *= -1
  step % 255
end




# require 'em/pure_ruby'
require 'eventmachine'

trap(:INT) { puts "int"; EM.stop }
trap(:TERM){ puts "term"; EM.stop }


@artnet = ArtNet::IO.new(false)
@artnet.on :poll do |data|
  puts "Artnet OpPoll"# - #{data[:packet].inspect} (#{data.inspect})"
end
@artnet.on :dmx do |data|
  puts "Artnet DMX - #{data[:packet].sequence}"# - #{data[:packet].inspect} (#{data.inspect})"
end
@artnet.on :message do |data|
  puts "Artnet msg - #{data[:packet] && data[:packet].opcode.to_s(16)}"
end
step = 0
EM.run do
  EM::open_datagram_socket('192.168.0.203', ArtNet::IO::PORT, nil) do |s|
    puts s.instance_variable_set(:@artnet, @artnet)
    def s.receive_data data
      # puts 'receive_data'
      sender = Socket.unpack_sockaddr_in(get_peername)
      #TODO: sender_addrinfo and EM get_peername
      sender = ["AF_INET", sender[0], sender[1], sender[1]] 
      @artnet.process_data(data, sender)
      # EM.stop
    end
  end

  EM.add_periodic_timer(0.5) {
    step += 10
    @artnet.send_update 0, [func1(step),func2(step),func3(step), func1(step),func2(step),func3(step)], 0
  }
  # EM::open_datagram_socket('127.0.0.1', ArtNet::IO::PORT) do |c|
  #   c.send_datagram 'hello', '192.168.0.255', ArtNet::IO::PORT
  # end
end


# # temporary test script used to test things as they're being built
# # will be replaced with real tests :)
# artnet = ArtNet::IO.new network: "192.168.0.255", netmask: "255.255.255.0"
# # artnet.poll_nodes
# artnet.on :poll do |data|
#   puts "Artnet OpPoll - #{data[:packet].inspect} (#{data.inspect})"
# end
# artnet.on :dmx do |sender, packet|
#   puts "Artnet DMX - #{data[:packet].inspect} (#{data.inspect})"
# end
# step = 0
# while(step += 10) do
#   artnet.send_update 1, [Random.rand(255)] if Random.rand(10) == 0
#   # artnet.process_events
#   # artnet.send_update 1, [func1(step),func2(step),func3(step), func1(step),func2(step),func3(step)], 4
#   # puts artnet.rx_data
#   #puts "Seeing #{artnet.nodes.length} node(s) on the network:"
#   #artnet.nodes.each do |node|
#   #  puts "#{node.ip}\t#{node.shortname}\t#{node.longname}"
#   #end
#   sleep 0.1
# end
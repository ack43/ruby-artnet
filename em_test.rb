#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
# require 'em/pure_ruby'
require 'eventmachine'
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




trap(:INT) { puts "int"; EM.stop }
trap(:TERM){ puts "term"; EM.stop }


# @artnet = ArtNet::IO.new(false)
# @artnet.on :poll do |data|
#   puts "Artnet OpPoll"# - #{data[:packet].inspect} (#{data.inspect})"
# end
# @artnet.on :dmx do |data|
#   puts "Artnet DMX - #{data[:packet].sequence}"# - #{data[:packet].inspect} (#{data.inspect})"
# end
# @artnet.on :message do |data|
#   puts "Artnet msg - #{data[:packet] && data[:packet].opcode.to_s(16)}"
# end
# step = 0
EM.run do
  ArtNet::EMServer.test_me do |s|
    s.artnet.off :dmx
    s.artnet.on :dmx do |data|
      puts "msg - #{data[:packet].universe} #{data[:packet].length}: #{data[:packet].channels.join(" ")}"
    end
  end
  # EM::open_datagram_socket('192.168.0.203', ArtNet::IO::PORT, nil) do |s|
  #   puts s.instance_variable_set(:@artnet, @artnet)
  #   def s.receive_data data
  #     # puts 'receive_data'
  #     sender = Socket.unpack_sockaddr_in(get_peername)
  #     #TODO: sender_addrinfo and EM get_peername
  #     sender = ["AF_INET", sender[0], sender[1], sender[1]] 
  #     @artnet.process_data(data, sender)
  #     # EM.stop
  #   end
  # end

  # EM.add_periodic_timer(0.5) {
  #   step += 10
  #   @artnet.send_update 0, [func1(step),func2(step),func3(step), func1(step),func2(step),func3(step)], 0
  # }
  # EM::open_datagram_socket('127.0.0.1', ArtNet::IO::PORT) do |c|
  #   c.send_datagram 'hello', '192.168.0.255', ArtNet::IO::PORT
  # end
end
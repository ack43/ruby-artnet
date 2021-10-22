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

# temporary test script used to test things as they're being built
# will be replaced with real tests :)
artnet = ArtNet::IO.new network: "192.168.0.255", netmask: "255.255.255.0"
artnet.poll_nodes
artnet.on :poll do |data|
  # puts "Artnet OpPoll - #{data[:packet].inspect} (#{data.inspect})"
end
artnet.on :dmx do |data|
  # puts "Artnet DMX - #{data[:packet].inspect} (#{data.inspect})"
  puts data[:packet].sequence
  puts data[:universe]
  # puts data[:data].inspect
end
artnet.on :message do |data|
  # puts "Artnet msg - #{data.inspect}"
end
step = 0
while(step += 10) do
  # artnet.send_update 0, [Random.rand(255)] if Random.rand(10) == 0
  # puts 'process_events'
  artnet.process_events
  # puts 'after process_events'
  # artnet.send_update 0, [func1(step),func2(step),func3(step), func1(step),func2(step),func3(step)], 149
  # puts artnet.rx_data
  #puts "Seeing #{artnet.nodes.length} node(s) on the network:"
  #artnet.nodes.each do |node|
  #  puts "#{node.ip}\t#{node.shortname}\t#{node.longname}"
  #end
  # puts 'sleep'
  # sleep 0.5
end
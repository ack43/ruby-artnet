#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
require 'art_net'

# temporary test script used to test things as they're being built
# will be replaced with real tests :)
artnet = ArtNet::IO.new :network => "192.168.0.100", :netmask => "255.255.255.0"
# artnet.poll_nodes
while(true) do
  artnet.process_events
  # artnet.send_update 2, [10,20,30]
  #puts artnet.rx_data[0][0]
  #puts "Seeing #{artnet.nodes.length} node(s) on the network:"
  #artnet.nodes.each do |node|
  #  puts "#{node.ip}\t#{node.shortname}\t#{node.longname}"
  #end
  sleep 0.1
end


require 'art_net/packet'

module ArtNet::IO::Nodes
    
  # attr_reader :nodes

  # send an ArtPoll packet
  # normal process_events calls later will then collect the results in @nodes
  def poll_nodes
    # clear any list of nodes we already know about and start fresh
    @nodes.clear

    _poll = ArtNet::Packet::Poll.new
    _poll.priority = 250
    puts "%08b" % _poll.talk_to_me
    puts _poll.inspect
    transmit _poll
  end

  def nodes
    @nodes.values
  end

  def node(ip)
    @nodes[ip]
  end
  
end

require 'art_net/io'
require 'art_net/node'
require 'art_net/packet'


if defined?(EM) or defined?(EventMachine)
  require 'art_net/em'
end

module ArtNet
end

require 'ipaddr'
require 'art_net/mac_addr'
require "art_net/packet/base"

module ArtNet

  class PacketFormatError < RuntimeError
  end

  module Packet

    ID = 'Art-Net'
    PROTVER = 14

    @@types = {}

    def self.types
      @@types
    end

    def self.register(klass)
      @@types[klass.const_get('OPCODE')] = klass
    end

    def self.load(data, sender)
      puts 'all data'
      puts data.inspect
      puts data[...10].inspect
      id, opcode = data.unpack 'Z7xv'
      puts types.inspect
      puts id.inspect
      puts opcode.inspect
      raise PacketFormatError.new('Not an Art-Net packet') unless id === 'Art-Net'
      klass = types[opcode]
      raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      packet = klass.unpack(data[10..], sender)
      return packet
    end

    {
      address: 'Address',
      dmx: 'DMX',
      poll: 'Poll',
      poll_reply: 'PollReply'
    }.each_pair do |file,  klass|
      require "art_net/packet/#{file}"
      register const_get(klass)
    end

  end
end


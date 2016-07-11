require 'ipaddr'
require 'art_net/mac_addr'
%w(base address dmx poll poll_reply).each do |file|
  require "art_net/packet/#{file}"
end

module ArtNet

  class PacketFormatError < RuntimeError
  end

  module Packet

    ID = 'Art-Net'
    PROTVER = 14

    @@types = {
      0x2000 => Poll,
      0x2100 => PollReply,
      0x5000 => DMX,
      0x6000 => Address
    }

    def self.types
      @@types
    end

    def self.register(opcode, klass)
      @@types[opcode] = klass
    end

    def self.load(data, sender)
      id, opcode = data.unpack 'Z7xS'
      raise PacketFormatError.new('Not an Art-Net packet') unless id === 'Art-Net'
      klass = types[opcode]
      raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      packet = klass.unpack(data[10..-1], sender)
      return packet
    end

  end
end


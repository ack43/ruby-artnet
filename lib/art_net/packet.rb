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

    def self.load(data, sender = nil)
      id, opcode, protver = data.unpack 'Z8vn'
      raise PacketFormatError.new('Not an Art-Net packet (id)')     unless id === ID 
      klass = @@types[opcode]
      raise PacketFormatError.new('Not an Art-Net packet (protver') unless protver === PROTVER if klass.protver_check? # alt for Base.check_version(ver)
      # raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      
      if klass.nil?
        puts "Unknown opcode 0x#{opcode.to_s(16)}"
        packet = Base.new(opcode)
        packet.raw_data = data
      else
        packet = klass.unpack(data[klass.data_offset..], sender)
      end
      return packet
    end
    def self.safe_load(data, sender = nil)
      id, opcode, protver = data.unpack 'Z8vn'
      return false unless id === ID 
      klass = @@types[opcode]
      return nil unless protver === PROTVER if klass.protver_check? # alt for Base.check_version(ver)
      # raise PacketFormatError.new("Unknown opcode 0x#{opcode.to_s(16)}") if klass.nil?
      
      if klass.nil?
        # return nil
        puts "Unknown opcode 0x#{opcode.to_s(16)}"
        packet = Base.new(opcode)
        packet.raw_data = data
      else
        packet = klass.unpack(data[klass.data_offset..], sender)
      end
      return packet
    end

    {
      address: 'Address',
      dmx: 'DMX',
      poll: 'Poll',
      poll_reply: 'PollReply',
      sync: 'Sync',
      diag_data: 'DiagData'
    }.each_pair do |file,  klass|
      require "art_net/packet/#{file}"
      register const_get(klass)
    end

  end
end


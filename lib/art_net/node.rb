module ArtNet
  class Node
    attr_accessor :ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout
  end
end

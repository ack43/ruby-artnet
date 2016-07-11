module ArtNet
  class Node

    attr_accessor :ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout

    def ==(other)
      fields = [:ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout]
      fields.all?{|field| other.respond_to?(field) && send(field) == other.send(field)}
    end

  end
end

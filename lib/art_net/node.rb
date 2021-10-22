module ArtNet
  class Node

    @@styles = {}

    def self.styles
      @@styles
    end

    def self.register(klass)
      @@styles[klass.const_get('CODE')] = klass
    end


    attr_accessor :ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout

    def ==(other)
      ret = other.class == self.class
      return ret unless ret

      fields = [:ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout]
      fields.all?{|field| other.respond_to?(field) && send(field) == other.send(field)}
    end

    # [:node, :controller, :media, :route, :backup, :config, :diag, :visual].each do |meth|
    #   define_method "#{meth}?" do false end
    # end
    
    def self.load(code)
      # klass = self.descendants.detect { |klass|
      #   klass.CODE == code
      # }
      klass = styles[code]
      if klass
        klass.new
      else
        puts "Device for code #{code} not found!!"
      end
    end

    require 'art_net/node/styles'
    {
      node: 'Node',
      controller: 'Controller',
      media: 'Media',
      route: 'Route',
      backup: 'Backup',
      config: 'Config',
      # diag: 'Config',
      visual: 'Visual'
    }.each_pair do |file,  klass|
      meth = file
      prefix = "St"
      # require "art_net/node/#{file}"
      register const_get("#{prefix}#{klass}")
      define_method "#{meth}?" do false end
    end
    define_method "diag?" do false end # diag: 'Config',

  end
end
# require 'art_net/node/styles'

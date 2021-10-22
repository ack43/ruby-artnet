module ArtNet
  class MacAddr

    def initialize(data = nil)
      @addr = nil
      if data.nil?
        @addr = [0,0,0,0,0,0]
      # elsif data.is_a?(Integer)
      #   @addr = [data].unpack 'C*'
      elsif data.length == 6
        @addr = data
        # @addr = data.unpack 'C*'
      else
        data.gsub!(/[\s:-]*/, '').upcase
        if data.length == 12 && data.all?{|c| ('A'..'F').include?(c) || ('0'..'9').include?(c)}
          @addr = data.scan(/../).map(&:hex)
        end
      end
      raise "Invalid MAC address #{data.inspect}" if @addr.nil?
    end

    def ==(other)
      to_s == other.to_s
    end

    def to_s
      @addr.map{|b| '%02X' % b}.join(':')
    end

    def to_bytes
      @addr.pack 'C6'
    end

  end
end

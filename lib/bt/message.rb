module BT
  class Message
    attr_reader :length, :type

    def self.from_io(io)
      length = io.read(4).unpack("N")[0]
      puts "length: #{length}"
      body = io.read(length) if length > 0
      body ||= ""

      type = body.getbyte(0)
      payload = body[1..-1]

      new(length, type, payload)
    end

    def initialize(length, type, payload)
      @length = length
      @payload

      @type = case type
      when nil
        :keep_alive
      when 0
        :choke
      when 1
        :unchoke
      when 2
        :interested
      when 3
        :uninterested
      when 4
        :have
      when 5
        :bitfield
      when 6
        :request
      when 7
        :piece
      when 8
        :cancel
      end
    end

    def inspect
      "#<BT::Message #{type}>"
    end

  end
end

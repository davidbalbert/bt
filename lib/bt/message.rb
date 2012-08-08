module BT
  MESSAGE_IDS = [:choke, :unchoke, :interested, :uninterested, :have,
                 :bitfield, :request, :piece, :cancel]
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

      @type = if type.nil?
        :keepalive
      else
        MESSAGE_IDS[type]
      end
    end

    def inspect
      "#<BT::Message #{type}>"
    end

  end
end

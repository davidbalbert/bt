module BT
  class Message
    MESSAGE_SYMS = [:choke, :unchoke, :interested, :uninterested, :have,
                   :bitfield, :request, :piece, :cancel]

    MESSAGE_IDS = {:keepalive => nil, :choke => 0, :unchoke => 1, :interested =>
                   2, :uninterested => 3, :have => 4, :bitfield => 5, :request =>
                   6, :piece => 7, :cancel => 8}

    attr_reader :length, :type, :payload

    def self.from_io(io)
      length = io.read(4).unpack("N")[0]
      puts "length: #{length}"
      body = io.read(length) if length > 0
      body ||= ""

      type = body.getbyte(0)
      payload = body[1..-1]

      new(length, type, payload)
    end

    def self.keepalive
      new(0, nil, "")
    end

    def self.interested
      new(1, MESSAGE_IDS[:interested], "")
    end

    def self.request(index, offset, length)
      payload = [index, offset, length].pack("NNN")
      new(13, MESSAGE_IDS[:request], payload)
    end

    def initialize(length, type, payload)
      @length = length
      @payload = payload

      @type = if type.nil?
        :keepalive
      else
        MESSAGE_SYMS[type]
      end
    end

    def inspect
      "#<BT::Message #{@type}>"
    end

    def to_s
      out = [@length].pack("N")
      out << [MESSAGE_IDS[@type]].pack("C") if MESSAGE_IDS[@type]
      out << @payload

      out
    end
  end

  class Block
    attr_reader :index, :offset, :data, :length

    def initialize(index, offset, data)
      @index = index
      @offset = offset
      @data = data
      @length = data.bytesize
    end

    def inspect
      "#<BT::Block (piece index: #{@index}, offset: #{@offset}, length: #{@length})>"
    end
  end
end

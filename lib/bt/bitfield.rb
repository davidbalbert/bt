module BT
  class BitField
    include Enumerable

    attr_reader :length
    alias size length
    alias count length

    def initialize(str, length)
      @data = str.dup
      @length = length
    end

    def [](index)
      return nil if index.abs >= @length

      @data.getbyte(index / 8) & (1 << (7 - (index % 8))) > 0 ? 1 : 0
    end

    def []=(index, val)
      raise IndexError, "index #{index} out of bounds" if index.abs >= @length

      byte = @data.getbyte(index / 8)

      if !val || val == 0
        val = 0
        result = byte & (255 ^ (1 << (7 - index % 8)))
      else
        val = 1
        result = byte | 1 << (7 - index % 8)
      end

      @data.setbyte(index / 8, result)

      val
    end

    def each
      return to_enum unless block_given?

      @length.times do |i|
        yield self[i]
      end
    end

    def to_s
      self.map { |i| i.to_s }.join
    end

    def inspect
      "#<BT::BitField [#{to_s}]>"
    end
  end
end

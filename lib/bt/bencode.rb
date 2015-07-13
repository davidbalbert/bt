class String
  def bencode
    "#{bytesize}:#{self}"
  end
end

class Array
  def bencode
    "l#{map(&:bencode).join}e"
  end
end

class Integer
  def bencode
    "i#{to_s}e"
  end
end

class Hash
  def bencode
    sorted = sort { |(k1, _), (k2, _)| k1.to_s <=> k2.to_s }

    "d#{sorted.map { |(k, v)| k.to_s.bencode + v.bencode }.join}e"
  end
end

module BT
  module Bencode
    class << self
      def decode(s)
        Decoder.new(s).decode
      end

      def encode(o)
        o.bencode
      end
    end

    class ParseError < StandardError; end

    class Decoder
      attr_reader :input, :pos

      def initialize(input)
        @input = input.b
        @pos = 0
      end

      def decode
        case peek
        when 'i'
          decode_integer
        when 'l'
          decode_list
        when 'd'
          decode_dict
        when /\d/
          decode_string
        else
          raise ParseError, "Expecting to parse value, got '#{peek}'"
        end
      end

      private

      def decode_list
        shift # 'l'

        a = []

        until peek == 'e'
          a << decode
        end

        shift # 'e'

        a
      end

      def decode_integer
        shift # 'i'

        s = "".b

        until peek == 'e'
          s << shift
        end

        shift # 'e'

        s.to_i
      end

      def decode_dict
        shift # 'd'

        h = {}

        until peek == 'e'
          raise ParseError, "Expecting to parse a string, got '#{peek}'" unless peek =~ /\d/

          h[decode_string] = decode
        end

        shift # 'e'

        h
      end

      def decode_string
        s = "".b

        until peek == ':'
          s << shift
        end

        shift # ':'


        len = s.to_i
        res = "".b

        len.times do
          res << shift
        end

        res
      end

      def peek
        input[pos]
      end

      def shift
        input[pos]
      ensure
        @pos += 1
      end
    end
  end
end

require 'thread'
require 'socket'

module BT
  PROTOCOL_NAME = "BitTorrent protocol"

  class Peer
    attr_reader :ip, :port, :peer_id

    def initialize(ip, port, info_hash, my_peer_id)
      @ip = ip
      @port = port
      @info_hash = info_hash
      @my_peer_id = my_peer_id

      @am_choking = true
      @am_interested = false
      @peer_choking = true
      @peer_interested = false
    end

    def start
      Thread.new do
        @socket = TCPSocket.new(@ip.to_s, @port)
        @socket.write("\x13#{PROTOCOL_NAME}\0\0\0\0\0\0\0\0#{@info_hash}#{@my_peer_id}")

        resp = @socket.read(49)
        resp << @socket.read(resp.getbyte(0))

        begin
          parse_handshake(resp)

          loop do
            p Message.from_io(@socket)
          end
        rescue e
          puts e.message
        ensure
          @socket.close
        end
      end.join
    end

    def parse_handshake(handshake)
      peer_protocol_length = handshake.getbyte(0)
      peer_protocol, @extensions, info_hash, @peer_id = handshake[1..-1].unpack("a#{peer_protocol_length}a8a20a20")

      if peer_protocol != PROTOCOL_NAME
        raise PeerError, "#{inspect} says: Unsupported protocol '#{peer_protocol}'"
      end

      if info_hash != @info_hash
        raise PeerError, "#{inspect} says: Peer's info_hash #{info_hash.inspect} is different from our info_hash #{@my_info_hash.inspect}"
      end

      if @peer_id == @my_peer_id
        raise PeerError, "#{inspect} says: Won't connect to myself"
      end
    end

    def inspect
      "#<BT::Peer:#{@ip.to_s}:#{@port}#{@peer_id ? " id=#{@peer_id}" : ""}>"
    end
  end

  class PeerError < StandardError; end
end

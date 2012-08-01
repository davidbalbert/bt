require 'thread'
require 'socket'

module BT
  class Peer
    attr_reader :ip, :port

    def initialize(ip, port, info_hash, peer_id)
      @ip = ip
      @port = port
      @info_hash = info_hash
      @peer_id

      @am_choking = true
      @am_interested = false
      @peer_choking = true
      @peer_interested = false
    end

    def start
      Thread.new do
        @socket = TCPSocket.new(@ip.to_s, @port)
        @socket.write("\x13BitTorrent protocol\0\0\0\0\0\0\0\0#{@info_hash}#{@peer_id}")

        resp = @socket.read(49)
        resp << @socket.read(resp.bytes.to_a[0])
        p resp

        @socket.close
      end.join
    end

    def inspect
      "#<BT::Peer: #{@ip.to_s}:#{@port}>"
    end
  end
end

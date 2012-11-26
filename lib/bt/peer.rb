require 'thread'
require 'socket'

module BT
  class Peer
    PROTOCOL_NAME = "BitTorrent protocol"
    KEEP_ALIVE_TIME = 120

    attr_reader :ip, :port, :peer_id, :am_choking, :am_interested, :peer_choking, :peer_interested

    alias am_choking? am_choking
    alias am_interested? am_interested

    alias peer_choking? peer_choking
    alias peer_interested? peer_interested

    alias choked? peer_choking?
    alias interested? am_interested?

    def initialize(ip, port, metainfo, my_peer_id)
      @ip = ip
      @port = port
      @metainfo = metainfo
      @info_hash = metainfo.info_hash
      @my_peer_id = my_peer_id

      # what we're doing to the peer
      @am_choking = true
      @am_interested = false

      # what the peer is doing to us
      @peer_choking = true
      @peer_interested = false

      @send_queue = Queue.new

      @running = false
      @running_lock = Mutex.new

      # the unix epoch, very long ago
      @last_send_time = Time.at(0)
      @last_send_time_lock = Mutex.new
    end

    def start
      @running = true

      Thread.new do
        @socket = TCPSocket.new(@ip.to_s, @port)
        @socket.write("\x13#{PROTOCOL_NAME}\0\0\0\0\0\0\0\0#{@info_hash}#{@my_peer_id}")

        resp = @socket.read(49)
        resp << @socket.read(resp.getbyte(0))

        begin
          parse_handshake(resp)

          # No error after our handshake, let's spin up our sender queue
          Thread.new do
            loop do
              message = @send_queue.pop
              break unless running?

              puts "Sending #{message.inspect}"
              @socket.write(message.to_s)

              @last_send_time_lock.synchronize do
                @last_send_time = Time.now
              end
            end
          end

          # and our keep alive queue
          Thread.new do
            loop do
              seconds_since_last_send = Time.now - last_send_time
              if seconds_since_last_send < KEEP_ALIVE_TIME
                sleep seconds_since_last_send
              else
                sleep KEEP_ALIVE_TIME
              end

              break unless running?

              @last_send_time_lock.synchronize do
                now = Time.now
                if now - @last_send_time >= KEEP_ALIVE_TIME
                  @send_queue << Message.keepalive

                  # not exactly last sent time, it might go out a bit later,
                  # but it's good enough to ensure that we sleep for close to
                  # KEEP_ALIVE_TIME the next time around the loop
                  @last_send_time = now
                end
              end
            end
          end

          loop do
            message = Message.from_io(@socket)
            p message

            case message.type
            when :keepalive
              # TODO: reset a 2 minute timer. somewhere else drop the
              # connection if they haven't responded for over two minutes
            when :bitfield
              @bitfield = BitField.new(message.payload, @metainfo.piece_count)
            when :unchoke
              @peer_choking = false

              # XXX: This is only temporary. It should be controlled by an
              # outside coordinating object
              @send_queue << Message.interested
              @am_interested = true
            end
          end
        rescue Exception => e
          puts e.message
        ensure
          @socket.close
          @running_lock.synchronize do
            @running = false
          end
        end
      end
    end

    def running?
      @running_lock.synchronize do
        @running
      end
    end

    def last_send_time
      @last_send_time_lock.synchronize do
        @last_send_time
      end
    end

    def inspect
      "#<BT::Peer:#{@ip.to_s}:#{@port}#{@peer_id ? " id=#{@peer_id}" : ""}>"
    end

    private

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
  end

  class PeerError < StandardError; end
end

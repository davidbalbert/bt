require 'thread'
require 'socket'

module BT
  PROTOCOL_NAME = "BitTorrent protocol"

  class Peer
    KEEP_ALIVE_TIME = 120

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
            p Message.from_io(@socket)
          end
        rescue Exception => e
          puts e.message
        ensure
          @socket.close
          @running_lock.synchronize do
            @running = false
          end
        end
      end.join
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

    def inspect
      "#<BT::Peer:#{@ip.to_s}:#{@port}#{@peer_id ? " id=#{@peer_id}" : ""}>"
    end
  end

  class PeerError < StandardError; end
end

module BT
  class Client
    DEFAULT_PEER_ID = "-RB#{BT::VERSION_STRING}-#{$$}-#{Time.now.to_i}".encode("BINARY")[0...20]
    DEFAULT_PORT = 6881

    attr_reader :metainfo, :peer_id, :peers, :port

    def initialize(peer_id=nil, port=nil)
      @peer_id = peer_id || DEFAULT_PEER_ID
      @port = port || DEFAULT_PORT
      @torrents = {}
    end

    def add(torrent, destination)
      metainfo = MetaInfo.new(torrent)

      metainfo.write_files(destination)

      peers = []

      metainfo.trackers.each do |t|
        peers += t.announce(self, metainfo)
      end

      # XXX: Running OpenTracker locally gives me myself in the peers list.
      # Make sure to remove myself here. Is this normal behavior?
      #
      # Once we're connecting to all peers, we should remove this code in favor
      # of disconnecting when we receive our own peer_id in the handshake
      Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).each do |ip|
        peers = peers.reject { |peer| peer.ip == ip && peer.port == @port }
      end

      torrent = Torrent.new(metainfo, destination, peers)
      @torrents[metainfo.info_hash] = torrent

      peers[0].start

      metainfo.info_hash
    end
  end

  class Torrent < Struct.new(:metainfo, :destination, :peers)
  end
end

# client = BT::Client.new
# client.add('/path/to/metainfo.torrent', '/output/path')
# => info_hash
#
# client[info_hash]
# => #<MetaInfo>

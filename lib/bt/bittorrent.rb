module BT
  class BitTorrent
    attr_reader :metainfo, :peer_id, :peers, :port

    def initialize(torrent, destination, peer_id=nil)
      @metainfo = MetaInfo.new(torrent)
      @destination = destination
      @peer_id = peer_id || DEFAULT_PEER_ID
      @port = 6881

      @metainfo.write_files(@destination)

      @peers = []

      @metainfo.trackers.each do |t|
        @peers += t.announce(self, @metainfo)
      end

      # XXX: Running OpenTracker locally gives me myself in the peers list.
      # Make sure to remove myself here. Is this normal behavior?
      Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).each do |ip|
        @peers = @peers.reject { |peer| peer.ip == ip && peer.port == port }
      end
    end
  end
end

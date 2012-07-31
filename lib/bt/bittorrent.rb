module BT
  class BitTorrent
    attr_reader :metainfo, :peer_id

    def initialize(torrent, destination, peer_id=nil)
      @metainfo = MetaInfo.new(torrent)
      @destination = destination
      @peer_id = peer_id || DEFAULT_PEER_ID

      @metainfo.write_files(@destination)

      @metainfo.trackers.each do |t|
        t.announce(self, @metainfo)
      end
    end

  end
end

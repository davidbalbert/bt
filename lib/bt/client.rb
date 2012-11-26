require 'securerandom'

module BT
  Torrent = Struct.new(:metainfo, :destination, :fileset, :peers)

  class Client
    DEFAULT_PORT = 6881

    attr_reader :metainfo, :peer_id, :port

    def initialize(peer_id=nil, port=nil)
      @peer_id = peer_id || make_default_peer_id
      @port = port || DEFAULT_PORT
      @torrents = {}
    end

    def torrents
      @torrents.values
    end

    # TODO: Separate Client#add and Client#start
    def add(torrent, destination)
      metainfo = MetaInfo.new(torrent)

      fileset = FileSet.new(metainfo, destination)
      fileset.touch!

      peers = []

      metainfo.trackers.each do |t|
        peers += t.announce(self, metainfo)
      end

      # XXX: Running OpenTracker locally gives me myself in the peers list.
      # Make sure to remove myself here. Is this normal behavior?
      #
      # TODO: Once we're connecting to all peers, we should remove this code in
      # favor of disconnecting when we receive our own peer_id in the handshake
      Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).each do |ip|
        peers = peers.reject { |peer| peer.ip == ip && peer.port == @port }
      end

      torrent = Torrent.new(metainfo, fileset, destination, peers)
      @torrents[metainfo.info_hash] = torrent

      peers.each(&:start)

      metainfo.info_hash
    end

    def [](info_hash)
      @torrents[info_hash]
    end

    def reset
      @torrents.delete_if { true }

      self
    end

    private
    def make_default_peer_id
      # build peer id out of version string, process id, and a set of random
      # digits.  Should be unique yet give us some identifying info. More info
      # here: http://wiki.theory.org/BitTorrentSpecification#peer_id
      "-RB#{BT::VERSION_STRING}-#{$$}-#{SecureRandom.hex(11)}".encode("BINARY")[0...20]
    end
  end
end

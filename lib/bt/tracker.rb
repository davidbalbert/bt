require 'net/http'
require 'uri'
require 'ipaddr'

module BT
  class Tracker
    def initialize(url)
      @url = URI.parse(url)
    end

    def announce(client, metainfo)
      # TODO: This request shouldn't be so hardcoded (uploaded and downloaded
      # percents for instance)
      params = {}
      params["info_hash"] = metainfo.info_hash
      params["peer_id"] = client.peer_id
      params["compact"] = "1"
      params["port"] = client.port
      params["uploaded"] = "0"
      params["downloaded"] = "0"
      params["left"] = metainfo.files.reduce(0) { |acc, fi| acc + fi.length }.to_s


      url = @url.dup

      url.query = URI::encode_www_form(params)

      resp = Net::HTTP.get_response(url)

      raise TrackerError, "The tracker said: '#{resp.body}'" unless resp.code == "200"

      @last_response = Bencode.load(resp.body)
      peers = @last_response["peers"]

      # TODO: Also support old style text IP lists
      peers.unpack("a4n" * (peers.length/6)).each_slice(2).map do |ip_string, port|
        Peer.new(IPAddr.new_ntoh(ip_string), port, metainfo, client.peer_id)
      end
    end
  end

  class TrackerError < StandardError; end
end

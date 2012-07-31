require 'net/http'
require 'uri'
require 'ipaddr'

module BT
  class Tracker
    def initialize(url)
      @url = URI.parse(url)
    end

    def announce(client, metainfo)
      params = {}
      params["info_hash"] = metainfo.info_hash
      params["peer_id"] = client.peer_id
      params["compact"] = "1"

      # TODO: Uncomment when we've implemented listening
      # params["port"] = client.port

      url = @url.dup

      url.query = URI::encode_www_form(params)

      @last_response = BEncode.load(Net::HTTP.get(url))

      peers = @last_response["peers"]

      peers.unpack("a4n" * (peers.length/6)).each_slice(2).map do |ip_string, port|
        [IPAddr.new_ntoh(ip_string), port]
      end
    end
  end
end

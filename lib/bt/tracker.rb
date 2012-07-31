require 'net/http'
require 'uri'

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

      URI::encode_www_form(params)
    end
  end
end

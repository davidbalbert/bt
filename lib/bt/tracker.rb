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

      url = @url.dup

      url.query = URI::encode_www_form(params)

      Net::HTTP.get_response(url)
    end
  end
end

require 'bt/version'
require 'bt/fileinfo'
require 'bt/metainfo'
require 'bt/tracker'
require 'bt/message'
require 'bt/peer'
require 'bt/client'

module BT
end

# # Ideal usage:
#
# require 'bt'
#
# client = BT::Client.new
#
# client.on_update do |info_hash, peer_speeds, estimated_time_left, bytes_downloaded, total_bytes|
#   # Update UI with speed and percent completion
# end
#
# client.on_peer do |info_hash, peer_id, event|
#   # event == :connect when we connect to a new peer and :disconnect when we
#   # disconnect. Also called when a peer initiants connect or disconnect
# end
#
# client.info_hashes
# # => Array of info_hashes
#
# client[info_hash]
# # => Torrent (maybe? Should these be public?)
#
# info_hash = client.add(path_to_torrent_file, path_to_destination)
# client.start(info_hash)
#
# client.pause(info_hash)
#
# client.delete(info_hash)
#
#
# # Another idea for BT::Client#add:
#
# info_hash = client.add(path_to_torrent_file) do |metainfo|
#   # inspect metainfo object to decide where you want to save the torrent.
#   # The block should either return the destination path or nil if you decide
#   # not to cancel the download.
#
#   if path = get_path_from_user(metainfo)
#     path
#   else
#     nil
#   end
# end
#
#
# # Other features that it would be nice to have:
# - Figuring out how to resume a partially downloaded torrent
# - Saving and loading the state of the client
#   - including config
# - UPnP and NAT-PMP support
# - Creating torrents
# - Magnet links
# - DHT

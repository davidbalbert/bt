require 'bt/version'
require 'bt/fileinfo'
require 'bt/metainfo'
require 'bt/tracker'
require 'bt/message'
require 'bt/peer'
require 'bt/client'

module BT
end

# # A simple example:
#
# require 'bt'
#
# client = BT::Client.new
# client.add(path_to_torrent_file, path_to_destination)
#
# client.on_event(:update) do |torrent|
#   puts torrent.percent_complete
# end
#
# client.wait_for(:complete)
#
#
#
# # A more complex example. Not necessarily API compatable. I'll work on that later:
#
# require 'bt'
#
# client = BT::Client.new
#
# client.on_event(:update) do |info_hash, peer_speeds, estimated_time_left, bytes_downloaded, total_bytes|
#   # Update UI with speed and percent completion
# end
#
# client.on_event(:connect) do |info_hash, peer_id|
#   # event == :connect when we connect to a new peer and :disconnect when we
#   # disconnect. Also called when a peer initiants connect or disconnect
# end
#
# client.on_event(:complete) do |info_hash|
#   # Do something when the torrent completes
# end
#
# client.on_event(:all) do |type, *args|
#   # Useful for integrating into an external event loop, maybe for a GUI app.
#   # This is run in a different thread, so you should have a threadsafe way to
#   # trigger events in your main event loop. For instance, you could have some
#   # kind of threadsafe queue that you write to and read from in your main loop.
# end
#
# client.info_hashes
# # => Array of info_hashes
#
# client[info_hash]
# # => Torrent? MetaInfo? (maybe? Should these be public?)
#
# # These methods should return immediately
# info_hash = client.add(path_to_torrent_file, path_to_destination)
#
# client.pause(info_hash)
#
# client.start(info_hash)
#
# client.delete(info_hash)
#
# # This should probably wait until the client has cleaned up, closed all connections, etc?
# client.shutdown
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
# - Multiple torrents inside one client
# - UPnP and NAT-PMP support
# - Creating torrents
# - Magnet links
# - DHT

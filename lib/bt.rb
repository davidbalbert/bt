require 'bt/version'
require 'bt/fileinfo'
require 'bt/metainfo'
require 'bt/tracker'
require 'bt/bittorrent'

module BT
  DEFAULT_PEER_ID = "-RB#{BT::VERSION_STRING}-#{$$}-#{Time.now.to_i}".encode("BINARY")[0...20]
end

require 'fileutils'
require 'digest'

require 'bencode'

module BT
  FileInfo = Struct.new(:path, :length)

  class MetaInfo
    attr_reader :path

    class << self
      alias load new
    end

    def initialize(path)
      @path = File.expand_path(path)
      @info = BEncode.load(File.open(@path, "rb") { |f| f.read })

      @info["info"]["name"].force_encoding("UTF-8")
    end

    def name
      @info["info"]["name"]
    end

    def piece_count
      @info["info"]["pieces"].size / 20
    end

    def files
      @files ||= if @info["info"]["length"]
        [FileInfo.new(@info["info"]["name"], @info["info"]["length"])]
      else
        @info["info"]["files"].map { |f| FileInfo.new(File.join(*f["path"]), f["length"]) }
      end
    end

    def trackers
      # TODO: Make this work with multitracker metadata extension:
      # http://bittorrent.org/beps/bep_0012.html
      @trackers ||= [Tracker.new(@info["announce"])]
    end

    def write_files(destination)
      destination = File.expand_path(destination)

      files.each do |fi|
        path = File.join(destination, name, fi.path)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") do |f|
          # XXX: truncate is not available on all platforms. Do something nicer?
          f.truncate(fi.length)
        end
      end
    end

    def info_hash
      @info_hash ||= Digest::SHA1.new.digest((@info["info"].bencode))
    end

    def inspect
      "#<BT::MetaInfo:#{@path}>"
    end
  end
end

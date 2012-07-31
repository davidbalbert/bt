require 'bencode'

module BT
  class MetaInfo
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
      @info = BEncode.load(File.open(@path, "rb") { |f| f.read })

      @info["info"]["name"].force_encoding("UTF-8")
    end

    def name
      @info["info"]["name"]
    end

    def files
      @files ||= if @info["info"]["length"]
        [name]
      else
        @info["info"]["files"].map { |f| File.join(*f["path"]) }
      end
    end

    def inspect
      "#<BT::MetaInfo:#{@path}>"
    end
  end
end

module BT
  class FileSet
    def initialize(metainfo, destination)
      # XXX: metainfo.name is supposed to be advisory. Mabye we should allow
      # the name to be overridden somewhere? For single file torrents, we'd
      # have to also change MetaInfo#files, because metainfo.name is used to
      # create the FileInfo object
      dir_name = metainfo.multiple_files? ? metainfo.name : ""
      @output_dir = File.join(File.expand_path(destination), dir_name)
      @files = metainfo.files
    end

    def touch!
      @files.each do |fi|
        path = File.join(@output_dir, fi.path)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") do |f|
          # XXX: truncate is not available on all platforms. Do something nicer?
          f.truncate(fi.length)
        end
      end
    end
  end
end
